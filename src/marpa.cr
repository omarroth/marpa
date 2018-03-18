require "./lib_marpa"

build_bnf = File.read("src/bnf/minimal.ebnf")

build_config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(build_config))

build_grammar = LibMarpa.marpa_g_new(pointerof(build_config))
LibMarpa.marpa_g_force_valued(build_grammar)

p_error_string = uninitialized String

s_statements = LibMarpa.marpa_g_symbol_new(build_grammar)
s_statement = LibMarpa.marpa_g_symbol_new(build_grammar)
s_start_rule = LibMarpa.marpa_g_symbol_new(build_grammar)
s_priority_rule = LibMarpa.marpa_g_symbol_new(build_grammar)
s_quantified_rule = LibMarpa.marpa_g_symbol_new(build_grammar)
s_discard_rule = LibMarpa.marpa_g_symbol_new(build_grammar)
s_op_declare = LibMarpa.marpa_g_symbol_new(build_grammar)
s_alternatives = LibMarpa.marpa_g_symbol_new(build_grammar)
s_adverb_list = LibMarpa.marpa_g_symbol_new(build_grammar)
s_adverb_item = LibMarpa.marpa_g_symbol_new(build_grammar)
s_separator_specification = LibMarpa.marpa_g_symbol_new(build_grammar)
s_proper_specification = LibMarpa.marpa_g_symbol_new(build_grammar)
s_lhs = LibMarpa.marpa_g_symbol_new(build_grammar)
s_rhs = LibMarpa.marpa_g_symbol_new(build_grammar)
s_rhs_primary = LibMarpa.marpa_g_symbol_new(build_grammar)
s_parenthesized_rhs_primary_list = LibMarpa.marpa_g_symbol_new(build_grammar)
s_rhs_list = LibMarpa.marpa_g_symbol_new(build_grammar)
s_single_symbol = LibMarpa.marpa_g_symbol_new(build_grammar)
s_symbol = LibMarpa.marpa_g_symbol_new(build_grammar)
s_symbol_name = LibMarpa.marpa_g_symbol_new(build_grammar)
s_op_declare_bnf = LibMarpa.marpa_g_symbol_new(build_grammar)
s_op_declare_match = LibMarpa.marpa_g_symbol_new(build_grammar)
s_op_equal_priority = LibMarpa.marpa_g_symbol_new(build_grammar)
s_quantifier = LibMarpa.marpa_g_symbol_new(build_grammar)
s_boolean = LibMarpa.marpa_g_symbol_new(build_grammar)
s_bare_name = LibMarpa.marpa_g_symbol_new(build_grammar)
s_bracketed_name = LibMarpa.marpa_g_symbol_new(build_grammar)
s_single_quoted_string = LibMarpa.marpa_g_symbol_new(build_grammar)
s_character_class = LibMarpa.marpa_g_symbol_new(build_grammar)

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

# TERMINALS
s_start_colon = LibMarpa.marpa_g_symbol_new(build_grammar)
s_discard_colon = LibMarpa.marpa_g_symbol_new(build_grammar)
s_separator_string = LibMarpa.marpa_g_symbol_new(build_grammar)
s_proper_string = LibMarpa.marpa_g_symbol_new(build_grammar)
s_arrow = LibMarpa.marpa_g_symbol_new(build_grammar)
s_left_parenthesis = LibMarpa.marpa_g_symbol_new(build_grammar)
s_right_parenthesis = LibMarpa.marpa_g_symbol_new(build_grammar)
s_asterisk = LibMarpa.marpa_g_symbol_new(build_grammar)
s_plus = LibMarpa.marpa_g_symbol_new(build_grammar)

symbol_names[s_start_colon] = "s_start_colon"
symbol_names[s_discard_colon] = "s_discard_colon"
symbol_names[s_separator_string] = "s_separator_string"
symbol_names[s_proper_string] = "s_proper_string"
symbol_names[s_arrow] = "s_arrow"
symbol_names[s_left_parenthesis] = "s_left_parenthesis"
symbol_names[s_right_parenthesis] = "s_right_parenthesis"
symbol_names[s_asterisk] = "s_asterisk"
symbol_names[s_plus] = "s_plus"
# END

rhs = [] of Int32

LibMarpa.marpa_g_sequence_new(build_grammar, s_statements, s_statement, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

rhs.clear
rhs << s_start_rule
LibMarpa.marpa_g_rule_new(build_grammar, s_statement, rhs, rhs.size)

rhs.clear
rhs << s_priority_rule
LibMarpa.marpa_g_rule_new(build_grammar, s_statement, rhs, rhs.size)

rhs.clear
rhs << s_quantified_rule
LibMarpa.marpa_g_rule_new(build_grammar, s_statement, rhs, rhs.size)

rhs.clear
rhs << s_discard_rule
LibMarpa.marpa_g_rule_new(build_grammar, s_statement, rhs, rhs.size)

rhs.clear
rhs << s_start_colon
rhs << s_op_declare_bnf
rhs << s_symbol
LibMarpa.marpa_g_rule_new(build_grammar, s_start_rule, rhs, rhs.size)

rhs.clear
rhs << s_lhs
rhs << s_op_declare
rhs << s_alternatives
LibMarpa.marpa_g_rule_new(build_grammar, s_priority_rule, rhs, rhs.size)

rhs.clear
rhs << s_lhs
rhs << s_op_declare
rhs << s_single_symbol
rhs << s_quantifier
rhs << s_adverb_list
LibMarpa.marpa_g_rule_new(build_grammar, s_quantified_rule, rhs, rhs.size)

rhs.clear
rhs << s_discard_colon
rhs << s_op_declare_match
rhs << s_single_symbol
LibMarpa.marpa_g_rule_new(build_grammar, s_discard_rule, rhs, rhs.size)

rhs.clear
rhs << s_op_declare_bnf
LibMarpa.marpa_g_rule_new(build_grammar, s_op_declare, rhs, rhs.size)

rhs.clear
rhs << s_op_declare_match
LibMarpa.marpa_g_rule_new(build_grammar, s_op_declare, rhs, rhs.size)

LibMarpa.marpa_g_sequence_new(build_grammar, s_alternatives, s_rhs, s_op_equal_priority, 1, LibMarpa::MARPA_PROPER_SEPARATION)

rhs.clear
rhs << s_separator_specification
LibMarpa.marpa_g_rule_new(build_grammar, s_adverb_item, rhs, rhs.size)

rhs.clear
rhs << s_proper_specification
LibMarpa.marpa_g_rule_new(build_grammar, s_adverb_item, rhs, rhs.size)

LibMarpa.marpa_g_sequence_new(build_grammar, s_adverb_list, s_adverb_item, -1, 0, LibMarpa::MARPA_PROPER_SEPARATION)

rhs.clear
rhs << s_separator_string
rhs << s_arrow
rhs << s_single_symbol
LibMarpa.marpa_g_rule_new(build_grammar, s_separator_specification, rhs, rhs.size)

rhs.clear
rhs << s_proper_string
rhs << s_arrow
rhs << s_boolean
LibMarpa.marpa_g_rule_new(build_grammar, s_proper_specification, rhs, rhs.size)

rhs.clear
rhs << s_symbol_name
LibMarpa.marpa_g_rule_new(build_grammar, s_lhs, rhs, rhs.size)

LibMarpa.marpa_g_sequence_new(build_grammar, s_rhs, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

rhs.clear
rhs << s_single_symbol
LibMarpa.marpa_g_rule_new(build_grammar, s_rhs_primary, rhs, rhs.size)

rhs.clear
rhs << s_single_quoted_string
LibMarpa.marpa_g_rule_new(build_grammar, s_rhs_primary, rhs, rhs.size)

rhs.clear
rhs << s_parenthesized_rhs_primary_list
LibMarpa.marpa_g_rule_new(build_grammar, s_rhs_primary, rhs, rhs.size)

rhs.clear
rhs << s_left_parenthesis
rhs << s_rhs_list
rhs << s_right_parenthesis
LibMarpa.marpa_g_rule_new(build_grammar, s_parenthesized_rhs_primary_list, rhs, rhs.size)

LibMarpa.marpa_g_sequence_new(build_grammar, s_rhs_list, s_rhs_primary, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

rhs.clear
rhs << s_symbol
LibMarpa.marpa_g_rule_new(build_grammar, s_single_symbol, rhs, rhs.size)

rhs.clear
rhs << s_character_class
LibMarpa.marpa_g_rule_new(build_grammar, s_single_symbol, rhs, rhs.size)

rhs.clear
rhs << s_symbol_name
LibMarpa.marpa_g_rule_new(build_grammar, s_symbol, rhs, rhs.size)

rhs.clear
rhs << s_bare_name
LibMarpa.marpa_g_rule_new(build_grammar, s_symbol_name, rhs, rhs.size)

rhs.clear
rhs << s_bracketed_name
LibMarpa.marpa_g_rule_new(build_grammar, s_symbol_name, rhs, rhs.size)

rhs.clear
rhs << s_asterisk
LibMarpa.marpa_g_rule_new(build_grammar, s_quantifier, rhs, rhs.size)

rhs.clear
rhs << s_plus
LibMarpa.marpa_g_rule_new(build_grammar, s_quantifier, rhs, rhs.size)

LibMarpa.marpa_g_start_symbol_set(build_grammar, s_statements)
LibMarpa.marpa_g_precompute(build_grammar)

build_recce = LibMarpa.marpa_r_new(build_grammar)
LibMarpa.marpa_r_start_input(build_recce)

build_tokens = ["(?<s_start_colon>:start)",
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
token_regex = Regex.union(build_tokens.map { |a| /#{a}/ })

token_values = {} of Int32 => String

# LEXER
build_bnf.scan(token_regex) do |match|
  position = match.begin || 0
  symbol = match.to_h.compact.to_a[1][0]
  value = match.to_h.compact.to_a[1][1]

  col = position - (build_bnf[0..position].rindex("\n") || 0) + 1
  row = build_bnf[0..position].count("\n") + 1

  if symbol == "s_whitespace"
  elsif symbol == "s_mismatch"
    raise "Lexing error at #{row}, #{col}"
  else
    status = LibMarpa.marpa_r_alternative(build_recce, symbol_names.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      buffer = uninitialized Int32[128]
      size = LibMarpa.marpa_r_terminals_expected(build_recce, buffer)
      slice = buffer.to_slice[0, size]

      msg = "Unexpected symbol at line #{row}, character #{col}, expected:\n"
      slice.each do |id|
        msg += symbol_names[id] + "\n"
      end

      raise msg
    end

    status = LibMarpa.marpa_r_earleme_complete(build_recce)
    if status < 0
      e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
      raise "Earleme complete #{e}"
    end

    token_values[position] = value
  end
end
# END

bocage = LibMarpa.marpa_b_new(build_recce, -1)
if !bocage
  e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
  raise "Bocage complete #{e}"
end

order = LibMarpa.marpa_o_new(bocage)
if !order
  e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
  raise "Order complete #{e}"
end

tree = LibMarpa.marpa_t_new(order)
if !tree
  e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
  raise "Tree complete #{e}"
end

tree_status = LibMarpa.marpa_t_next(tree)
if tree_status <= -1
  e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
  raise "Tree status #{e}"
end

value = LibMarpa.marpa_v_new(tree)
if !value
  e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
  raise "Value returned #{e}"
end

alias Item = {String, Int32}
alias RecArray = Item | Array(RecArray)

stack = [] of RecArray
context = [] of RecArray
l0 = [] of RecArray
g1 = [] of RecArray
unconfirmed = [] of Item

start_rules = [] of Array(RecArray)
priority_rules = [] of Array(RecArray)
quantified_rules = [] of Array(RecArray)
discard_rules = [] of Array(RecArray)

loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    rule = value.value

    start = rule.t_arg_0
    stop = rule.t_arg_n
    rule_id = rule.t_rule_id

    context = stack[start..stop]
    stack.delete_at(start..stop)

    case rule_id
    when 0 # statement+ => statements
      stack = context
      break
    when 5 # s_start_colon, s_op_declare_bnf, s_symbol => s_start_rule
      start_rules << context
    when 6 # s_lhs, s_op_declare, s_alternatives => s_priority_rule
      s_lhs = context[0].as(Item)
      s_op_declare = context[1].as(Item)

      if s_op_declare[0] == "::="
        g1 << s_lhs
      else
        l0 << s_lhs
      end

      priority_rules << context
    when 7 # s_lhs, s_op_declare, s_single_symbol, s_quantifier, s_adverb_list => s_quantified_rule
      s_lhs = context[0].as(Item)
      s_op_declare = context[1].as(Item)

      if s_op_declare[0] == "::="
        g1 << s_lhs
      else
        l0 << s_lhs
      end

      quantified_rules << context
    when 8 # s_discard_colon, s_op_declare_match, s_single_symbol => s_discard_rule
      discard_rules << context
    when 11 # s_rhs+ '|' => s_alternatives
      context.delete({"|", 22})
    when 14     # s_adverb_item* => s_adverb_list
    when 15, 16 # => s_{proper,separator}_specification
      # s_proper_string, s_arrow, s_boolean => s_proper_specification
      # s_separator_string, s_arrow, s_single_symbol => s_separator_specification
      context.delete({"=>", 33})
    when 18 # s_rhs_primary+ => s_rhs
    when 22
      context = context[1]
    when 27, 28 # => s_symbol_name
      context = context[0].as(Item)
      unconfirmed << context
    else
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

l0.uniq!
g1.uniq!

unconfirmed = unconfirmed - l0 - g1
if unconfirmed.size > 0
  symbols = unconfirmed.map { |a, b| a }.join(", ")
  raise "Undefined symbols: #{symbols}"
end

symbols = {} of Int32 => String
tokens = {} of String => Regex

configuration = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(configuration))

grammar = LibMarpa.marpa_g_new(pointerof(configuration))
LibMarpa.marpa_g_force_valued(grammar)

# Create symbols
(g1 + l0).each do |symbol|
  id = LibMarpa.marpa_g_symbol_new(grammar)
  value = symbol[0].as(String)

  symbols[id] = value
end

start_rules.each do |rule|
  symbol = rule[2].as(Item)

  LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(symbol[0]))
end

discard = [] of Item
discard_rules.each do |rule|
  symbol = rule[2].as(Item)

  discard << symbol
end

# We want to do lexical rules first
quantified_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!
priority_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!

quantified_rules.each do |rule|
  lhs = rule[0].as(Item)
  op_declare = rule[1].as(Item)
  single_symbol = rule[2].as(Item)
  quantifier = rule[3].as(Item)

  case op_declare[0]
  when "~"
    if single_symbol[1] == 26
      raise "An L0 lexeme cannot appear on the RHS of an L0 rule : #{single_symbol[0]}"
    end

    regex = /#{single_symbol[0]}#{quantifier[0]}/

    if tokens[lhs[0]]?
      tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
    else
      tokens[lhs[0]] = regex
    end
  when "::="
    rhs = [] of Int32

    case quantifier[0]
    when "*"
      quantifier = 0
    else
      quantifier = 1
    end

    separator = -1
    proper = LibMarpa::MARPA_PROPER_SEPARATION

    # Get adverbs if possible
    adverb_list = rule[4]?.try &.as(Array)
    adverb_list ||= [] of RecArray
    adverb_list.each do |adverb|
      key = adverb[0].as(Item)
      value = adverb[1].as(Item)
      case key[0]
      when "proper"
        if value[0] == 0
          proper = LibMarpa::MARPA_KEEP_SEPARATION
        end
      when "separator"
        separator = symbols.key(value[0])
      end
    end

    status = LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs[0]), symbols.key(single_symbol[0]), separator, quantifier, proper)
    if status < 0
      raise "Unable to create sequence for #{lhs[0]}"
    end
  end
end

priority_rules.each do |rule|
  lhs = rule[0].as(Item)
  op_declare = rule[1].as(Item)
  alternatives = rule[2].as(Array(RecArray))

  case op_declare[0]
  when "~"
    alternatives.each do |alternative|
      rhs = [] of String | Regex
      alternative = alternative.as(Array(RecArray))

      alternative.each do |item|
        item = item.as(Item)

        case item[1]
        when 25, 26 # Symbol => <elements>
          if !tokens.has_key?(item[0])
            raise "Can't evaluate yet: #{item[0]}"
          end

          rhs << tokens[item[0]]
        when 27 # Literal => 'string'
          rhs << Regex.escape(item[0][1..-2])
        when 28 # Character class => [\s]
          rhs << item[0]
        else
          raise "Unidentifiable LHS type for : #{lhs[0]}"
        end
      end

      regex = /#{rhs.join("")}/

      if tokens[lhs[0]]?
        tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
      else
        tokens[lhs[0]] = regex
      end
    end
  when "::="
    alternatives.each do |alternative|
      rhs = [] of Int32
      alternative = alternative.as(Array(RecArray))
      alternative.each do |item|
        item = item.as(Item)

        case item[1]
        when 25, 26 # Symbol name
          rhs << symbols.key(item[0])
        when 27 # Catch literals
          literal_id = LibMarpa.marpa_g_symbol_new(grammar)
          literal_name = item[0]

          tokens[literal_name] = Regex.new(Regex.escape(item[0][1..-2]))
          symbols[literal_id] = literal_name
          rhs << symbols.key(literal_name)
        when 28 # Catch regex
          character_id = LibMarpa.marpa_g_symbol_new(grammar)
          character_name = item[0]

          tokens[character_name] = Regex.new(item[0])
          symbols[character_id] = character_name
          rhs << symbols.key(character_name)
        else
          raise "Unidentifiable LHS type for : #{lhs[0]}"
        end
      end

      status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs[0]), rhs, rhs.size)
      if status < 0
        raise "Error generating rule #{lhs[0]} : #{rhs.map { |a| symbols[a] }}"
      end
    end
  end
end

input = build_bnf

LibMarpa.marpa_g_precompute(grammar)
recce = LibMarpa.marpa_r_new(grammar)
LibMarpa.marpa_r_start_input(recce)

row = 0
col = 0

buffer = uninitialized Int32[128]
size = LibMarpa.marpa_r_terminals_expected(recce, buffer)
slice = buffer.to_slice[0, size]

msg = "Unexpected symbol at line #{row}, character #{col}, expected:\n"

expected = [] of String
slice.each do |id|
  expected << symbols[id]
  msg += symbols[id] + "\n"
end
puts expected

raise msg
