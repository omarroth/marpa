input = <<-BNF

priorities ::= alternatives+
alternatives ::= alternative+
alternative ::= rhs

lhs ::= <symbol name>
rhs ::= <rhs primary>+
<rhs primary> ::= <single symbol> | <single quoted string>
  | <parenthesized rhs primary list>
<parenthesized rhs primary list> ::= '(' <rhs primary list> ')'
<rhs primary list> ::= <rhs primary>+

<character class modifiers> ~ <character class modifier>*
<character class modifier> ~ ':ic'
<character class modifier> ~ ':i'

<single symbol> ::= symbol | <character class>
symbol ::= <symbol name>
<symbol name> ::= <bare name> | <bracketed name>
<bare name> ~ [\w]+
<bracketed name> ~ '<' <bracketed name string> '>'
<bracketed name string> ~ [\s\w]+

<character class> ~ '[' <cc elements> ']' <character class modifiers>
<cc elements> ~ <cc element>+
<cc element> ~ <safe cc character> | <escaped cc character>

BNF

config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))

s_alternative = LibMarpa.marpa_g_symbol_new(g)
s_alternatives = LibMarpa.marpa_g_symbol_new(g)
s_asterisk = LibMarpa.marpa_g_symbol_new(g)
s_backslash = LibMarpa.marpa_g_symbol_new(g)
s_bare_name = LibMarpa.marpa_g_symbol_new(g)
s_bracketed_name = LibMarpa.marpa_g_symbol_new(g)
s_cc_element = LibMarpa.marpa_g_symbol_new(g)
s_cc_elements = LibMarpa.marpa_g_symbol_new(g)
s_character_class = LibMarpa.marpa_g_symbol_new(g)
s_character_class_modifier = LibMarpa.marpa_g_symbol_new(g)
s_character_class_modifiers = LibMarpa.marpa_g_symbol_new(g)
s_colon_discard = LibMarpa.marpa_g_symbol_new(g)
s_colon_start = LibMarpa.marpa_g_symbol_new(g)
s_discard_rule = LibMarpa.marpa_g_symbol_new(g)
s_escaped_cc_character = LibMarpa.marpa_g_symbol_new(g)
s_left_bracket = LibMarpa.marpa_g_symbol_new(g)
s_left_parenthesis = LibMarpa.marpa_g_symbol_new(g)
s_lhs = LibMarpa.marpa_g_symbol_new(g)
s_op_declare = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_bnf = LibMarpa.marpa_g_symbol_new(g)
s_op_declare_match = LibMarpa.marpa_g_symbol_new(g)
s_parenthesized_rhs_primary_list = LibMarpa.marpa_g_symbol_new(g)
s_pipe = LibMarpa.marpa_g_symbol_new(g)
s_plus = LibMarpa.marpa_g_symbol_new(g)
s_priorities = LibMarpa.marpa_g_symbol_new(g)
s_priority_rule = LibMarpa.marpa_g_symbol_new(g)
s_quantified_rule = LibMarpa.marpa_g_symbol_new(g)
s_quantifier = LibMarpa.marpa_g_symbol_new(g)
s_rhs = LibMarpa.marpa_g_symbol_new(g)
s_rhs_primary = LibMarpa.marpa_g_symbol_new(g)
s_rhs_primary_list = LibMarpa.marpa_g_symbol_new(g)
s_right_bracket = LibMarpa.marpa_g_symbol_new(g)
s_right_parenthesis = LibMarpa.marpa_g_symbol_new(g)
s_safe_cc_character = LibMarpa.marpa_g_symbol_new(g)
s_single_quote = LibMarpa.marpa_g_symbol_new(g)
s_single_quoted_name = LibMarpa.marpa_g_symbol_new(g)
s_single_quoted_string = LibMarpa.marpa_g_symbol_new(g)
s_single_symbol = LibMarpa.marpa_g_symbol_new(g)
s_start_rule = LibMarpa.marpa_g_symbol_new(g)
s_statement = LibMarpa.marpa_g_symbol_new(g)
s_statements = LibMarpa.marpa_g_symbol_new(g)
s_string_without_single_quote = LibMarpa.marpa_g_symbol_new(g)
s_symbol = LibMarpa.marpa_g_symbol_new(g)
s_symbol_name = LibMarpa.marpa_g_symbol_new(g)
s_whitespace = LibMarpa.marpa_g_symbol_new(g)

symbol_name = {} of Int32 => String

symbol_name[s_alternative] = "s_alternative"
symbol_name[s_alternatives] = "s_alternatives"
symbol_name[s_asterisk] = "s_asterisk"
symbol_name[s_bare_name] = "s_bare_name"
symbol_name[s_bracketed_name] = "s_bracketed_name"
symbol_name[s_cc_element] = "s_cc_element"
symbol_name[s_cc_elements] = "s_cc_elements"
symbol_name[s_character_class] = "s_character_class"
symbol_name[s_character_class_modifier] = "s_character_class_modifier"
symbol_name[s_character_class_modifiers] = "s_character_class_modifiers"
symbol_name[s_colon_discard] = "s_colon_discard"
symbol_name[s_colon_start] = "s_colon_start"
symbol_name[s_discard_rule] = "s_discard_rule"
symbol_name[s_escaped_cc_character] = "s_escaped_cc_character"
symbol_name[s_left_bracket] = "s_left_bracket"
symbol_name[s_left_parenthesis] = "s_left_parenthesis"
symbol_name[s_lhs] = "s_lhs"
symbol_name[s_op_declare] = "s_op_declare"
symbol_name[s_op_declare_bnf] = "s_op_declare_bnf"
symbol_name[s_op_declare_match] = "s_op_declare_match"
symbol_name[s_parenthesized_rhs_primary_list] = "s_parenthesized_rhs_primary_list"
symbol_name[s_pipe] = "s_pipe"
symbol_name[s_plus] = "s_plus"
symbol_name[s_priorities] = "s_priorities"
symbol_name[s_priority_rule] = "s_priority_rule"
symbol_name[s_quantified_rule] = "s_quantified_rule"
symbol_name[s_quantifier] = "s_quantifier"
symbol_name[s_rhs] = "s_rhs"
symbol_name[s_rhs_primary] = "s_rhs_primary"
symbol_name[s_rhs_primary_list] = "s_rhs_primary_list"
symbol_name[s_right_bracket] = "s_right_bracket"
symbol_name[s_right_parenthesis] = "s_right_parenthesis"
symbol_name[s_safe_cc_character] = "s_safe_cc_character"
symbol_name[s_single_quote] = "s_single_quote"
symbol_name[s_single_quoted_name] = "s_single_quoted_name"
symbol_name[s_single_quoted_string] = "s_single_quoted_string"
symbol_name[s_single_symbol] = "s_single_symbol"
symbol_name[s_start_rule] = "s_start_rule"
symbol_name[s_statement] = "s_statement"
symbol_name[s_statements] = "s_statements"
symbol_name[s_string_without_single_quote] = "s_string_without_single_quote"
symbol_name[s_symbol] = "s_symbol"
symbol_name[s_symbol_name] = "s_symbol_name"
symbol_name[s_whitespace] = "s_whitespace"

rhs = [0, 0, 0, 0]

rhs[0] = s_start_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)

rhs[0] = s_priority_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)

rhs[0] = s_discard_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)

rhs[0] = s_quantified_rule
LibMarpa.marpa_g_rule_new(g, s_statement, rhs, 1)

rhs[0] = s_rhs
LibMarpa.marpa_g_rule_new(g, s_alternative, rhs, 1)

rhs[0] = s_symbol_name
LibMarpa.marpa_g_rule_new(g, s_lhs, rhs, 1)

rhs[0] = s_single_symbol
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)

rhs[0] = s_single_quoted_string
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)

rhs[0] = s_parenthesized_rhs_primary_list
LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, 1)

rhs[0] = s_symbol
LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, 1)

rhs[0] = s_character_class
LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, 1)

rhs[0] = s_symbol_name
LibMarpa.marpa_g_rule_new(g, s_symbol, rhs, 1)

rhs[0] = s_bare_name
LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, 1)

rhs[0] = s_bracketed_name
LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, 1)

# rhs[0] = s_asterisk
# LibMarpa.marpa_g_rule_new(g, s_quantifier, rhs, 1)

# rhs[0] = s_plus
# LibMarpa.marpa_g_rule_new(g, s_quantifier, rhs, 1)

rhs[0] = s_string_without_single_quote
LibMarpa.marpa_g_rule_new(g, s_single_quoted_name, rhs, 1)

rhs[0] = s_op_declare_bnf
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)

rhs[0] = s_op_declare_match
LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, 1)

rhs[0] = s_safe_cc_character
LibMarpa.marpa_g_rule_new(g, s_cc_element, rhs, 1)

rhs[0] = s_string_without_single_quote
rhs[1] = s_character_class_modifiers
LibMarpa.marpa_g_rule_new(g, s_single_quoted_string, rhs, 2)

rhs[0] = s_colon_start
rhs[1] = s_op_declare_bnf
rhs[2] = s_symbol
LibMarpa.marpa_g_rule_new(g, s_start_rule, rhs, 3)

rhs[0] = s_lhs
rhs[1] = s_op_declare
rhs[2] = s_priorities
LibMarpa.marpa_g_rule_new(g, s_priority_rule, rhs, 3)

rhs[0] = s_colon_discard
rhs[1] = s_op_declare_match
rhs[2] = s_single_symbol
LibMarpa.marpa_g_rule_new(g, s_discard_rule, rhs, 3)

rhs[0] = s_left_parenthesis
rhs[1] = s_rhs_primary_list
rhs[2] = s_right_parenthesis
LibMarpa.marpa_g_rule_new(g, s_parenthesized_rhs_primary_list, rhs, 3)

rhs[0] = s_lhs
rhs[1] = s_op_declare
rhs[2] = s_single_symbol
rhs[3] = s_quantifier
LibMarpa.marpa_g_rule_new(g, s_quantified_rule, rhs, 4)

rhs[0] = s_left_bracket
rhs[1] = s_cc_elements
rhs[2] = s_right_bracket
rhs[3] = s_character_class_modifiers
LibMarpa.marpa_g_rule_new(g, s_character_class, rhs, 4)

LibMarpa.marpa_g_sequence_new(g, s_alternatives, s_alternative, s_pipe, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_cc_elements, s_cc_element, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_character_class_modifiers, s_character_class_modifier, -1, 0, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_priorities, s_alternatives, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_rhs, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_rhs_primary_list, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_statements, s_statement, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

LibMarpa.marpa_g_start_symbol_set(g, s_statements)
LibMarpa.marpa_g_precompute(g)

r = LibMarpa.marpa_r_new(g)
LibMarpa.marpa_r_start_input(r)

tokens = [
  { %r((?<s_op_declare_bnf>::=)), "s_op_declare_bnf" },
  { %r((?<s_op_declare_match>~)), "s_op_declare_match" },
  { %r((?<s_left_parenthesis>\()), "s_left_parenthesis" },
  { %r((?<s_right_parenthesis>\))), "s_right_parenthesis" },
  { %r((?<s_colon_discard>:discard)), "s_colon_discard" },
  { %r((?<s_colon_start>:start)), "s_colon_start" },
  { %r((?<s_quantifier>\*|\+)), "s_quantifier" },
  { %r((?<s_backslash>\\)), "s_backslash" },
  { %r((?<s_string_without_single_quote>'[^'\n\v\f]+')), "s_string_without_single_quote" },
  { %r((?<s_bracketed_name><[\s\w]+>)), "s_bracketed_name" },
  { %r((?<s_character_class_modifiers>:ic|:i)), "s_character_class_modifier" },
  { %r((?<s_single_quote>\')), "s_single_quote" },
  { %r((?<s_pipe>\|)), "s_pipe" },
  { %r((?<s_left_bracket>\[)), "s_left_bracket" },
  { %r((?<s_right_bracket>\])), "s_right_bracket" },
  { %r((?<s_bare_name>[\w]+)), "s_bare_name" },
  { %r((?<s_whitespace>[\s]+)), "s_whitespace" },
  { %r((?<s_escaped_cc_character>\\?[^\]\n\v\f\r])), "s_safe_cc_character" },
  { %r((?<s_mismatch>.)), "s_mismatch" },
]

# LEXER
token_regex = Regex.union(tokens.map { |a| a[0] })
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

      if symbol == "s_bare_name"
        symbol = "s_safe_cc_character"

        status = LibMarpa.marpa_r_alternative(r, symbol_name.key(symbol), position + 1, 1)
        if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
          size = LibMarpa.marpa_r_terminals_expected(r, buffer)
          slice = buffer.to_slice[0, size]

          msg = "Unexpected symbol at line #{col}, character #{row}, expected:\n"
          slice.each do |id|
            msg += symbol_name[id] + "\n"
          end

          raise msg
        end
      end
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

stack = [] of {Int32, String}
loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(g, p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    #
  end

  token = value.value
  token_result = token.t_result
  token_value = token.t_token_value

  stack << {token_result, token_values[token_value - 1]}
end

# Time to pop

alias RecArray = String | Array(RecArray)

state = [] of RecArray
current = [] of RecArray
previous = -1

stack.size.times do
  item = stack.shift

  if item[0] <= previous
    state << current
    current = [] of RecArray
  end

  current << item[1]
  previous = item[0]
end

puts state

def pretty(rec_array : RecArray, spacing = 0)
  if rec_array.is_a?(Array)
    print " " * spacing
    puts "["
    rec_array.each do |item|
      print " " * spacing
      puts pretty(item, spacing + 2)
    end
    print " " * spacing
    print "]"
  else
    return " " * spacing + rec_array
  end
end

# puts pretty(state)
