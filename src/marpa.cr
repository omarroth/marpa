require "./helpers"
require "./lib_marpa"
require "json"
require "math"
require "option_parser"

alias Rule = Hash(String, String | Array(String))
alias RecArray = Array(RecArray) | String

def elapsed_text(elapsed)
  millis = elapsed.total_milliseconds
  return "#{millis.round(2)}ms" if millis >= 1

  "#{(millis * 1000).round(2)}µs"
end

def parse(rules : Hash(String, Array(Rule)), input : String)
  config = uninitialized LibMarpa::MarpaConfig
  LibMarpa.marpa_c_init(pointerof(config))

  grammar = LibMarpa.marpa_g_new(pointerof(config))
  LibMarpa.marpa_g_force_valued(grammar)

  p_error_string = String.new

  symbols = {} of Int32 => String

  (rules["L0"] + rules["G1"]).each do |rule|
    lhs = rule["lhs"].as(String)

    if lhs == "[:start]" || lhs == "[:discard]"
      next
    end

    if !symbols.key?(lhs)
      id = LibMarpa.marpa_g_symbol_new(grammar)

      if id < 0
        raise "Could not create symbol ID for #{lhs}"
      end

      symbols[id] = lhs
    end
  end

  rules["G1"].each do |rule|
    lhs = rule["lhs"].as(String)
    rhs = rule["rhs"].as(Array(String))

    min = rule["min"]?.try &.as(String)
    separator = rule["separator"]?.try &.as(String)
    proper = rule["proper"]?.try &.as(String)
    action = rule["action"]?.try &.as(String)

    # Handle start rules
    if lhs == "[:start]"
      status = LibMarpa.marpa_g_start_symbol(grammar)
      if status > 0
        puts "Previous start symbol was '#{symbols[status]}', setting new start symbol to '#{rhs[0]}'."
      end

      LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(rhs[0]))
      next
    end

    # Handle quantified rules
    if min || proper || separator
      min = min.try &.to_i
      min ||= 0

      proper = proper.try &.to_i
      proper ||= 1

      if separator
        if symbols.key?(separator)
          separator = symbols.key(separator)
        else
          id = LibMarpa.marpa_g_symbol_new(grammar)

          if id < 0
            raise "Could not create symbol ID for #{separator}"
          end

          symbols[id] = separator
          separator = id
        end
      end
      separator ||= -1

      status = LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs), symbols.key(rhs[0]), separator, min, proper)
      if status < 0
        error = LibMarpa.marpa_g_error(grammar, p_error_string)
        raise "Unable to create sequence for #{lhs}, error: #{error}"
      else
        rules["G1"].delete(rule)
        rules["G1"].insert(status, rule)
      end

      next
    end

    ids = [] of Int32
    rhs.each do |symbol|
      if symbol.starts_with?("'") && !symbols.key?(symbol)
        id = LibMarpa.marpa_g_symbol_new(grammar)

        if id < 0
          raise "Could not create symbol ID for #{lhs}"
        end

        rules["L0"] << {"lhs" => symbol, "rhs" => [Regex.escape(symbol[1..-2])]}
        symbols[id] = symbol
      end

      ids << symbols.key(symbol)
    end

    status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs), ids, ids.size)
    if status < 0
      error = LibMarpa.marpa_g_error(grammar, p_error_string)
      raise "Unable to create rule for #{lhs}, error: #{error}"
    end
  end

  tokens = {} of String => Regex
  discard = [] of String

  rules["L0"].each do |rule|
    lhs = rule["lhs"].as(String)
    rhs = rule["rhs"].as(Array(String))

    if lhs == "[:discard]"
      discard << rhs[0]
      next
    end

    if lhs.starts_with? "'"
      tokens[lhs] = Regex.new(rhs[0])
      next
    end

    regex = ""

    rhs.each do |symbol|
      case symbol
      when .starts_with? "'"
        regex += Regex.escape(symbol[1..-2])
      when .starts_with? "["
        regex += symbol
      when .starts_with? "/"
        regex += symbol[1..-2]
      else
        if !tokens.has_key?(symbol)
          # If we can't process a rule yet, come back 'round later
          rules.delete(rule)
          rules["L0"] << rule
          next
        else
          regex += tokens[symbol].to_s
        end
      end
    end

    tokens[lhs] = Regex.new(regex)
  end

  LibMarpa.marpa_g_error_clear(grammar)
  LibMarpa.marpa_g_precompute(grammar)
  status = LibMarpa.marpa_g_error(grammar, p_error_string)
  if status.value > 0
    raise status.to_s
  end
  recce = LibMarpa.marpa_r_new(grammar)
  LibMarpa.marpa_r_start_input(recce)

  position = 0
  values = {} of Int32 => String
  buffer = uninitialized Int32[64]
  until position == input.size
    size = LibMarpa.marpa_r_terminals_expected(recce, buffer)

    slice = buffer.to_slice[0, size]
    expected = [] of String
    slice.each do |id|
      expected << symbols[id]
    end

    matches = [] of {String, String}
    if expected.empty?
      break
    else
      expected.each do |terminal|
        md = tokens[terminal].match(input, position)
        if md && md.begin == position
          matches << {md[0], terminal}
        end
      end
    end

    if matches.empty?
      discard_token = false
      discard.each do |terminal|
        md = input.match(tokens[terminal], position)
        if md && md.begin == position
          position += md[0].size
          discard_token = true
        end
      end

      if discard_token
        next
      else
        last_newline = input[0..position].rindex("\n")
        last_newline ||= 0

        col = position - last_newline
        row = input[0..position].count("\n") + 1

        error_msg = "Lexing error at row #{row}, column #{col}, here:\n"
        error_msg += input[last_newline..position + 3]
        error_msg += "...\n"
        error_msg += " " * col
        error_msg += "^\n"

        error_msg += "Expected: \n"
        expected.each do |id|
          error_msg += "    #{id}\n"
        end

        raise error_msg
      end
    end

    matches.sort_by! { |a, b| a.size }.reverse!
    position += matches[0][0].size
    values[position + 1] = matches[0][0]

    matches.select { |a, b| a.size == matches[0][0].size }.each do |match|
      status = LibMarpa.marpa_r_alternative(recce, symbols.key(match[1]), position + 1, 1)

      if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
        # error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
        error_msg = "Unexpected symbol, expected: \n"
        expected.each do |id|
          error_msg += "#{id}\n"
        end

        raise error_msg
      end
    end

    status = LibMarpa.marpa_r_earleme_complete(recce)
    if status < 0
      e = LibMarpa.marpa_g_error(grammar, p_error_string)
      raise "Earleme complete: #{e}"
    end
  end

  bocage = LibMarpa.marpa_b_new(recce, -1)
  if !bocage
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Bocage complete: #{e}"
  end

  order = LibMarpa.marpa_o_new(bocage)
  if !order
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Order complete: #{e}"
  end

  tree = LibMarpa.marpa_t_new(order)
  if !tree
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Tree complete: #{e}"
  end

  tree_status = LibMarpa.marpa_t_next(tree)
  if tree_status <= -1
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Tree status: #{e}"
  end

  value = LibMarpa.marpa_v_new(tree)
  if !value
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Value returned: #{e}"
  end

  stack = [] of RecArray
  loop do
    step_type = LibMarpa.marpa_v_step(value)

    case step_type
    when step_type.value < 0
      e = LibMarpa.marpa_g_error(grammar, p_error_string)
      raise "Event returned #{e}"
    when LibMarpa::MarpaStepType::MARPA_STEP_RULE
      rule = value.value

      start = rule.t_arg_0
      stop = rule.t_arg_n
      rule_id = rule.t_rule_id

      context = stack[start..stop]
      stack.delete_at(start..stop)

      stack << context
    when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
      token = value.value

      stack << values[token.t_token_value]
    when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
      symbol = value.value

      stack << [] of RecArray
    when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
      stack = stack[0]
      break
    when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    end
  end

  return stack
end

def stack_to_rules(stack)
  rules = {} of String => Array(Rule)
  rules["G1"] = [] of Rule
  rules["L0"] = [] of Rule

  stack = stack.as(Array(RecArray))
  stack.each do |rule|
    rule = rule[0].as(Array(RecArray))

    lhs = rule[0].flatten
    op_declare = rule[1].flatten

    case lhs
    when ":start"
      rhs = rule[2].flatten.as(Array(String))
      rules["G1"] << {"lhs" => "[:start]", "rhs" => rhs}
    when ":discard"
      rhs = rule[2].flatten.as(Array(String))
      rules["L0"] << {"lhs" => "[:discard]", "rhs" => rhs}
    else
      lhs = lhs[0].as(String)

      if op_declare == ["::="]
        if rule[3]?
          # quantified
          rhs = rule[2].flatten.as(Array(String))

          quantified = Rule.new
          quantified["lhs"] = lhs
          quantified["rhs"] = rhs

          quantifier = rule[3].flatten
          if quantifier == ["*"]
            quantified["min"] = "0"
          elsif quantifier == ["+"]
            quantified["min"] = "1"
          end

          adverbs = rule[4].as(Array)
          adverbs.each do |adverb|
            adverb = adverb.flatten
            adverb.delete "=>"

            name = adverb[0].as(String)
            value = adverb[1].as(String)

            quantified[name] = value
          end

          rules["G1"] << quantified
        else
          # priority

          alternatives = rule[2].as(Array(RecArray))
          alternatives.delete "|"
          alternatives.each do |rhs|
            rules["G1"] << {"lhs" => lhs, "rhs" => rhs.flatten}
          end
        end
      elsif op_declare == ["~"]
        rhs = rule[2].flatten.as(Array(String))
        if rule[3]?
          quantifier = rule[3].flatten.as(Array(String))[0]
          rhs[0] = rhs[0] + quantifier
        end

        rules["L0"] << {"lhs" => lhs, "rhs" => rhs}
      end
    end
  end

  return rules
end

# Hacky way to get around type restrictions
class String
  def flatten
    return self
  end
end

def parse(rules : String, input : String)
  grammar = metag_grammar
  stack = parse(grammar, rules)
  rules = stack_to_rules(stack)

  stack = parse(rules, input)
  return stack
end

# input = %([1,"abc\ndef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])
# grammar = File.read("src/bnf/json.bnf")
# puts parse(grammar, input)

# input = File.read("src/bnf/metag.bnf")
# grammar = metag_grammar
# stack = parse(grammar, input)
# rules = stack_to_rules(stack)

# Extract rules (clumsily)
# puts %(rules["L0"] = [)
# rules["L0"].each { |a| print a, ",", "\n" }
# puts "]"
# puts ""
# puts %(rules["G1"] = [)
# rules["G1"].each { |a| print a, ",", "\n" }
# puts "]"

grammar = File.read("src/bnf/english.bnf")
input = File.read("src/test.english")
stack = parse(grammar, input)

input = File.read("src/sample.english")
OptionParser.parse! do |parser|
  parser.banner = "Usage: marpa [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

stack = parse(grammar, input)

# grammar = File.read("src/bnf/english.bnf")
# input = <<-END_INPUT
# How many is thirty-nine?
# # How about fourty-five?
# Is he for real?
# END_INPUT
# stack = parse(grammar, input)

stack = stack.as(Array(RecArray))
stack.each do |sentence|
  sentence = sentence.as(Array(RecArray))
  sentence = sentence.flatten.as(Array(String))
  # sentence = sentence.join(" ")

  puts sentence
end
