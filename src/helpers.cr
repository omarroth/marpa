def build_marpa(input, grammar, discard, lexemes, symbols, rule_names)
  recce = LibMarpa.marpa_r_new(grammar)
  LibMarpa.marpa_r_start_input(recce)

  p_error_string = uninitialized String

  tokens = {} of Int32 => String
  position = 0

  until position == input.size
    col = position - (input[0..position].rindex("\n") || 0) + 1
    row = input[0..position].count("\n") + 1

    buffer = uninitialized Int32[128]
    size = LibMarpa.marpa_r_terminals_expected(recce, buffer)

    slice = buffer.to_slice[0, size]
    expected = [] of String
    slice.each do |id|
      expected << symbols[id]
    end

    matches = [] of {String, String}

    # For each expected token, try to find it at current position
    expected.each do |id|
      if md = lexemes[id].match(input, position)
        if md.begin == position
          symbol = id
          match = md[0]

          matches << {symbol, match}
        end
      end
    end

    if matches.empty?
      discard.each do |id|
        if md = lexemes[id].match(input, position)
          if md.begin == position
            symbol = id
            match = md[0]

            matches << {symbol, match}
          end
        end
      end
      if matches.empty?
        error_msg = "Lexing error at #{row}, #{col}, expected: \n"
        expected.each do |id|
          error_msg += "#{id}\n"
        end

        raise error_msg
      else
        position += matches[0][1].size
        next
      end
    end

    matches.sort_by! { |a, b| b.size }.reverse!

    symbol = matches[0][0]
    match = matches[0][1]
    position += match.size

    status = LibMarpa.marpa_r_alternative(recce, symbols.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
      expected.each do |id|
        error_msg += "#{id}\n"
      end

      raise error_msg
    end

    status = LibMarpa.marpa_r_earleme_complete(recce)
    if status < 0
      e = LibMarpa.marpa_g_error(grammar, p_error_string)
      raise "Earleme complete #{e}"
    end

    tokens[position] = match
  end

  bocage = LibMarpa.marpa_b_new(recce, -1)
  if !bocage
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Bocage complete #{e}"
  end

  order = LibMarpa.marpa_o_new(bocage)
  if !order
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Order complete #{e}"
  end

  tree = LibMarpa.marpa_t_new(order)
  if !tree
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Tree complete #{e}"
  end

  tree_status = LibMarpa.marpa_t_next(tree)
  if tree_status <= -1
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Tree status #{e}"
  end

  value = LibMarpa.marpa_v_new(tree)
  if !value
    e = LibMarpa.marpa_g_error(grammar, p_error_string)
    raise "Value returned #{e}"
  end

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
      e = LibMarpa.marpa_g_error(grammar, p_error_string)
      raise "Event returned #{e}"
    when LibMarpa::MarpaStepType::MARPA_STEP_RULE
      rule = value.value

      start = rule.t_arg_0
      stop = rule.t_arg_n
      rule_id = rule.t_rule_id

      context = stack[start..stop]
      stack.delete_at(start..stop)

      case rule_names[rule_id]
      when "statements ::= statement+"
        stack = context
        break
      when "<start rule> ::= ':start' <op declare bnf> symbol"
        start_rules << context
      when "<priority rule> ::= lhs <op declare> alternatives"
        s_lhs = context[0].as(Item)
        s_op_declare = context[1].as(Item)

        if s_op_declare[0] == "::="
          g1 << s_lhs
        else
          l0 << s_lhs
        end

        priority_rules << context
      when "<quantified rule> ::= lhs <op declare> <single symbol> quantifier <adverb list>"
        s_lhs = context[0].as(Item)
        s_op_declare = context[1].as(Item)

        if s_op_declare[0] == "::="
          g1 << s_lhs
        else
          l0 << s_lhs
        end

        quantified_rules << context
      when "<discard rule> ::= ':discard' <op declare match> <single symbol>"
        discard_rules << context
      when "alternatives ::= rhs+" # s_rhs+ '|' => s_alternatives
        context.delete({"|", 24})
      when "<adverb list> ::= <adverb item>*"
      when "<proper specification> ::= 'proper =>' boolean", "<separator specification> ::= 'separator =>' <single symbol>"
        context.delete({"separator =>", 35})
      when "rhs ::= <rhs primary>+"
      when "<parenthesized rhs primary list> ::= '(' <rhs list> ')'"
        context = context[1]
      when "<symbol name ::= <bare name>", "<symbol name> ::= <bracketed name>"
        context = context[0].as(Item)
        unconfirmed << context
      else
        if context.size == 1
          context = context[0]
        end
      end

      stack << context
    when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
      token = value.value

      token_value = tokens[token.t_token_value - 1]
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
  rule_names = {} of Int32 => String

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

  discard = [] of String
  discard_rules.each do |rule|
    symbol = rule[2].as(Item)

    discard << symbol[0]
  end

  # We want to do lexical rules first
  quantified_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!
  priority_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!

  quantified_rules.each do |rule|
    lhs = rule[0].as(Item)
    op_declare = rule[1].as(Item)
    single_symbol = rule[2].as(Item)
    quantifier = rule[3].as(Item)

    rule_name = "#{lhs[0]} #{op_declare[0]} #{single_symbol[0]}#{quantifier[0]}"

    case op_declare[0]
    when "~"
      if single_symbol[1] == 26
        raise "An L0 lexeme cannot appear on the RHS of an L0 rule : #{single_symbol[0]}"
      end

      regex = /(#{single_symbol[0]}#{quantifier[0]})/

      if tokens[lhs[0]]?
        tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
      else
        tokens[lhs[0]] = regex
      end
    when "::="
      if quantifier[0] == "*"
        quantifier = 0
      else
        quantifier = 1
      end

      separator = -1
      proper = LibMarpa::MARPA_PROPER_SEPARATION

      puts rule

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

      rule_names[status] = rule_name
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
          when 27 # Symbol => <elements>
            if !tokens.has_key?(item[0])
              raise "Can't evaluate: #{item[0]}"
            end

            rhs << tokens[item[0]]
          when 29 # Literal => 'string'
            rhs << Regex.escape(item[0][1..-2])
          when 31 # Character class => [\s]
            rhs << item[0]
          else
            raise "Unidentifiable LHS type for : #{lhs[0]}"
          end
        end

        regex = /(#{rhs.join("")})/

        if tokens[lhs[0]]?
          tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
        else
          tokens[lhs[0]] = regex
        end
      end
    when "::="
      alternatives.each do |alternative|
        rhs = [] of Int32
        puts alternative

        alternative = alternative.as(Array(RecArray))
        alternative = alternative.flatten

        rule_name = "#{lhs[0]} #{op_declare[0]} #{alternative.map { |a, b| a }.join(" ")}"

        alternative.each do |item|
          item = item.as(Item)

          case symbols[item[1]]
          when "<bare name>", "<bracketed name>" # Symbol name
            rhs << symbols.key(item[0])
          when "<single quoted string>" # Catch literals
            literal_name = item[0]

            # Create literal if it hasn't already been created
            if !tokens.has_key?(literal_name)
              literal_id = LibMarpa.marpa_g_symbol_new(grammar)

              tokens[literal_name] = /(#{Regex.escape(literal_name[1..-2])})/
              symbols[literal_id] = literal_name
            end

            rhs << symbols.key(literal_name)
          when "<character class>" # Catch regex
            character_name = item[0]

            if !tokens.has_key?(character_name)
              character_id = LibMarpa.marpa_g_symbol_new(grammar)

              tokens[character_name] = /(#{character_name})/
              symbols[character_id] = character_name
            end

            rhs << symbols.key(character_name)
          else
            raise "Unidentifiable LHS type for : #{lhs[0]}"
          end
        end

        status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs[0]), rhs, rhs.size)
        if status < 0
          raise "Error generating rule #{lhs[0]} : #{rhs.map { |a| symbols[a] }}"
        end

        rule_names[status] = rule_name
      end
    end
  end

  return grammar, tokens, symbols, rule_names

  # LibMarpa.marpa_g_precompute(grammar)
  # recce = LibMarpa.marpa_r_new(grammar)
  # LibMarpa.marpa_r_start_input(recce)

  # token_values = {} of Int32 => String
  # position = 0

  # until position == input.size
  #   col = position - (input[0..position].rindex("\n") || 0) + 1
  #   row = input[0..position].count("\n") + 1

  #   buffer = uninitialized Int32[128]
  #   size = LibMarpa.marpa_r_terminals_expected(recce, buffer)

  #   slice = buffer.to_slice[0, size]
  #   expected = [] of String
  #   slice.each do |id|
  #     expected << symbols[id]
  #   end

  #   matches = [] of {String, String}

  #   # For each expected token, try to find it at current position
  #   expected.each do |id|
  #     if md = tokens[id].match(input, position)
  #       if md.begin == position
  #         symbol = id
  #         match = md[0]

  #         matches << {symbol, match}
  #       end
  #     end
  #   end

  #   if matches.empty?
  #     discard.each do |id|
  #       if md = tokens[id].match(input, position)
  #         if md.begin == position
  #           symbol = id
  #           match = md[0]

  #           matches << {symbol, match}
  #         end
  #       end
  #     end
  #     if matches.empty?
  #       error_msg = "Lexing error at #{row}, #{col}, expected: \n"
  #       expected.each do |id|
  #         error_msg += "#{id}\n"
  #       end

  #       raise error_msg
  #     else
  #       position += matches[0][1].size
  #       next
  #     end
  #   end

  #   matches.sort_by! { |a, b| b.size }.reverse!

  #   symbol = matches[0][0]
  #   match = matches[0][1]
  #   position += match.size

  #   status = LibMarpa.marpa_r_alternative(recce, symbols.key(symbol), position + 1, 1)

  #   if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
  #     error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
  #     expected.each do |id|
  #       error_msg += "#{id}\n"
  #     end

  #     raise error_msg
  #   end

  #   status = LibMarpa.marpa_r_earleme_complete(recce)
  #   if status < 0
  #     e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #     raise "Earleme complete #{e}"
  #   end

  #   token_values[position] = match
  # end

  # bocage = LibMarpa.marpa_b_new(recce, -1)
  # if !bocage
  #   e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #   raise "Bocage complete #{e}"
  # end

  # order = LibMarpa.marpa_o_new(bocage)
  # if !order
  #   e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #   raise "Order complete #{e}"
  # end

  # tree = LibMarpa.marpa_t_new(order)
  # if !tree
  #   e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #   raise "Tree complete #{e}"
  # end

  # tree_status = LibMarpa.marpa_t_next(tree)
  # if tree_status <= -1
  #   e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #   raise "Tree status #{e}"
  # end

  #   value = LibMarpa.marpa_v_new(tree)
  #   if !value
  #     e = LibMarpa.marpa_g_error(grammar, p_error_string)
  #     raise "Value returned #{e}"
  #   end
end

#       status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs[0]), rhs, rhs.size)
#       if status < 0
#         raise "Error generating rule #{lhs[0]} : #{rhs.map { |a| symbols[a] }}"
#       end

#       rule_names[status] = rule_name
#     end
#   symbols = {} of Int32 => String
#   tokens = {} of String => Regex
#   rule_names = {} of Int32 => String

#   configuration = uninitialized LibMarpa::MarpaConfig
#   LibMarpa.marpa_c_init(pointerof(configuration))

#   grammar = LibMarpa.marpa_g_new(pointerof(configuration))
#   LibMarpa.marpa_g_force_valued(grammar)

#   # Create symbols
#   (g1 + l0).each do |symbol|
#     id = LibMarpa.marpa_g_symbol_new(grammar)
#     value = symbol[0].as(String)

#     symbols[id] = value
#   end

#   start_rules.each do |rule|
#     symbol = rule[2].as(Item)

#     LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(symbol[0]))
#   end

#   discard = [] of String
#   discard_rules.each do |rule|
#     symbol = rule[2].as(Item)

#     discard << symbol[0]
#   end

#   # We want to do lexical rules first
#   quantified_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!
#   priority_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!

#   quantified_rules.each do |rule|
#     lhs = rule[0].as(Item)
#     op_declare = rule[1].as(Item)
#     single_symbol = rule[2].as(Item)
#     quantifier = rule[3].as(Item)

#     rule_name = "#{lhs[0]} #{op_declare[0]} #{single_symbol[0]}#{quantifier[0]}"

#     case op_declare[0]
#     when "~"
#       if single_symbol[1] == 26
#         raise "An L0 lexeme cannot appear on the RHS of an L0 rule : #{single_symbol[0]}"
#       end

#       regex = /(#{single_symbol[0]}#{quantifier[0]})/

#       if tokens[lhs[0]]?
#         tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
#       else
#         tokens[lhs[0]] = regex
#       end
#     when "::="
#       if quantifier[0] == "*"
#         quantifier = 0
#       else
#         quantifier = 1
#       end

#       separator = -1
#       proper = LibMarpa::MARPA_PROPER_SEPARATION

#       adverb_list = rule[4]?.try &.as(Array)
#       adverb_list ||= [] of RecArray
#       adverb_list.each do |adverb|
#         key = adverb[0].as(Item)
#         value = adverb[1].as(Item)

#         case key[0]
#         when "proper"
#           if value[0] == 0
#             proper = LibMarpa::MARPA_KEEP_SEPARATION
#           end
#         when "separator"
#           separator = symbols.key(value[0])
#         end
#       end

#       status = LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs[0]), symbols.key(single_symbol[0]), separator, quantifier, proper)
#       if status < 0
#         raise "Unable to create sequence for #{lhs[0]}"
#       end

#       rule_names[status] = rule_name
#     end
#   end

#   priority_rules.each do |rule|
#     lhs = rule[0].as(Item)
#     op_declare = rule[1].as(Item)
#     alternatives = rule[2].as(Array(RecArray))

#     case op_declare[0]
#     when "~"
#       alternatives.each do |alternative|
#         rhs = [] of String | Regex
#         alternative = alternative.as(Array(RecArray))

#         alternative.each do |item|
#           item = item.as(Item)

#           case item[1]
#           when 25, 26 # Symbol => <elements>
#             if !tokens.has_key?(item[0])
#               raise "Can't evaluate: #{item[0]}"
#             end

#             rhs << tokens[item[0]]
#           when 27 # Literal => 'string'
#             rhs << Regex.escape(item[0][1..-2])
#           when 28 # Character class => [\s]
#             rhs << item[0]
#           else
#             raise "Unidentifiable LHS type for : #{lhs[0]}"
#           end
#         end

#         regex = /(#{rhs.join("")})/

#         if tokens[lhs[0]]?
#           tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
#         else
#           tokens[lhs[0]] = regex
#         end
#       end
#     when "::="
#       alternatives.each do |alternative|
#         rhs = [] of Int32
#         alternative = alternative.as(Array(RecArray))
#         alternative = alternative.flatten

#         rule_name = "#{lhs[0]} #{op_declare[0]} #{alternative.map { |a, b| a }.join(" ")}"

#         alternative.each do |item|
#           item = item.as(Item)

#           case item[1]
#           when 25, 26 # Symbol name
#             rhs << symbols.key(item[0])
#           when 27 # Catch literals
#             literal_name = item[0]

#             # Create literal if it hasn't already been created
#             if !tokens.has_key?(literal_name)
#               literal_id = LibMarpa.marpa_g_symbol_new(grammar)

#               tokens[literal_name] = /(#{Regex.escape(literal_name[1..-2])})/
#               symbols[literal_id] = literal_name
#             end

#             rhs << symbols.key(literal_name)
#           when 28 # Catch regex
#             character_name = item[0]

#             if !tokens.has_key?(character_name)
#               character_id = LibMarpa.marpa_g_symbol_new(grammar)

#               tokens[character_name] = /(#{character_name})/
#               symbols[character_id] = character_name
#             end

#             rhs << symbols.key(character_name)
#           else
#             raise "Unidentifiable LHS type for : #{lhs[0]}"
#           end
#         end

#         status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs[0]), rhs, rhs.size)
#         if status < 0
#           raise "Error generating rule #{lhs[0]} : #{rhs.map { |a| symbols[a] }}"
#         end

#         rule_names[status] = rule_name
#       end
#     end
#   end

#   input = build_bnf

#   LibMarpa.marpa_g_precompute(grammar)
#   recce = LibMarpa.marpa_r_new(grammar)
#   LibMarpa.marpa_r_start_input(recce)

#   token_values = {} of Int32 => String
#   position = 0

#   until position == input.size
#     col = position - (input[0..position].rindex("\n") || 0) + 1
#     row = input[0..position].count("\n") + 1

#     buffer = uninitialized Int32[128]
#     size = LibMarpa.marpa_r_terminals_expected(recce, buffer)

#     slice = buffer.to_slice[0, size]
#     expected = [] of String
#     slice.each do |id|
#       expected << symbols[id]
#     end

#     matches = [] of {String, String}

#     # For each expected token, try to find it at current position
#     expected.each do |id|
#       if md = tokens[id].match(input, position)
#         if md.begin == position
#           symbol = id
#           match = md[0]

#           matches << {symbol, match}
#         end
#       end
#     end

#     if matches.empty?
#       discard.each do |id|
#         if md = tokens[id].match(input, position)
#           if md.begin == position
#             symbol = id
#             match = md[0]

#             matches << {symbol, match}
#           end
#         end
#       end
#       if matches.empty?
#         error_msg = "Lexing error at #{row}, #{col}, expected: \n"
#         expected.each do |id|
#           error_msg += "#{id}\n"
#         end

#         raise error_msg
#       else
#         position += matches[0][1].size
#         next
#       end
#     end

#     matches.sort_by! { |a, b| b.size }.reverse!

#     symbol = matches[0][0]
#     match = matches[0][1]
#     position += match.size

#     status = LibMarpa.marpa_r_alternative(recce, symbols.key(symbol), position + 1, 1)

#     if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
#       error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
#       expected.each do |id|
#         error_msg += "#{id}\n"
#       end

#       raise error_msg
#     end

#     status = LibMarpa.marpa_r_earleme_complete(recce)
#     if status < 0
#       e = LibMarpa.marpa_g_error(grammar, p_error_string)
#       raise "Earleme complete #{e}"
#     end

#     token_values[position] = match
#   end

#   bocage = LibMarpa.marpa_b_new(recce, -1)
#   if !bocage
#     e = LibMarpa.marpa_g_error(grammar, p_error_string)
#     raise "Bocage complete #{e}"
#   end

#   order = LibMarpa.marpa_o_new(bocage)
#   if !order
#     e = LibMarpa.marpa_g_error(grammar, p_error_string)
#     raise "Order complete #{e}"
#   end

#   tree = LibMarpa.marpa_t_new(order)
#   if !tree
#     e = LibMarpa.marpa_g_error(grammar, p_error_string)
#     raise "Tree complete #{e}"
#   end

#   tree_status = LibMarpa.marpa_t_next(tree)
#   if tree_status <= -1
#     e = LibMarpa.marpa_g_error(grammar, p_error_string)
#     raise "Tree status #{e}"
#   end

#   valuator = LibMarpa.marpa_v_new(tree)
#   if !valuator
#     e = LibMarpa.marpa_g_error(grammar, p_error_string)
#     raise "Valuator returned #{e}"
#   end

#   stack = [] of RecArray
#   context = [] of RecArray
#   l0 = [] of RecArray
#   g1 = [] of RecArray
#   unconfirmed = [] of Item

#   start_rules = [] of Array(RecArray)
#   priority_rules = [] of Array(RecArray)
#   quantified_rules = [] of Array(RecArray)
#   discard_rules = [] of Array(RecArray)

#   loop do
#     step_type = LibMarpa.marpa_v_step(valuator)

#     case step_type
#     when step_type.value < 0
#       e = LibMarpa.marpa_g_error(build_grammar, p_error_string)
#       raise "Event returned #{e}"
#     when LibMarpa::MarpaStepType::MARPA_STEP_RULE
#       rule = valuator.value

#       start = rule.t_arg_0
#       stop = rule.t_arg_n
#       rule_id = rule.t_rule_id

#       context = stack[start..stop]
#       stack.delete_at(start..stop)

#       case rule_names[rule_id]
#       when "statements ::= statement+"
#         stack = context
#         break
#       when "<start rule> ::= ':start' <op declare bnf> symbol"
#         start_rules << context
#       when "<priority rule> ::= lhs <op declare> alternatives"
#         s_lhs = context[0].as(Item)
#         s_op_declare = context[1].as(Item)

#         if s_op_declare[0] == "::="
#           g1 << s_lhs
#         else
#           l0 << s_lhs
#         end

#         priority_rules << context
#       when "<quantified rule> ::= lhs <op declare> <single symbol> quantifier <adverb list>"
#         s_lhs = context[0].as(Item)
#         s_op_declare = context[1].as(Item)

#         if s_op_declare[0] == "::="
#           g1 << s_lhs
#         else
#           l0 << s_lhs
#         end

#         quantified_rules << context
#       when "<discard rule> ::= ':discard' <op declare match> <single symbol>"
#         discard_rules << context
#       when "alternatives ::= rhs+" # s_rhs+ '|' => s_alternatives
#         context.delete({"|", 22})
#       when "<adverb list> ::= <adverb item>*"
#       when "<proper specification> ::= 'proper =>' boolean", "<separator specification> ::= 'separator =>' <single symbol>"
#         context.delete({"=>", 33})
#       when "rhs ::= <rhs primary>+"
#       when "<parenthesized rhs primary list> ::= '(' <rhs list> ')'"
#         context = context[1]
#       when "<symbol name ::= <bare name>", "<symbol name> ::= <bracketed name>"
#         context = context[0].as(Item)
#         unconfirmed << context
#       else
#         if context.size == 1
#           context = context[0]
#         end
#       end

#       stack << context
#     when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
#       token = valuator.value

#       token_value = token_values[token.t_token_value - 1]
#       token_id = token.t_token_id

#       stack << {token_value, token_id}
#     when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
#       symbol = valuator.value
#     when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
#       break
#     when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
#     end
#   end

#   l0.uniq!
#   g1.uniq!

#   unconfirmed = unconfirmed - l0 - g1
#   if unconfirmed.size > 0
#     symbols = unconfirmed.map { |a, b| a }.join(", ")
#     raise "Undefined symbols: #{symbols}"
#   end

#   symbols = {} of Int32 => String
#   tokens = {} of String => Regex
#   rule_names = {} of Int32 => String

#   configuration, grammar = build_marpa

#   # Create symbols
#   (g1 + l0).each do |symbol|
#     id = LibMarpa.marpa_g_symbol_new(grammar)
#     value = symbol[0].as(String)

#     symbols[id] = value
#   end

#   start_rules.each do |rule|
#     symbol = rule[2].as(Item)

#     LibMarpa.marpa_g_start_symbol_set(grammar, symbols.key(symbol[0]))
#   end

#   discard = [] of String
#   discard_rules.each do |rule|
#     symbol = rule[2].as(Item)

#     discard << symbol[0]
#   end

#   # We want to do lexical rules first
#   quantified_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!
#   priority_rules.sort_by! { |a| a[1].as(Item)[1] }.reverse!

#   quantified_rules.each do |rule|
#     lhs = rule[0].as(Item)
#     op_declare = rule[1].as(Item)
#     single_symbol = rule[2].as(Item)
#     quantifier = rule[3].as(Item)

#     rule_name = "#{lhs[0]} #{op_declare[0]} #{single_symbol[0]}#{quantifier[0]}"

#     case op_declare[0]
#     when "~"
#       if single_symbol[1] == 26
#         raise "An L0 lexeme cannot appear on the RHS of an L0 rule : #{single_symbol[0]}"
#       end

#       regex = /(#{single_symbol[0]}#{quantifier[0]})/

#       if tokens[lhs[0]]?
#         tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
#       else
#         tokens[lhs[0]] = regex
#       end
#     when "::="
#       if quantifier[0] == "*"
#         quantifier = 0
#       else
#         quantifier = 1
#       end

#       separator = -1
#       proper = LibMarpa::MARPA_PROPER_SEPARATION

#       adverb_list = rule[4]?.try &.as(Array)
#       adverb_list ||= [] of RecArray
#       adverb_list.each do |adverb|
#         key = adverb[0].as(Item)
#         value = adverb[1].as(Item)

#         case key[0]
#         when "proper"
#           if value[0] == 0
#             proper = LibMarpa::MARPA_KEEP_SEPARATION
#           end
#         when "separator"
#           separator = symbols.key(value[0])
#         end
#       end

#       status = LibMarpa.marpa_g_sequence_new(grammar, symbols.key(lhs[0]), symbols.key(single_symbol[0]), separator, quantifier, proper)
#       if status < 0
#         raise "Unable to create sequence for #{lhs[0]}"
#       end

#       rule_names[status] = rule_name
#     end
#   end

#   priority_rules.each do |rule|
#     lhs = rule[0].as(Item)
#     op_declare = rule[1].as(Item)
#     alternatives = rule[2].as(Array(RecArray))

#     case op_declare[0]
#     when "~"
#       alternatives.each do |alternative|
#         rhs = [] of String | Regex
#         alternative = alternative.as(Array(RecArray))

#         alternative.each do |item|
#           item = item.as(Item)

#           case item[1]
#           when 25, 26 # Symbol => <elements>
#             if !tokens.has_key?(item[0])
#               raise "Can't evaluate: #{item[0]}"
#             end

#             rhs << tokens[item[0]]
#           when 27 # Literal => 'string'
#             rhs << Regex.escape(item[0][1..-2])
#           when 28 # Character class => [\s]
#             rhs << item[0]
#           else
#             raise "Unidentifiable LHS type for : #{lhs[0]}"
#           end
#         end

#         regex = /(#{rhs.join("")})/

#         if tokens[lhs[0]]?
#           tokens[lhs[0]] = Regex.union(tokens[lhs[0]], regex)
#         else
#           tokens[lhs[0]] = regex
#         end
#       end
#     when "::="
#       alternatives.each do |alternative|
#         rhs = [] of Int32
#         alternative = alternative.as(Array(RecArray))
#         alternative = alternative.flatten

#         rule_name = "#{lhs[0]} #{op_declare[0]} #{alternative.map { |a, b| a }.join(" ")}"

#         alternative.each do |item|
#           item = item.as(Item)

#           case item[1]
#           when 25, 26 # Symbol name
#             rhs << symbols.key(item[0])
#           when 27 # Catch literals
#             literal_name = item[0]

#             # Create literal if it hasn't already been created
#             if !tokens.has_key?(literal_name)
#               literal_id = LibMarpa.marpa_g_symbol_new(grammar)

#               tokens[literal_name] = /(#{Regex.escape(literal_name[1..-2])})/
#               symbols[literal_id] = literal_name
#             end

#             rhs << symbols.key(literal_name)
#           when 28 # Catch regex
#             character_name = item[0]

#             if !tokens.has_key?(character_name)
#               character_id = LibMarpa.marpa_g_symbol_new(grammar)

#               tokens[character_name] = /(#{character_name})/
#               symbols[character_id] = character_name
#             end

#             rhs << symbols.key(character_name)
#           else
#             raise "Unidentifiable LHS type for : #{lhs[0]}"
#           end
#         end

#         status = LibMarpa.marpa_g_rule_new(grammar, symbols.key(lhs[0]), rhs, rhs.size)
#         if status < 0
#           raise "Error generating rule #{lhs[0]} : #{rhs.map { |a| symbols[a] }}"
#         end

#         rule_names[status] = rule_name
#       end
#     end
#   end
# end
