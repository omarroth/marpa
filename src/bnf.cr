require "./lib_marpa"
require "json"

# input = File.read("src/bnf/metag.ebnf")
# input = File.read("src/bnf/numbers.ebnf")
input = File.read("src/bnf/minimal.ebnf")

config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))
LibMarpa.marpa_g_force_valued(g)

s_statements = LibMarpa.marpa_g_symbol_new(g)
s_statement = LibMarpa.marpa_g_symbol_new(g)
s_start_rule = LibMarpa.marpa_g_symbol_new(g)
s_priority_rule = LibMarpa.marpa_g_symbol_new(g)
s_quantified_rule = LibMarpa.marpa_g_symbol_new(g)
s_discard_rule = LibMarpa.marpa_g_symbol_new(g)
s_op_declare = LibMarpa.marpa_g_symbol_new(g)
s_alternatives = LibMarpa.marpa_g_symbol_new(g)
s_adverb_list = LibMarpa.marpa_g_symbol_new(g)
s_adverb_item = LibMarpa.marpa_g_symbol_new(g)
s_separator_specification = LibMarpa.marpa_g_symbol_new(g)
s_proper_specification = LibMarpa.marpa_g_symbol_new(g)
s_lhs = LibMarpa.marpa_g_symbol_new(g)
s_rhs = LibMarpa.marpa_g_symbol_new(g)
s_rhs_primary = LibMarpa.marpa_g_symbol_new(g)
s_parenthesized_rhs_primary_list = LibMarpa.marpa_g_symbol_new(g)
s_rhs_list = LibMarpa.marpa_g_symbol_new(g)
s_single_symbol = LibMarpa.marpa_g_symbol_new(g)
s_symbol = LibMarpa.marpa_g_symbol_new(g)
s_symbol_name = LibMarpa.marpa_g_symbol_new(g)
s_whitespace = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_bnf = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_match = LibMarpa.marpa_g_symbol_new(g)
s_op_equal_priority = LibMarpa.marpa_g_symbol_new(g)
s_quantifier = LibMarpa.marpa_g_symbol_new(g)
s_boolean = LibMarpa.marpa_g_symbol_new(g)
s_bare_name = LibMarpa.marpa_g_symbol_new(g)
s_bracketed_name = LibMarpa.marpa_g_symbol_new(g)
s_bracketed_name_string = LibMarpa.marpa_g_symbol_new(g)
s_single_quoted_string = LibMarpa.marpa_g_symbol_new(g)
s_string_without_single_quote = LibMarpa.marpa_g_symbol_new(g)
s_character_class = LibMarpa.marpa_g_symbol_new(g)
s_cc_elements = LibMarpa.marpa_g_symbol_new(g)

symbol_names = {} of Int32 => String

symbol_names[s_statements] = "s_statements"
symbol_names[s_statement] = "s_statement"
symbol_names[s_start_rule] = "s_start_rule"
symbol_names[s_priority_rule] = "s_priority_rule"
symbol_names[s_quantified_rule] = "s_quantified_rule"
symbol_names[s_discard_rule] = "s_discard_rule"
symbol_names[s_op_declare] = "s_op_declare"
symbol_names[s_alternatives] = "s_alternatives"
symbol_names[s_adverb_list] = "s_adverb_list"
symbol_names[s_adverb_item] = "s_adverb_item"
symbol_names[s_separator_specification] = "s_separator_specification"
symbol_names[s_proper_specification] = "s_proper_specification"
symbol_names[s_lhs] = "s_lhs"
symbol_names[s_rhs] = "s_rhs"
symbol_names[s_rhs_primary] = "s_rhs_primary"
symbol_names[s_parenthesized_rhs_primary_list] = "s_parenthesized_rhs_primary_list"
symbol_names[s_rhs_list] = "s_rhs_list"
symbol_names[s_single_symbol] = "s_single_symbol"
symbol_names[s_symbol] = "s_symbol"
symbol_names[s_symbol_name] = "s_symbol_name"
symbol_names[s_whitespace] = "s_whitespace"
symbol_names[s_op_declare_bnf] = "s_op_declare_bnf"
symbol_names[s_op_declare_match] = "s_op_declare_match"
symbol_names[s_op_equal_priority] = "s_op_equal_priority"
symbol_names[s_quantifier] = "s_quantifier"
symbol_names[s_boolean] = "s_boolean"
symbol_names[s_bare_name] = "s_bare_name"
symbol_names[s_bracketed_name] = "s_bracketed_name"
symbol_names[s_bracketed_name_string] = "s_bracketed_name_string"
symbol_names[s_single_quoted_string] = "s_single_quoted_string"
symbol_names[s_string_without_single_quote] = "s_string_without_single_quote"
symbol_names[s_character_class] = "s_character_class"
symbol_names[s_cc_elements] = "s_cc_elements"

rhs = [0, 0, 0, 0, 0]

# 24
# rhs[0] = s_lhs
# rhs[1] = s_op_declare
# rhs[2] = s_single_symbol
# rhs[3] = s_quantifier
# rhs[4] = s_adverb_list
# LibMarpa.marpa_g_rule_new(g, s_quantified_rule, rhs, 5)

# LibMarpa.marpa_g_sequence_new(g, s_statements, s_statement, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

# LibMarpa.marpa_g_start_symbol_set(g, s_statements)

LibMarpa.marpa_g_precompute(g)

r = LibMarpa.marpa_r_new(g)
LibMarpa.marpa_r_start_input(r)

tokens = [
  "(?<s_start_colon>:start)",
  "(?<s_discard_colon>:discard)",
  "(?<s_separator_string>separator)",
  "(?<s_proper_string>proper)",
  "(?<s_arrow>=>)",
  "(?<s_left_parenthesis>\\()",
  "(?<s_right_parenthesis>\\))",
  "(?<s_op_declare_bnf>::=)",
  "(?<s_op_declare_match>~)",
  "(?<s_op_equal_priority>\\|)",
  "(?<s_quantifier>\\*|\\+)",
  "(?<s_boolean>[01])",
  "(?<s_single_quoted_string>'[^'\x0A\x0B\x0C\x0D\u0085\u2028\u2029]+')",
  "(?<s_character_class>\\[[^\x5d\x0A\x0B\x0C\x0D\u0085\u2028\u2029]+\\])",
  "(?<s_bracketed_name><[\\s\\w]+>)",
  "(?<s_bare_name>[\\w]+)",
  "(?<s_whitespace>[\\s]+)",
  "(?<s_mismatch>.)",
]

token_regex = Regex.union(tokens.map { |a| /#{a}/ })
token_values = {} of Int32 => String

input.scan(token_regex) do |match|
  position = match.begin || 0
  symbol = match.to_h.compact.to_a[1][0]
  value = match.to_h.compact.to_a[1][1]

  col = input[0..position][/.+$/].size + 1
  row = input[0..position].count("\n") + 1

  if symbol == "s_whitespace"
    # Do nothing
  elsif symbol == "s_mismatch"
    raise "Lexing error at #{row}, #{col}"
  else
    status = LibMarpa.marpa_r_alternative(r, symbol_names.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      buffer = uninitialized Int32[128]
      size = LibMarpa.marpa_r_terminals_expected(r, buffer)
      slice = buffer.to_slice[0, size]

      msg = "Unexpected symbol at line #{row}, character #{col}, expected:\n"
      slice.each do |id|
        msg += symbol_names[id] + "\n"
      end

      raise msg
    end

    status = LibMarpa.marpa_r_earleme_complete(r)
    if status < 0
      e = LibMarpa.marpa_g_error(g, out p_error_string)
      raise "Earleme complete #{e}"
    end

    token_values[position] = value
  end
end

bocage = LibMarpa.marpa_b_new(r, -1)
if !bocage
  e = LibMarpa.marpa_g_error(g, out p_error_string)
  raise "Bocage complete #{e}"
end

order = LibMarpa.marpa_o_new(bocage)
if !order
  e = LibMarpa.marpa_g_error(g, p_error_string)
  raise "Order complete #{e}"
end

tree = LibMarpa.marpa_t_new(order)
if !tree
  e = LibMarpa.marpa_g_error(g, p_error_string)
  raise "Tree complete #{e}"
end

tree_status = LibMarpa.marpa_t_next(tree)
if tree_status <= -1
  e = LibMarpa.marpa_g_error(g, p_error_string)
  raise "Tree status #{e}"
end

value = LibMarpa.marpa_v_new(tree)
if !value
  e = LibMarpa.marpa_g_error(g, p_error_string)
  raise "Value returned #{e}"
end

configuration = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(configuration))

grammar = LibMarpa.marpa_g_new(pointerof(configuration))
LibMarpa.marpa_g_force_valued(grammar)

alias RecArray = String | Array(RecArray)
stack = [] of RecArray

symbols = {} of Int32 => String
tokens = {} of String => String
discard = [] of String

loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(g, p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    rule = value.value

    # TEMP
    print "    ", rule.t_rule_id, "\n"

    start = rule.t_arg_0
    stop = rule.t_arg_n
    rule_id = rule.t_rule_id

    current = [] of RecArray
    current = stack[start..stop]
    stack.delete_at(start..stop)

    # Reduce rule
    if current.size == 1 && rule_id != 25 && rule_id != 26
      current = current[0]
    end

    case rule.t_rule_id
    when 4
      # If symbol hasn't already been created, add it
      if !symbols.key?(current)
        id = LibMarpa.marpa_g_symbol_new(grammar)
        symbols[id] = current.as(String)
      end
    when 5
    when 6
      # current = current[1..-2]
      # tokens << [current[1]]
    when 7
      # if current.is_a?(Array)

    when 11
    when 12 # LHS name
      if !symbols.key?(current)
        id = LibMarpa.marpa_g_symbol_new(grammar)
        symbols[id] = current.as(String)
      end
    when 13
      current = current.as(String).gsub(" ", "_")
    when 14
      current = current.as(String).[1..-2].gsub(" ", "_")
    when 15, 16 # Op declare
    when 17     # Alternative
    when 18     # Start
      symbol = current[2]
      LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(symbol))
    when 19 # Priority
      lhs = current[0]
      op_declare = current[1]
      alternatives = current[2]

      if op_declare == "::="
        alternatives.as(Array).each do |item|
        end
      else
        alternatives.as(Array).each do |item|
          if item.is_a?(Array)
            puts item
          end
        end
      end
    when 20 # Discard
      discard << current[2].as(String)
    when 21, 22 # Adverb list
      current.as(Array).delete_at(1)
    when 23 # Parenthesized array
      if !current.is_a?(String)
        current = current[1]
      end
    when 24 # Quantified
      lhs = current[0].as(String)
      op_declare = current[1].as(String)
      single_symbol = current[2].as(String)
      adverb_list = current[4]?

      if current[3] == "*"
        quantifier = 0
      else
        quantifier = 1
      end

      separator = -1
      proper = LibMarpa::MARPA_PROPER_SEPARATION

      if adverb_list
        adverb_list.as(Array).each do |item|
          if item[0] == "separator"
            separator = symbols.key(item[1])
          elsif item[0] == "proper"
            if item[1] == 0
              proper = LibMarpa::MARPA_KEEP_SEPARATION
            end
          end
        end
      end

      if op_declare == "~"
        if symbols.key?(single_symbol)
          LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs), symbols.key(single_symbol), separator, quantifier, proper)
        else
          tokens[lhs] = "(?<#{lhs}>#{single_symbol}#{current[3].as(String)})"
        end
      elsif op_declare == "::="
        LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs), symbols.key(single_symbol), separator, quantifier, proper)
      end
    when 26
      current.delete("|")
    end

    stack << current
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    token = value.value
    token_value = token_values[token.t_token_value - 1]

    # TEMP
    puts token_value

    stack << token_value
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    #
  end
end
