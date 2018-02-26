require "./bnf_new"

# input = File.read("src/bnf/metag.ebnf")
# input = File.read("src/bnf/numbers.ebnf")
input = File.read("src/bnf/minimal.ebnf")

configuration = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(configuration))

grammar = LibMarpa.marpa_g_new(pointerof(configuration))
LibMarpa.marpa_g_force_valued(grammar)

g, value, values, types = parse_bnf(input)

alias RecArray = String | Array(RecArray)

stack = [] of RecArray
symbols = {} of Int32 => String
tokens = {} of String => String
discard = [] of String

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
    when 0 # start_rule => statement -- DONE?
      context = context[0]
    when 1 # priority_rule => statement -- DONE?
      context = context[0]
    when 2 # quantified_rule => statement -- DONE?
      context = context[0]
    when 3 # discard_rule => statement -- DONE?
      context = context[0]
    when 4 # symbol_name => lhs -- DONE
      context = context[0]
    when 5 # single_symbol => rhs_primary -- DONE
      context = context[0]
    when 6 # single_quoted_string => rhs_primary -- DONE
      single_quoted_string = context[0].as(String)
      single_quoted_string = single_quoted_string[1..-2]
      single_quoted_string = Regex.escape(single_quoted_string)

      if tokens[single_quoted_string]?
        literal = tokens[single_quoted_string]
      else
        id = LibMarpa.marpa_g_symbol_new(grammar)
        literal = "__literal_" + id.to_s

        symbols[id] = literal
        tokens[single_quoted_string] = literal
      end

      context = literal
    when 7 # parenthesized_rhs_primary_list => rhs_primary -- DONE
      context = context[0]
    when 8 # separator_spec => adverb_item -- DONE
      context = context[0]
    when 9 # proper_spec => adverb_item -- DONE
      context = context[0]
    when 10 # symbol => single_symbol -- DONE
      context = context[0]
    when 11 # character_class => single_symbol -- DONE
      character_class = context[0].as(String)

      if tokens[character_class]?
        literal = tokens[character_class]
      else
        id = LibMarpa.marpa_g_symbol_new(grammar)
        literal = "__literal_" + id.to_s

        symbols[id] = literal
        tokens[character_class] = literal
      end

      context = literal
    when 12 # symbol_name => symbol -- DONE
      context = context[0]
    when 13 # bare_name => symbol_name -- DONE
      symbol_name = context[0].as(String)
      symbol_name = "__" + symbol_name

      if !symbols.key?(symbol_name)
        id = LibMarpa.marpa_g_symbol_new(grammar)
        symbols[id] = symbol_name
      end

      context = symbol_name
    when 14 # bracketed_name => symbol_name -- DONE
      symbol_name = context[0].as(String)
      symbol_name = symbol_name[1..-2]
      symbol_name = symbol_name.gsub(" ", "_")
      symbol_name = "__" + symbol_name

      if !symbols.key?(symbol_name)
        id = LibMarpa.marpa_g_symbol_new(grammar)
        symbols[id] = symbol_name
      end

      context = symbol_name
    when 15 # op_declare_bnf => op_declare -- DONE
      context = context[0]
    when 16 # op_declare_match => op_declare -- DONE
      context = context[0]
    when 17 # start_colon, op_declare_bnf, symbol => start_rule -- DONE
      symbol = context[2].as(String)
      LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(symbol))
    when 18 # lhs, op_declare, alternatives => priority_rule
      lhs = context[0].as(String)
      op_declare = context[1].as(String)
      alternatives = context[2].as(Array)

      alternatives.each do |alternative|
        alternative = alternative.as(Array)
        alternative = alternative.flatten

        rhs = [] of Int32

        alternative.each do |rhs_symbol|
          rhs << symbols.key(rhs_symbol)
        end

        LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs), rhs, rhs.size)
      end
    when 19 # discard_colon, op_declare_match, single_symbol => discard_rule -- DONE
      single_symbol = context[2].as(String)
      discard << single_symbol
    when 20 # separator_string, arrow, single_symbol => separator_spec -- DONE
      context.delete_at(1)
    when 21 # proper_string, arrow, boolean, proper_spec -- DONE
      context.delete_at(1)
    when 22 # left_paren, rhs_primary_list, right_paren => parenthesized_rhs_primary_list -- DONE
      context = context[1]
    when 23 # lhs, op_declare, single_symbol, quantifier, adverb_list => quantified_rule -- DONE
      lhs = context[0].as(String)
      op_declare = context[1].as(String)
      single_symbol = context[2].as(String)
      quantifier = context[3].as(String)

      adverb_list = [] of RecArray
      if context[4]?
        adverb_list = context[4].as(Array(RecArray))
      end

      separator = -1
      proper = LibMarpa::MARPA_PROPER_SEPARATION
      adverb_list.each do |item|
        if item[0] == "proper"
          if item[1] == "0"
            proper = LibMarpa::MARPA_KEEP_SEPARATION
          end
        elsif item[0] == "separator"
          separator = symbols.key(item[1])
        end
      end

      if op_declare == "~"
        tokens[single_symbol + quantifier] = lhs
      else
        if quantifier == "*"
          quantifier = 0
        else
          quantifier = 1
        end

        # if discard.includes?(lhs)
        #   discard << single_symbol
        # end
        LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs), symbols.key(single_symbol), separator, quantifier, proper)
      end
    when 24 # adverb_item* => adverb_list -- DONE
    when 25 # rhs+ => alternatives, separator => "|" -- DONE?
      rhs = context.as(Array)
      rhs.delete("|")
      context = rhs
    when 26 # rhs_primary+ => rhs -- DONE?
    when 27 # rhs_primary+ => rhs_primary_list -- DONE?
    when 28 # statement+ => statements -- DONE
    end

    stack << context
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    token = value.value

    token_value = values[token.t_token_value - 1]

    stack << token_value
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
  end
end

LibMarpa.marpa_g_precompute(grammar)

recce = LibMarpa.marpa_r_new(grammar)
LibMarpa.marpa_r_start_input(recce)

tokens["."] = "__mismatch"
token_regex = Regex.union(tokens.map { |value, name| /(?<#{name}>#{value})/ })

token_values = {} of Int32 => String

input.scan(token_regex) do |match|
  position = match.begin || 0
  symbol = match.to_h.compact.to_a[1][0]
  value = match.to_h.compact.to_a[1][1]

  # col = input[0..position][/.+$/].size + 1
  # col = input[0..position][/.+/].size
  # puts col
  # puts position
  # col = input[0..position][-1, '\n'].size
  col = 1
  row = input[0..position].count("\n") + 1
  # puts row

  if discard.includes?(symbol)
  elsif symbol == "mismatch"
    raise "Lexing error at #{row}, #{col}"
  else
    status = LibMarpa.marpa_r_alternative(recce, symbols.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      buffer = uninitialized Int32[128]
      size = LibMarpa.marpa_r_terminals_expected(recce, buffer)
      slice = buffer.to_slice[0, size]

      puts symbol
      msg = "Unexpected symbol at line #{row}, character #{col}, expected:\n"
      slice.each do |id|
        msg += symbols[id] + "\n"
      end

      raise msg
    end

    status = LibMarpa.marpa_r_earleme_complete(recce)
    if status < 0
      e = LibMarpa.marpa_g_error(grammar, out p_error_string)
      raise "Earleme complete #{e}"
    end

    token_values[position] = value
  end
end

# pp symbols

# puts discard
