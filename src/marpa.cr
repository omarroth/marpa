require "./marpa/*"
require "./marpa/lib_marpa/*"

module Marpa
  class Parser
    # Parse input given NAIF rules.
    # See `metag_grammar` for an example of this format,
    # or [the original interface](https://metacpan.org/pod/distribution/Marpa-R2/pod/NAIF.pod) for
    # information on  which this is based.
    def parse(rules : Hash(String, Array(Rule)), input : String, tag : Bool = false)
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
        rank = rule["rank"]?.try &.as(String).to_i
        rank ||= 0

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

        if rank
          LibMarpa.marpa_g_error_clear(grammar)
          status = LibMarpa.marpa_g_rule_rank_set(grammar, status, rank)
          error = LibMarpa.marpa_g_error(grammar, p_error_string)

          if error != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
            raise "Unable to set rank for #{lhs}, error: #{error}"
          end
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
        options = Regex::Options::None

        rhs.each do |symbol|
          case symbol
          when .starts_with? "'"
            regex += Regex.escape(symbol[1..-2])
          when .starts_with? "["
            regex += symbol
          when .starts_with? "/"
            body = symbol[1..-1].rpartition("/")
            right_side = body[2]

            if right_side.includes? "i"
              options = options | Regex::Options::IGNORE_CASE
            end
            if right_side.includes? "m"
              options = options | Regex::Options::MULTILINE
            end
            if right_side.includes? "x"
              options = options | Regex::Options::EXTENDED
            end

            regex += body[0]
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

        tokens[lhs] = Regex.new(regex, options)
      end

      LibMarpa.marpa_g_error_clear(grammar)
      LibMarpa.marpa_g_precompute(grammar)
      status = LibMarpa.marpa_g_error(grammar, p_error_string)
      if status.value > 0
        raise "Precomputing grammar produced #{status}"
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

            error_msg = "Lexing error at row #{row}, column #{col}, (position: #{position}) here:\n"
            error_msg += input[last_newline..position]
            error_msg += "\n"
            error_msg += " " * Math.max(col - 1, 0)
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
            last_newline = input[0..position].rindex("\n")
            last_newline ||= 0

            col = position - last_newline
            row = input[0..position].count("\n") + 1

            error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
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
      LibMarpa.marpa_o_rank(order)

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

          if tag
            stack << "#{values[token.t_token_value]}/#{symbols[token.t_token_id]}"
          else
            stack << values[token.t_token_value]
          end
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

    # Convert the output of a succesful parse to NAIF.
    def stack_to_rules(stack)
      rules = {} of String => Array(Rule)
      rules["G1"] = [] of Rule
      rules["L0"] = [] of Rule

      stack = stack.as(Array)
      stack.each do |rule|
        rule = rule[0].as(Array)

        lhs = rule[0]
        if lhs.is_a?(Array)
          lhs = lhs.flatten
          lhs = lhs[0]
        end

        op_declare = rule[1]
        if op_declare.is_a?(Array)
          op_declare = op_declare.flatten
          op_declare = op_declare[0]
        end

        rhs = rule[2].as(Array)
        rhs = rhs.flatten
        rhs = rhs.as(Array(String))

        case lhs
        when ":start"
          rules["G1"] << {"lhs" => "[:start]", "rhs" => rhs}
        when ":discard"
          rules["L0"] << {"lhs" => "[:discard]", "rhs" => rhs}
        else
          if op_declare == "::="
            if rule[3]?
              # quantified

              quantified = Rule.new
              quantified["lhs"] = lhs
              quantified["rhs"] = rhs

              quantifier = rule[3].as(Array)
              quantifier = quantifier.flatten
              quantifier = quantifier[0]
              if quantifier == "*"
                quantified["min"] = "0"
              elsif quantifier == "+"
                quantified["min"] = "1"
              end

              adverbs = rule[4].as(Array)
              adverbs.each do |adverb|
                adverb = adverb.as(Array)
                adverb = adverb.flatten
                adverb.delete "=>"

                name = adverb[0].as(String)
                value = adverb[1].as(String)

                quantified[name] = value
              end

              rules["G1"] << quantified
            elsif rule[2].empty?
              rules["G1"] << {"lhs" => lhs, "rhs" => [] of String}
            else
              # priority

              priorities = rule[2].as(Array)
              rank = 0

              priorities.delete "||"
              priorities.each do |priority|
                alternatives = priority.as(Array)

                alternatives.delete "|"
                alternatives.each do |alternative|
                  alternative = alternative.as(Array)

                  prioritized = {"lhs" => lhs, "rhs" => alternative.flatten}
                  if rank != 0
                    prioritized["rank"] = "#{rank}"
                  end

                  rules["G1"] << prioritized
                end

                rank -= 1
              end
            end
          elsif op_declare == "~"
            if rule[3]?
              quantifier = rule[3].as(Array).flatten[0]
              rhs[0] = rhs[0] + quantifier
            end

            rules["L0"] << {"lhs" => lhs, "rhs" => rhs}
          end
        end
      end

      return rules
    end

    # Parse input given BNF rules.
    # `parse` will output the resulting parse tree, notated here
    # as 'stack'.
    # 'tag' will output each node's value and type separated by "/".
    def parse(rules : String, input : String, tag : Bool = false)
      grammar = metag_grammar
      stack = parse(grammar, rules)
      rules = stack_to_rules(stack)

      stack = parse(rules, input, tag)
      return stack
    end
  end
end
