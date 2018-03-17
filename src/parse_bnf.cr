require "./bnf_new"

input = File.read("src/bnf/minimal.ebnf")

configuration = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(configuration))

grammar = LibMarpa.marpa_g_new(pointerof(configuration))
LibMarpa.marpa_g_force_valued(grammar)

g, value, token_values, symbol_names = parse_bnf(input)

alias Item = {name: String, type: String}
alias RecArray = {String, Int32} | Array(RecArray)

stack = [] of RecArray
symbols = {} of Int32 => String
tokens = {} of String => String
discard = [] of String
l0 = [] of {String, RecArray}
g1 = [] of {String, RecArray}
unconfirmed = [] of String

loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(g, out p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    rule = value.value

    start = rule.t_arg_0
    stop = rule.t_arg_n
    rule_id = rule.t_rule_id

    context = [] of String
    context = stack[start..stop]
    stack.delete_at(start..stop)

    case rule.t_rule_id
    when 0 # statement+ => statements
      stack = context
      break
    when 1 # s_start_rule => statement
      context = context[0]
    when 2 # s_priority_rule => statement
      context = context[0]
    when 3 # s_quantified_rule => statement
      context = context[0]
    when 4 # s_discard_rule => statement
      context = context[0]
    when 5 # s_start_colon, s_op_declare_bnf, s_symbol => s_start_rule
    when 6 # s_lhs, s_op_declare, s_alternatives => s_priority_rule
      s_lhs = context[0][0].as(String)
      s_op_declare = context[1][0].as(String)
      s_alternatives = context[2].as(Array(RecArray))

      s_alternatives.each do |s_alternative|
        if s_op_declare == "::="
          g1 << {s_lhs, s_alternative}
        else
          l0 << {s_lhs, s_alternative}
        end
      end
    when 7 # s_lhs, s_op_declare, s_single_symbol, s_quantifier, s_adverb_list => s_quantified_rule
      s_lhs = context[0][0].as(String)
      s_op_declare = context[1][0].as(String)
      s_single_symbol = context[2].as({String, Int32})

      if s_op_declare == "::="
        g1 << {s_lhs, s_single_symbol}
      else
        l0 << {s_lhs, s_single_symbol}
      end
    when 8 # s_discard_colon, s_op_declare_match, s_single_symbol => s_discard_rule
      s_single_symbol = context[2][0].as(String)
      discard << s_single_symbol
    when 9 # s_op_declare_bnf => s_op_declare
      context = context[0]
    when 10 # s_op_declare_match => s_op_declare -- DONE
      context = context[0]
    when 11 # s_rhs+ '|' => s_alternatives -- done?
      context.delete({"|", 22})
    when 12 # s_separator_specification => s_adverb_item
      context = context[0]
    when 13 # s_proper_specification => s_adverb_item
      context = context[0]
    when 14 # s_adverb_item* => s_adverb_list
    when 15 # s_separator_string, s_arrow, s_single_symbol => s_separator_specification
      context.delete_at(1)
    when 16 # s_proper_string, s_arrow, s_boolean => s_proper_specification
      context.delete_at(1)
    when 17 # s_symbol_name => s_lhs -- DONE
      context = context[0]
    when 18 # s_rhs_primary+ => s_rhs
      if context.size == 1
        context = context[0]
      end
    when 19 # s_single_symbol => s_rhs_primary -- DONE
      context = context[0]
    when 20 # s_single_quoted_string => s_rhs_primary -- DONE
      context = context[0].as(Tuple(String, Int32))
      context = {context[0][1..-2], context[1]}
    when 21 # s_parenthesized_rhs_primary_list => s_rhs_primary -- DONE
      context = context[0]
    when 22 # s_left_parenthesis, s_rhs_list, s_right_parenthesis => s_parenthesized_rhs_primary_list -- DONE
      context = context[1]
    when 23 # s_rhs_primary+ => s_rhs_list
    when 24 # s_symbol => s_single_symbol
      context = context[0]
    when 25 # s_character_class => s_single_symbol
      context = context[0]
    when 26 # s_symbol_name => s_symbol
      context = context[0]
      # when 27 # s_bare_name => s_symbol_name
    when 27, 28 # s_bracketed_name => s_symbol_name
      context = context[0]
      s_symbol_name = context[0].as(String)
      unconfirmed << s_symbol_name
    when 29 # s_asterisk => s_quantifier
      context = context[0]
    when 30 # s_plus => s_quantifier
      context = context[0]
    end

    stack << context
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    token = value.value

    token_value = token_values[token.t_token_value - 1]
    token_id = token.t_token_id

    stack << {token_value, token_id}
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
    symbol = value.value
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
  end
end

# pp stack.size

# pp g1
# l0.each do |l0_rule|
#   puts l0_rule
# end

l0_confirmed = l0.map { |a, b| a }
l0_confirmed.uniq!
g1_confirmed = g1.map { |a, b| a }
g1_confirmed.uniq!
unconfirmed.uniq!

unconfirmed -= g1_confirmed
unconfirmed -= l0_confirmed

if unconfirmed.size > 0
  raise "Undefined item: #{unconfirmed[0]}"
end
