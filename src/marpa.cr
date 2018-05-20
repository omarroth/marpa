require "./helpers"
require "./lib_marpa"
require "json"

alias Rule = Hash(String, String | Array(String))
alias RecArray = Array(RecArray) | {String, String}

def parse_input(rules : Hash(String, Array(Rule)), input : String)
  meta_config = uninitialized LibMarpa::MarpaConfig
  LibMarpa.marpa_c_init(pointerof(meta_config))

  meta_grammar = LibMarpa.marpa_g_new(pointerof(meta_config))
  LibMarpa.marpa_g_force_valued(meta_grammar)

  p_error_string = String.new

  symbols = {} of Int32 => String

  (rules["L0"] + rules["G1"]).each do |rule|
    lhs = rule["lhs"].as(String)

    if lhs == "[:start]" || lhs == "[:discard]"
      next
    end

    if !symbols.key?(lhs)
      id = LibMarpa.marpa_g_symbol_new(meta_grammar)

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
      status = LibMarpa.marpa_g_start_symbol(meta_grammar)
      if status > 0
        puts "Previous start symbol was '#{symbols[status]}', setting new start symbol to '#{rhs[0]}'."
      end

      LibMarpa.marpa_g_start_symbol_set(meta_grammar, symbols.key(rhs[0]))
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
          id = LibMarpa.marpa_g_symbol_new(meta_grammar)

          if id < 0
            raise "Could not create symbol ID for #{separator}"
          end

          symbols[id] = separator
          separator = id
        end
      end
      separator ||= -1

      status = LibMarpa.marpa_g_sequence_new(meta_grammar, symbols.key(lhs), symbols.key(rhs[0]), separator, min, proper)
      if status < 0
        raise "Unable to create sequence for #{lhs}"
      end

      next
    end

    ids = [] of Int32
    rhs.each do |symbol|
      if symbol.starts_with?("'") && !symbols.key?(symbol)
        id = LibMarpa.marpa_g_symbol_new(meta_grammar)

        rules["L0"] << {"lhs" => symbol, "rhs" => [Regex.escape(symbol[1..-2])]}
        symbols[id] = symbol
      end

      ids << symbols.key(symbol)
    end

    status = LibMarpa.marpa_g_rule_new(meta_grammar, symbols.key(lhs), ids, ids.size)
    if status < 0
      raise "Unable to create rule for #{lhs}"
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

  LibMarpa.marpa_g_precompute(meta_grammar)
  recce = LibMarpa.marpa_r_new(meta_grammar)
  LibMarpa.marpa_r_start_input(recce)

  position = 0
  values = {} of Int32 => String
  until position == input.size
    last_newline = input[0..position].rindex("\n")
    last_newline ||= 0

    col = position - last_newline + 1
    row = input[0..position].count("\n") + 1

    buffer = uninitialized Int32[128]
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
        md = input.match(tokens[terminal], position)
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
        error_msg = "Lexing error at #{row}, #{col}, here: \n"
        error_msg += input[position - 15..position + 15].gsub("\n", "\\n") + "\n"
        error_msg += "               ^               \n"
        error_msg += "Expected: \n"
        expected.each do |id|
          error_msg += "    #{id}\n"
        end

        raise error_msg
      end
    end

    matches.sort_by! { |a, b| a.size }
    position += matches[0][0].size
    values[position + 1] = matches[0][0]

    matches.select { |a, b| a.size == matches[0][0].size }.each do |match|
      status = LibMarpa.marpa_r_alternative(recce, symbols.key(match[1]), position + 1, 1)

      if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
        error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
        expected.each do |id|
          error_msg += "#{id}\n"
        end

        raise error_msg
      end
    end

    status = LibMarpa.marpa_r_earleme_complete(recce)
    if status < 0
      e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
      raise "Earleme complete: #{e}"
    end
  end

  bocage = LibMarpa.marpa_b_new(recce, -1)
  if !bocage
    e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
    raise "Bocage complete: #{e}"
  end

  order = LibMarpa.marpa_o_new(bocage)
  if !order
    e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
    raise "Order complete: #{e}"
  end

  tree = LibMarpa.marpa_t_new(order)
  if !tree
    e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
    raise "Tree complete: #{e}"
  end

  tree_status = LibMarpa.marpa_t_next(tree)
  if tree_status <= -1
    e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
    raise "Tree status: #{e}"
  end

  value = LibMarpa.marpa_v_new(tree)
  if !value
    e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
    raise "Value returned: #{e}"
  end

  stack = [] of RecArray
  loop do
    step_type = LibMarpa.marpa_v_step(value)

    case step_type
    when step_type.value < 0
      e = LibMarpa.marpa_g_error(meta_grammar, p_error_string)
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

      stack << {values[token.t_token_value], symbols[token.t_token_id]}
    when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
      symbol = value.value

      start = symbol.t_arg_0
      stop = symbol.t_arg_n
    when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
      stack = stack[0]
      break
    when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    end
  end

  return stack
end

rules = metag_grammar
stack = parse_input(rules, File.read("src/bnf/metag.bnf"))
# pp metag_stack

# stack = stack[0].as(Array(RecArray))
stack = stack.as(Array(RecArray))
# pp stack
stack.each do |rule|
  rule = rule.as(Array(RecArray))
  op_declare = rule[0][1]
  puts op_declare
  
  # if op_declare == "op declare match"
  # Process L0 rule
  # else
  # Process G1 rule
  # end
end
