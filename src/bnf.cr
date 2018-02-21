require "./lib_marpa"
require "json"

# input = File.read("src/bnf/metag.ebnf")
# input = File.read("src/bnf/numbers.ebnf")
input = File.read("src/bnf/minimal.ebnf")

config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))
LibMarpa.marpa_g_force_valued(g)

s_adverb_item = LibMarpa.marpa_g_symbol_new(g)
s_adverb_list = LibMarpa.marpa_g_symbol_new(g)
s_alternative = LibMarpa.marpa_g_symbol_new(g)
s_alternatives = LibMarpa.marpa_g_symbol_new(g)
s_arrow = LibMarpa.marpa_g_symbol_new(g)
s_bare_name = LibMarpa.marpa_g_symbol_new(g)
s_boolean = LibMarpa.marpa_g_symbol_new(g)
s_bracketed_name = LibMarpa.marpa_g_symbol_new(g)
s_character_class = LibMarpa.marpa_g_symbol_new(g)
s_discard_colon = LibMarpa.marpa_g_symbol_new(g)
s_discard_rule = LibMarpa.marpa_g_symbol_new(g)
s_left_parenthesis = LibMarpa.marpa_g_symbol_new(g)
s_lhs = LibMarpa.marpa_g_symbol_new(g)
s_op_declare = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_bnf = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_match = LibMarpa.marpa_g_symbol_new(g)
s_op_equal_priority = LibMarpa.marpa_g_symbol_new(g)
s_parenthesized_rhs_primary_list = LibMarpa.marpa_g_symbol_new(g)
s_priority_rule = LibMarpa.marpa_g_symbol_new(g)
s_proper_specification = LibMarpa.marpa_g_symbol_new(g)
s_proper_string = LibMarpa.marpa_g_symbol_new(g)
s_quantified_rule = LibMarpa.marpa_g_symbol_new(g)
s_quantifier = LibMarpa.marpa_g_symbol_new(g)
s_rhs = LibMarpa.marpa_g_symbol_new(g)
s_rhs_primary = LibMarpa.marpa_g_symbol_new(g)
s_rhs_primary_list = LibMarpa.marpa_g_symbol_new(g)
s_right_parenthesis = LibMarpa.marpa_g_symbol_new(g)
s_separator_specification = LibMarpa.marpa_g_symbol_new(g)
s_separator_string = LibMarpa.marpa_g_symbol_new(g)
s_single_quoted_string = LibMarpa.marpa_g_symbol_new(g)
s_single_symbol = LibMarpa.marpa_g_symbol_new(g)
s_start_colon = LibMarpa.marpa_g_symbol_new(g)
s_start_rule = LibMarpa.marpa_g_symbol_new(g)
s_statement = LibMarpa.marpa_g_symbol_new(g)
s_statements = LibMarpa.marpa_g_symbol_new(g)
s_symbol = LibMarpa.marpa_g_symbol_new(g)
s_symbol_name = LibMarpa.marpa_g_symbol_new(g)

symbol_name = {} of Int32 => String

symbol_name[s_adverb_item] = "s_adverb_item"
symbol_name[s_adverb_list] = "s_adverb_list"
symbol_name[s_alternative] = "s_alternative"
symbol_name[s_alternatives] = "s_alternatives"
symbol_name[s_arrow] = "s_arrow"
symbol_name[s_bare_name] = "s_bare_name"
symbol_name[s_boolean] = "s_boolean"
symbol_name[s_bracketed_name] = "s_bracketed_name"
symbol_name[s_character_class] = "s_character_class"
symbol_name[s_discard_colon] = "s_discard_colon"
symbol_name[s_discard_rule] = "s_discard_rule"
symbol_name[s_left_parenthesis] = "s_left_parenthesis"
symbol_name[s_lhs] = "s_lhs"
symbol_name[s_op_declare] = "s_op_declare"
symbol_name[s_op_declare_bnf] = "s_op_declare_bnf"
symbol_name[s_op_declare_match] = "s_op_declare_match"
symbol_name[s_op_equal_priority] = "s_op_equal_priority"
symbol_name[s_parenthesized_rhs_primary_list] = "s_parenthesized_rhs_primary_list"
symbol_name[s_priority_rule] = "s_priority_rule"
symbol_name[s_proper_specification] = "s_proper_specification"
symbol_name[s_proper_string] = "s_proper_string"
symbol_name[s_quantified_rule] = "s_quantified_rule"
symbol_name[s_quantifier] = "s_quantifier"
symbol_name[s_rhs] = "s_rhs"
symbol_name[s_rhs_primary] = "s_rhs_primary"
symbol_name[s_rhs_primary_list] = "s_rhs_primary_list"
symbol_name[s_right_parenthesis] = "s_right_parenthesis"
symbol_name[s_separator_specification] = "s_separator_specification"
symbol_name[s_separator_string] = "s_separator_string"
symbol_name[s_single_quoted_string] = "s_single_quoted_string"
symbol_name[s_single_symbol] = "s_single_symbol"
symbol_name[s_start_colon] = "s_start_colon"
symbol_name[s_start_rule] = "s_start_rule"
symbol_name[s_statement] = "s_statement"
symbol_name[s_statements] = "s_statements"
symbol_name[s_symbol] = "s_symbol"
symbol_name[s_symbol_name] = "s_symbol_name"

rhs = [0, 0, 0, 0, 0]

# 0
rhs[0] = s_start_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)
# 1
rhs[0] = s_priority_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)
# 2
rhs[0] = s_quantified_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)
# 3
rhs[0] = s_discard_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)
# 4
rhs[0] = s_symbol_name
LibMarpa.marpa_g_rule_new(g, s_lhs, rhs, 1)
# 5
rhs[0] = s_single_symbol
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)
# 6
rhs[0] = s_single_quoted_string
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)
# 7
rhs[0] = s_parenthesized_rhs_primary_list
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)
# 8
rhs[0] = s_separator_specification
LibMarpa.marpa_g_rule_new(g, s_adverb_item, rhs, 1)
# 9
rhs[0] = s_proper_specification
LibMarpa.marpa_g_rule_new(g, s_adverb_item, rhs, 1)
# 10
rhs[0] = s_symbol
LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, 1)
# 11
rhs[0] = s_character_class
LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, 1)
# 12
rhs[0] = s_symbol_name
LibMarpa.marpa_g_rule_new(g, s_symbol, rhs, 1)
# 13
rhs[0] = s_bare_name
LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, 1)
# 14
rhs[0] = s_bracketed_name
LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, 1)
# 15
rhs[0] = s_op_declare_bnf
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)
# 16
rhs[0] = s_op_declare_match
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)
# 17
rhs[0] = s_op_declare_bnf
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)
# 18
rhs[0] = s_op_declare_match
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)
# 19
rhs[0] = s_rhs
rhs[1] = s_adverb_list
LibMarpa.marpa_g_rule_new(g, s_alternative, rhs, 2)
# 20
rhs[0] = s_start_colon
rhs[1] = s_op_declare_bnf
rhs[2] = s_symbol
LibMarpa.marpa_g_rule_new(g, s_start_rule, rhs, 3)
# 21
rhs[0] = s_lhs
rhs[1] = s_op_declare
rhs[2] = s_alternatives
LibMarpa.marpa_g_rule_new(g, s_priority_rule, rhs, 3)
# 22
rhs[0] = s_discard_colon
rhs[1] = s_op_declare_match
rhs[2] = s_single_symbol
LibMarpa.marpa_g_rule_new(g, s_discard_rule, rhs, 3)
# 23
rhs[0] = s_separator_string
rhs[1] = s_arrow
rhs[2] = s_single_symbol
LibMarpa.marpa_g_rule_new(g, s_separator_specification, rhs, 3)
# 24
rhs[0] = s_proper_string
rhs[1] = s_arrow
rhs[2] = s_boolean
LibMarpa.marpa_g_rule_new(g, s_proper_specification, rhs, 3)
# 25
rhs[0] = s_left_parenthesis
rhs[1] = s_rhs_primary_list
rhs[2] = s_right_parenthesis
LibMarpa.marpa_g_rule_new(g, s_parenthesized_rhs_primary_list, rhs, 3)
# 26
rhs[0] = s_lhs
rhs[1] = s_op_declare
rhs[2] = s_single_symbol
rhs[3] = s_quantifier
rhs[4] = s_adverb_list
LibMarpa.marpa_g_rule_new(g, s_quantified_rule, rhs, 5)

# 27
LibMarpa.marpa_g_sequence_new(g, s_adverb_list, s_adverb_item, -1, 0, LibMarpa::MARPA_PROPER_SEPARATION)
# 28
LibMarpa.marpa_g_sequence_new(g, s_alternatives, s_alternative, s_op_equal_priority, 1, LibMarpa::MARPA_PROPER_SEPARATION)
# 29
LibMarpa.marpa_g_sequence_new(g, s_rhs, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
# 30
LibMarpa.marpa_g_sequence_new(g, s_rhs_primary_list, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
# 31
LibMarpa.marpa_g_sequence_new(g, s_statements, s_statement, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

LibMarpa.marpa_g_start_symbol_set(g, s_statements)

LibMarpa.marpa_g_precompute(g)

r = LibMarpa.marpa_r_new(g)
LibMarpa.marpa_r_start_input(r)

tokens = [
  {"(?<s_start_colon>:start)", "s_start_colon"},
  {"(?<s_discard_colon>:discard)", "s_discard_colon"},
  {"(?<s_separator_string>separator)", "s_separator_string"},
  {"(?<s_proper_string>proper)", "s_proper_string"},
  {"(?<s_arrow>=>)", "s_arrow"},
  {"(?<s_left_parenthesis>\\()", "s_left_parenthesis"},
  {"(?<s_right_parenthesis>\\))", "s_right_parenthesis"},
  {"(?<s_op_declare_bnf>::=)", "s_op_declare_bnf"},
  {"(?<s_op_declare_match>~)", "s_op_declare_match"},
  {"(?<s_op_equal_priority>\\|)", "s_op_equal_priority"},
  {"(?<s_quantifier>\\*|\\+)", "s_quantifier"},
  {"(?<s_boolean>[01])", "s_boolean"},
  {"(?<s_single_quoted_string>'[^'\x0A\x0B\x0C\x0D\u0085\u2028\u2029]+')", "s_single_quoted_string"},
  {"(?<s_character_class>\\[[^\x5d\x0A\x0B\x0C\x0D\u0085\u2028\u2029]+\\])", "s_character_class"},
  {"(?<s_bracketed_name><[\\s\\w]+>)", "s_bracketed_name"},
  {"(?<s_bare_name>[\\w]+)", "s_bare_name"},
  {"(?<s_whitespace>[\\s]+)", "s_whitespace"},
  {"(?<s_mismatch>.)", "s_mismatch"},
]

token_regex = Regex.union(tokens.map { |a, b| /#{a}/ })
token_values = {} of Int32 => String

input.scan(token_regex) do |match|
  position = match.begin || 0
  symbol = match.to_h.compact.to_a[1][0]
  value = match.to_h.compact.to_a[1][1]

  row = input[0..position][/.+$/].size + 1
  col = input[0..position].count("\n") + 1

  if symbol == "s_whitespace"
    # Do nothing
  elsif symbol == "s_mismatch"
    raise "Lexing error at #{col}, #{row}"
  else
    status = LibMarpa.marpa_r_alternative(r, symbol_name.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      buffer = uninitialized Int32[128]
      size = LibMarpa.marpa_r_terminals_expected(r, buffer)
      slice = buffer.to_slice[0, size]

      msg = "Unexpected symbol at line #{col}, character #{row}, expected:\n"
      slice.each do |id|
        msg += symbol_name[id] + "\n"
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
  puts "Order complete #{e}"
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

alias RecArray = String | Array(RecArray)
stack = [] of RecArray

spacing = token_values.to_a.sort_by { |a, b| b.size }[-1][1].size + 1

loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(g, p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    rule = value.value

    #    if rule.t_rule_id < 4
    #      print " "*spacing, rule, "\n"
    #    end

    start = rule.t_arg_0
    stop = rule.t_arg_n

    if stop - start > 0
      tmp = [] of RecArray
      tmp = stack[start..stop]
      stack.delete_at(start..stop)

      stack << tmp
    end
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    token = value.value
    token_value = token_values[token.t_token_value - 1]

    # print token_values[token.t_token_value - 1].ljust(spacing), token, "\n"
    # print token_value, "\n"

    stack << token_value
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    #
  end
end

def rec_delete(stack, character)
  if stack.is_a?(Array)
    stack.each do |item|
      stack.delete(character)
      rec_delete(item, character)
    end
  end
end

def reduce(item)
  if item.is_a?(Array)
    if item.size == 1
      return reduce(item[0])
    else
      return item.map! { |x| reduce(x) }
    end
  else
    return item
  end
end

rec_delete(stack, "(")
rec_delete(stack, ")")
rec_delete(stack, "|")
rec_delete(stack, "=>")

stack = reduce(stack)

File.write("src/bnf.json", stack)
pp stack
