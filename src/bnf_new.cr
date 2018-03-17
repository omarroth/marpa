require "./lib_marpa"

input = File.read("src/bnf/minimal.ebnf")

def parse_bnf(input)
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
  s_op_declare_bnf = LibMarpa.marpa_g_symbol_new(g)
  s_op_declare_match = LibMarpa.marpa_g_symbol_new(g)
  s_op_equal_priority = LibMarpa.marpa_g_symbol_new(g)
  s_quantifier = LibMarpa.marpa_g_symbol_new(g)
  s_boolean = LibMarpa.marpa_g_symbol_new(g)
  s_bare_name = LibMarpa.marpa_g_symbol_new(g)
  s_bracketed_name = LibMarpa.marpa_g_symbol_new(g)
  s_single_quoted_string = LibMarpa.marpa_g_symbol_new(g)
  s_character_class = LibMarpa.marpa_g_symbol_new(g)
  # s_whitespace = LibMarpa.marpa_g_symbol_new(g)
  # s_bracketed_name_string = LibMarpa.marpa_g_symbol_new(g)
  # s_string_without_single_quote = LibMarpa.marpa_g_symbol_new(g)
  # s_cc_elements = LibMarpa.marpa_g_symbol_new(g)

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
  symbol_names[s_op_declare_bnf] = "s_op_declare_bnf"
  symbol_names[s_op_declare_match] = "s_op_declare_match"
  symbol_names[s_op_equal_priority] = "s_op_equal_priority"
  symbol_names[s_quantifier] = "s_quantifier"
  symbol_names[s_boolean] = "s_boolean"
  symbol_names[s_bare_name] = "s_bare_name"
  symbol_names[s_bracketed_name] = "s_bracketed_name"
  symbol_names[s_single_quoted_string] = "s_single_quoted_string"
  symbol_names[s_character_class] = "s_character_class"
  # symbol_names[s_whitespace] = "s_whitespace"
  # symbol_names[s_bracketed_name_string] = "s_bracketed_name_string"
  # symbol_names[s_string_without_single_quote] = "s_string_without_single_quote"
  # symbol_names[s_cc_elements] = "s_cc_elements"

  # Terminals
  s_start_colon = LibMarpa.marpa_g_symbol_new(g)
  s_discard_colon = LibMarpa.marpa_g_symbol_new(g)
  s_separator_string = LibMarpa.marpa_g_symbol_new(g)
  s_proper_string = LibMarpa.marpa_g_symbol_new(g)
  s_arrow = LibMarpa.marpa_g_symbol_new(g)
  s_left_parenthesis = LibMarpa.marpa_g_symbol_new(g)
  s_right_parenthesis = LibMarpa.marpa_g_symbol_new(g)
  s_asterisk = LibMarpa.marpa_g_symbol_new(g)
  s_plus = LibMarpa.marpa_g_symbol_new(g)

  symbol_names[s_start_colon] = "s_start_colon"
  symbol_names[s_discard_colon] = "s_discard_colon"
  symbol_names[s_separator_string] = "s_separator_string"
  symbol_names[s_proper_string] = "s_proper_string"
  symbol_names[s_arrow] = "s_arrow"
  symbol_names[s_left_parenthesis] = "s_left_parenthesis"
  symbol_names[s_right_parenthesis] = "s_right_parenthesis"
  symbol_names[s_asterisk] = "s_asterisk"
  symbol_names[s_plus] = "s_plus"
  # End Terminals

  rhs = [] of Int32

  LibMarpa.marpa_g_sequence_new(g, s_statements, s_statement, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

  rhs.clear
  rhs << s_start_rule
  LibMarpa.marpa_g_rule_new(g, s_statement, rhs, rhs.size)

  rhs.clear
  rhs << s_priority_rule
  LibMarpa.marpa_g_rule_new(g, s_statement, rhs, rhs.size)

  rhs.clear
  rhs << s_quantified_rule
  LibMarpa.marpa_g_rule_new(g, s_statement, rhs, rhs.size)

  rhs.clear
  rhs << s_discard_rule
  LibMarpa.marpa_g_rule_new(g, s_statement, rhs, rhs.size)

  rhs.clear
  rhs << s_start_colon
  rhs << s_op_declare_bnf
  rhs << s_symbol
  LibMarpa.marpa_g_rule_new(g, s_start_rule, rhs, rhs.size)

  rhs.clear
  rhs << s_lhs
  rhs << s_op_declare
  rhs << s_alternatives
  LibMarpa.marpa_g_rule_new(g, s_priority_rule, rhs, rhs.size)

  rhs.clear
  rhs << s_lhs
  rhs << s_op_declare
  rhs << s_single_symbol
  rhs << s_quantifier
  rhs << s_adverb_list
  LibMarpa.marpa_g_rule_new(g, s_quantified_rule, rhs, rhs.size)

  rhs.clear
  rhs << s_discard_colon
  rhs << s_op_declare_match
  rhs << s_single_symbol
  LibMarpa.marpa_g_rule_new(g, s_discard_rule, rhs, rhs.size)

  rhs.clear
  rhs << s_op_declare_bnf
  LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, rhs.size)

  rhs.clear
  rhs << s_op_declare_match
  LibMarpa.marpa_g_rule_new(g, s_op_declare, rhs, rhs.size)

  LibMarpa.marpa_g_sequence_new(g, s_alternatives, s_rhs, s_op_equal_priority, 1, LibMarpa::MARPA_PROPER_SEPARATION)

  rhs.clear
  rhs << s_separator_specification
  LibMarpa.marpa_g_rule_new(g, s_adverb_item, rhs, rhs.size)

  rhs.clear
  rhs << s_proper_specification
  LibMarpa.marpa_g_rule_new(g, s_adverb_item, rhs, rhs.size)

  LibMarpa.marpa_g_sequence_new(g, s_adverb_list, s_adverb_item, -1, 0, LibMarpa::MARPA_PROPER_SEPARATION)

  rhs.clear
  rhs << s_separator_string
  rhs << s_arrow
  rhs << s_single_symbol
  LibMarpa.marpa_g_rule_new(g, s_separator_specification, rhs, rhs.size)

  rhs.clear
  rhs << s_proper_string
  rhs << s_arrow
  rhs << s_boolean
  LibMarpa.marpa_g_rule_new(g, s_proper_specification, rhs, rhs.size)

  rhs.clear
  rhs << s_symbol_name
  LibMarpa.marpa_g_rule_new(g, s_lhs, rhs, rhs.size)

  LibMarpa.marpa_g_sequence_new(g, s_rhs, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

  rhs.clear
  rhs << s_single_symbol
  LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, rhs.size)

  rhs.clear
  rhs << s_single_quoted_string
  LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, rhs.size)

  rhs.clear
  rhs << s_parenthesized_rhs_primary_list
  LibMarpa.marpa_g_rule_new(g, s_rhs_primary, rhs, rhs.size)

  rhs.clear
  rhs << s_left_parenthesis
  rhs << s_rhs_list
  rhs << s_right_parenthesis
  LibMarpa.marpa_g_rule_new(g, s_parenthesized_rhs_primary_list, rhs, rhs.size)

  LibMarpa.marpa_g_sequence_new(g, s_rhs_list, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

  rhs.clear
  rhs << s_symbol
  LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, rhs.size)

  rhs.clear
  rhs << s_character_class
  LibMarpa.marpa_g_rule_new(g, s_single_symbol, rhs, rhs.size)

  rhs.clear
  rhs << s_symbol_name
  LibMarpa.marpa_g_rule_new(g, s_symbol, rhs, rhs.size)

  rhs.clear
  rhs << s_bare_name
  LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, rhs.size)

  rhs.clear
  rhs << s_bracketed_name
  LibMarpa.marpa_g_rule_new(g, s_symbol_name, rhs, rhs.size)

  rhs.clear
  rhs << s_asterisk
  LibMarpa.marpa_g_rule_new(g, s_quantifier, rhs, rhs.size)

  rhs.clear
  rhs << s_plus
  LibMarpa.marpa_g_rule_new(g, s_quantifier, rhs, rhs.size)

  LibMarpa.marpa_g_start_symbol_set(g, s_statements)
  LibMarpa.marpa_g_precompute(g)

  r = LibMarpa.marpa_r_new(g)
  LibMarpa.marpa_r_start_input(r)

  tokens = ["(?<s_start_colon>:start)",
            "(?<s_discard_colon>:discard)",
            "(?<s_separator_string>separator)",
            "(?<s_proper_string>proper)",
            "(?<s_arrow>=>)",
            "(?<s_left_parenthesis>\\()",
            "(?<s_right_parenthesis>\\))",
            "(?<s_op_declare_bnf>::=)",
            "(?<s_op_declare_match>~)",
            "(?<s_op_equal_priority>\\|)",
            "(?<s_asterisk>\\*)",
            "(?<s_plus>\\+)",
            "(?<s_boolean>[01])",
            "(?<s_single_quoted_string>'[^'\x0A\x0B\x0C\x0D\\x{0085}\\x{2028}\\x{2029}]+')",
            "(?<s_character_class>\\[[^\x5d\x0A\x0B\x0C\x0D\\x{0085}\\x{2028}\\x{2029}]+\\])",
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

  return g, value, token_values, symbol_names
end
