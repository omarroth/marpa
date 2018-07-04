require "./marpa/*"

module Marpa
  class Parser
    property grammar
    property recce
    property symbols
    property lexemes
    property rules
    property lexer
    property discard
    property discards
    property input
    property position
    property expected
    property matches
    property values

    def initialize
      @grammar = uninitialized LibMarpa::MarpaGrammar
      @recce = uninitialized LibMarpa::MarpaRecognizer

      @symbols = {} of String => Int32
      @lexemes = {} of Int32 => Hash(String, String)
      @rules = {} of Int32 => Hash(String, String)

      @lexer = {} of String => Regex
      @discard = [] of String

      @input = ""

      @position = 0
      @expected = [] of String
      @matches = [] of {String, String}
      @discards = [] of {String, String}
      @values = {} of Int32 => String
    end

    # Convenience method to expose internals of grammar, lexer, symbols, rules, etc.
    # Accepts `grammar` as BNF, and returns a builder object that can be used the same
    # as before:
    # ```
    # parser = Marpa::Parser.new
    # grammar = <<-'END_BNF'
    # :start ::= A
    # A ::= a
    # a ~ 'a'
    # END_BNF
    # input = "a"
    # grammar = parser.compile(grammar)
    # parser.parse(input, grammar) # => ["a"]
    # ```
    def compile(grammar : String)
      meta_grammar = Builder.new
      meta_grammar = build_meta_grammar(meta_grammar)

      builder = Builder.new
      parse(grammar, meta_grammar, builder)

      return builder
    end

    # Parse `input` given `grammar` in BNF format.
    # Accepts optional `actions` that can be used to perform semantics
    # on given rules.
    # On successful parse, returns the parse tree
    def parse(input : String, grammar : String, actions : Actions = Actions.new, events : Events = Events.new)
      meta_grammar = Builder.new
      meta_grammar = build_meta_grammar(meta_grammar)

      builder = Builder.new
      parse(grammar, meta_grammar, builder)

      return parse(input, builder, actions, events)
    end

    # Internal method used to parse the given input given computed grammar,
    # Notated here as `builder`
    def parse(input : String, builder : Builder, actions : Actions = Actions.new, events : Events = Events.new)
      @grammar = builder.grammar

      @symbols = builder.symbols
      @lexemes = builder.lexemes
      @rules = builder.rules

      @lexer = builder.lexer
      @discard = builder.discard
      @input = input

      encountered = @lexer.keys.map { |symbol| @symbols[symbol] }
      encountered += @rules.map { |k, v| @symbols[v["lhs"]] }
      encountered = @symbols.values - encountered

      if encountered.size > 0
        encountered = encountered.map { |id| @symbols.key_for(id) }
        error_msg = "Symbols not defined:\n"

        encountered.each do |id|
          error_msg += "    #{id}\n"
        end

        raise error_msg
      end

      p_error_string = String.new
      LibMarpa.marpa_g_error_clear(@grammar)
      LibMarpa.marpa_g_precompute(@grammar)
      status = LibMarpa.marpa_g_error(@grammar, p_error_string)
      if status.value > 0
        raise "Precomputing grammar produced #{status}"
      end
      @recce = LibMarpa.marpa_r_new(@grammar)
      LibMarpa.marpa_r_start_input(@recce)

      @position = 0
      @values = {} of Int32 => String
      buffer = StaticArray(Int32, 128).new(0_u8)
      event = uninitialized LibMarpa::MarpaEvent
      until @position == @input.size
        size = LibMarpa.marpa_r_terminals_expected(@recce, buffer.to_unsafe)

        if size == 0
          raise "Parse exhausted after #{@position} characters"
        end

        slice = buffer.to_slice[0, size]
        @expected = [] of String
        slice.each do |id|
          @expected << @symbols.key_for(id)
        end

        @matches = [] of {String, String}
        @expected.each do |terminal|
          md = @lexer[terminal].match(@input, @position)
          if md && md.begin == @position
            @matches << {md[0], terminal}
          end
        end

        @discards = [] of {String, String}
        if @matches.empty?
          @discard.each do |terminal|
            md = @input.match(@lexer[terminal], @position)
            if md && md.begin == @position
              @discards << {md[0], terminal}
            end
          end
        end

        # Perform default rule
        events.call("default", self)

        event_count = LibMarpa.marpa_g_event_count(@grammar)
        if event_count > 0
          event_count.times do |i|
            event_type = LibMarpa.marpa_g_event(@grammar, pointerof(event), i)
            value = event.t_value

            case event_type
            when LibMarpa::MarpaEventType::MARPA_EVENT_SYMBOL_COMPLETED
              event_name = @lexemes[value]["completion"]
            when LibMarpa::MarpaEventType::MARPA_EVENT_SYMBOL_PREDICTED
              event_name = @lexemes[value]["prediction"]
            when LibMarpa::MarpaEventType::MARPA_EVENT_EARLEY_ITEM_THRESHOLD
              raise "Reached maximum number of earley items, see https://metacpan.org/pod/distribution/Marpa-R2/pod/Scanless/R.pod#too_many_earley_items"
            else
              raise "Unimplemented event: #{event_type}"
            end

            events.call(event_name, self)
          end
        end

        if @matches.empty?
          if @discards.empty?
            last_newline = @input[0..@position].rindex("\n")
            last_newline ||= 0

            col = @position - last_newline
            row = @input[0..@position].count("\n") + 1

            error_msg = "Lexing error at row #{row}, column #{col}, (position: #{@position}) here:\n"
            error_msg += @input[last_newline..@position]
            error_msg += "\n"
            error_msg += " " * Math.max(col - 1, 0)
            error_msg += "^\n"

            error_msg += "Expected: \n"
            @expected.each do |id|
              error_msg += "    #{id}\n"
            end

            raise error_msg
          else
            @discards.sort_by! { |a, b| a.size }.reverse!
            @position += @discards[0][0].size
            next
          end
        end

        @matches.sort_by! { |a, b| a.size }.reverse!
        @matches.select! { |a, b| a.size == @matches[0][0].size }
        if @matches[0][0].size > 0
          @values[@position] = @matches[0][0]
        else
          @values[-@position] = @matches[0][0]
        end

        # L0 symbols don't trigger completion events, so we do it here
        completions = @matches.select { |match| @lexemes[@symbols[match[1]]]?.try &.["completion"]? }
        completions.each do |completion|
          event_name = @lexemes[@symbols[completion[1]]]["completion"]
          events.call(event_name, self)
        end

        @matches.each do |match|
          if @matches[0][0].size > 0
            value = @position + 1
          else
            value = -@position + 1
          end

          status = LibMarpa.marpa_r_alternative(@recce, @symbols[match[1]], value, 1)

          if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
            last_newline = @input[0..@position].rindex("\n")
            last_newline ||= 0

            col = @position - last_newline
            row = @input[0..@position].count("\n") + 1

            error_msg = "Unexpected symbol at line #{row}, character #{col}, expected: \n"
            @expected.each do |id|
              error_msg += "    #{id}\n"
            end

            raise error_msg
          end
        end

        status = LibMarpa.marpa_r_earleme_complete(@recce)
        if status < 0
          error = LibMarpa.marpa_g_error(@grammar, p_error_string)
          raise "Earleme complete: #{error}"
        end

        @position += @matches[0][0].size
      end

      bocage = LibMarpa.marpa_b_new(@recce, -1)
      if !bocage
        e = LibMarpa.marpa_g_error(@grammar, p_error_string)
        raise "Bocage complete: #{e}"
      end

      order = LibMarpa.marpa_o_new(bocage)
      if !order
        e = LibMarpa.marpa_g_error(@grammar, p_error_string)
        raise "Order complete: #{e}"
      end
      LibMarpa.marpa_o_rank(order)

      tree = LibMarpa.marpa_t_new(order)
      if !tree
        e = LibMarpa.marpa_g_error(@grammar, p_error_string)
        raise "Tree complete: #{e}"
      end

      tree_status = LibMarpa.marpa_t_next(tree)
      if tree_status <= -1
        e = LibMarpa.marpa_g_error(@grammar, p_error_string)
        raise "Tree status: #{e}"
      end

      value = LibMarpa.marpa_v_new(tree)
      if !value
        e = LibMarpa.marpa_g_error(@grammar, p_error_string)
        raise "Value returned: #{e}"
      end

      stack = [] of RecArray
      loop do
        step_type = LibMarpa.marpa_v_step(value)

        case step_type
        when step_type.value < 0
          e = LibMarpa.marpa_g_error(@grammar, p_error_string)
          raise "Event returned #{e}"
        when LibMarpa::MarpaStepType::MARPA_STEP_RULE
          rule = value.value

          start = rule.t_arg_0
          stop = rule.t_arg_n
          rule_id = rule.t_rule_id

          context = stack[start..stop]
          stack.delete_at(start..stop)

          action = @rules[rule_id]["action"]?
          action ||= "default"

          context = actions.call(action, context, rule_id)

          if context
            stack << context
          else
            stack << [] of RecArray
          end
        when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
          token = value.value

          stack << @values[token.t_token_value - 1]
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
  end

  # Skeleton class for Marpa actions
  class Actions
    # Class macro that converts a name and given context to a function call to
    # a method with that name
    def call(name, context, rule_id = 0)
      {% begin %}
        {%
          ancestors = @type.ancestors
          methods = @type.methods
        %}
        {% for ancestor in ancestors %}
          {% methods = methods + ancestor.methods %}
        {% end %}
        {% methods = methods.select { |method| method.args.size > 0 && method.args[0].name == :context } %}

        case name
        {% for method in methods.select { |method| method.args.size == 1 }.map { |method| method.name }.uniq %}
        when {{method.stringify}}
          return {{method}}(context)
        {% end %}
        {% for method in methods.select { |method| method.args.size == 2 }.map { |method| method.name }.uniq %}
        when {{method.stringify}}
          return {{method}}(context, rule_id)
        {% end %}
      else
          raise %(Could not find action "#{name}")
        end
      {% end %}
    end

    def default(context)
      return context
    end
  end

  # Skeleton class for events
  class Events < Marpa::Actions
    def default(context)
    end
  end

  class Builder < Marpa::Actions
    property grammar
    property rules
    property symbols
    property lexemes
    property discard

    def initialize
      @config = uninitialized LibMarpa::MarpaConfig
      LibMarpa.marpa_c_init(pointerof(@config))

      @grammar = LibMarpa.marpa_g_new(pointerof(@config))
      LibMarpa.marpa_g_force_valued(@grammar)

      @symbols = {} of String => Int32
      @lexemes = {} of Int32 => Hash(String, String)
      @rules = {} of Int32 => Hash(String, String)

      @lexer = {} of String => Regex
      @discard = [] of String

      @tokens = {} of String => Array(Array(String))
      @elements = {} of String => Regex
    end

    def lexer
      5.times do
        if !@tokens.empty?
          @tokens.each do |key, alternatives|
            regexes = [] of Regex
            alternatives.each do |alternative|
              regex = ""
              options = Regex::Options::None

              alternative.each do |element|
                if @lexer[element]?
                  options = options | @lexer[element].options
                  regex += @lexer[element].source
                elsif @elements[element]?
                  options = options | @elements[element].options
                  regex += @elements[element].source
                else
                  regex = ""
                  break
                end
              end

              if regex != ""
                regexes << Regex.new(regex, options)
              end
            end

            if !regexes.empty?
              @lexer[key] = Regex.union(regexes)
              @tokens.delete(key)
            end
          end
        end
      end

      if !@tokens.empty?
        error_msg = "Could not form L0 rules:\n"
        @tokens.each do |key, value|
          error_msg += "    #{key}\n"
        end

        raise error_msg
      end

      return @lexer
    end

    def start_rule(context)
      symbol = context[2].as(Array)
      symbol = symbol.flatten
      symbol = symbol[0]

      symbol_id = @symbols[symbol]
      status = LibMarpa.marpa_g_start_symbol(@grammar)

      if status > -1
        puts "Previous start symbol was '#{@symbols.key_for(status)}', setting new start symbol to '#{symbol}'."
      end

      LibMarpa.marpa_g_start_symbol_set(@grammar, symbol_id)

      ""
    end

    def priority_rule(context)
      lhs = context[0].as(Array)
      lhs = lhs.flatten
      lhs = lhs[0]
      priorities = context[2].as(Array)
      rank = 0

      priorities.delete "||"
      priorities.each do |priority|
        alternatives = priority.as(Array)

        alternatives.delete "|"
        alternatives.each do |alternative|
          rhs = alternative[0].as(Array)
          rhs = rhs.flatten

          adverbs = alternative[1].as(Array)
          alternative_rank = rank

          case context[1]
          when ["::="]
            lhs_id = @symbols[lhs]

            rhs.each do |symbol|
              if @elements[symbol]?
                @tokens[symbol] = [[symbol]]

                if !@symbols[symbol]?
                  id = LibMarpa.marpa_g_symbol_new(@grammar)
                  if id < 0
                    raise "Could not create symbol ID for #{symbol}"
                  end

                  @symbols[symbol] = id
                end
              end
            end

            rhs_ids = rhs.map { |symbol| @symbols[symbol] }
            rule = {} of String => String

            adverbs.each do |adverb|
              adverb = adverb.as(Array).flatten

              case adverb[0]
              when "action"
                rule["action"] = adverb[2]
              when "rank"
                alternative_rank = adverb[2].to_i
              else
                rule[adverb[0]] = adverb[2]
              end
            end

            rule_id = LibMarpa.marpa_g_rule_new(@grammar, lhs_id, rhs_ids, rhs_ids.size)
            if rule_id < 0
              error = LibMarpa.marpa_g_error(@grammar, out p_error_string)
              raise "Unable to create rule for #{lhs}, error: #{error}"
            end

            if alternative_rank != 0
              LibMarpa.marpa_g_error_clear(@grammar)
              LibMarpa.marpa_g_rule_rank_set(@grammar, rule_id, rank)
              error = LibMarpa.marpa_g_error(@grammar, p_error_string)

              if error != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
                raise "Unable to set rank for #{lhs}, error: #{error}"
              end
            end

            rule["lhs"] = lhs
            @rules[rule_id] = rule
          when ["~"]
            if @tokens[lhs]?
              @tokens[lhs] << rhs
            else
              @tokens[lhs] = [rhs]
            end
          end
        end

        rank += 1
      end

      ""
    end

    def quantified_rule(context)
      lhs = context[0].as(Array)
      lhs = lhs.flatten
      lhs = lhs[0]

      op_declare = context[1]

      rhs = context[2].as(Array)
      rhs = rhs.flatten
      rhs = rhs[0]

      quantifier = context[3].as(Array)
      quantifier = quantifier.flatten
      quantifier = quantifier[0]

      case op_declare
      when ["::="]
        lhs_id = @symbols[lhs]
        rhs_id = @symbols[rhs]

        case quantifier
        when "+"
          min = 1
        when "*"
          min = 0
        else
          raise "Rule for #{lhs} doesn't have correct quantifier"
        end

        adverbs = context[4].as(Array)

        separator = -1
        proper = LibMarpa::MARPA_KEEP_SEPARATION
        rank = 0
        rule = {} of String => String

        adverbs.each do |adverb|
          adverb = adverb.as(Array).flatten

          case adverb[0]
          when "separator"
            symbol = adverb[2]

            if @elements[symbol]? && !@symbols[symbol]?
              @tokens[symbol] = [[symbol]]

              if !@symbols[symbol]?
                id = LibMarpa.marpa_g_symbol_new(@grammar)
                if id < 0
                  raise "Could not create symbol ID for #{symbol}"
                end

                @symbols[symbol] = id
              end
            end

            separator = @symbols[symbol]
          when "proper"
            if adverb[2] == "1"
              proper = LibMarpa::MARPA_PROPER_SEPARATION
            end
          when "action"
            rule["action"] = adverb[2]
          when "rank"
            rank = adverb[2].to_i
          else
            rule[adverb[0]] = adverb[2]
          end
        end

        rule_id = LibMarpa.marpa_g_sequence_new(@grammar, lhs_id, rhs_id, separator, min, proper)
        if rule_id < 0
          error = LibMarpa.marpa_g_error(@grammar, out p_error_string)
          raise "Unable to create sequence for #{lhs}, error: #{error}"
        end

        if rank != 0
          LibMarpa.marpa_g_error_clear(@grammar)
          LibMarpa.marpa_g_rule_rank_set(@grammar, rule_id, rank)
          error = LibMarpa.marpa_g_error(@grammar, p_error_string)

          if error != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
            raise "Unable to set rank for #{lhs}, error: #{error}"
          end
        end

        rule["lhs"] = lhs
        @rules[rule_id] = rule
      when ["~"]
        @elements[rhs] = Regex.new(rhs + quantifier)
        if @tokens[lhs]?
          @tokens[lhs] << [rhs]
        else
          @tokens[lhs] = [[rhs]]
        end
      end

      ""
    end

    def discard_rule(context)
      symbol = context[2].as(Array)
      symbol = symbol.flatten
      symbol = symbol[0]

      @discard << symbol

      ""
    end

    def empty_rule(context)
      lhs = context[0].as(Array)
      lhs = lhs.flatten
      lhs = lhs[0]
      lhs_id = @symbols[lhs]

      rule_id = LibMarpa.marpa_g_rule_new(@grammar, lhs_id, [] of Int32, 0)
      if rule_id < 0
        raise "Could not create empty rule for #{lhs}"
      end

      rule = {} of String => String
      rule["lhs"] = lhs
      @rules[rule_id] = rule

      ""
    end

    def lexeme_rule(context)
      symbol = context[2].as(Array)
      symbol = symbol.flatten
      symbol = symbol[0]
      symbol_id = @symbols[symbol]

      pause = "before"
      event = "default"
      adverbs = context[3].as(Array)
      adverbs.each do |adverb|
        adverb = adverb.as(Array).flatten

        case adverb[0]
        when "pause"
          pause = adverb[2].as(String)
        when "event"
          event = adverb[2].as(String)
        end
      end

      lexeme = @lexemes[symbol_id]?
      lexeme ||= {} of String => String

      status = 0
      case pause
      when "before"
        lexeme["prediction"] = event
        status = LibMarpa.marpa_g_symbol_is_prediction_event_set(grammar, symbol_id, 1)
      when "after"
        lexeme["completion"] = event
        status = LibMarpa.marpa_g_symbol_is_completion_event_set(grammar, symbol_id, 1)
      end

      @lexemes[symbol_id] = lexeme
      if status < 0
        raise "Error setting symbol event for symbol #{symbol}"
      end

      ""
    end

    def create_symbol(context)
      symbol = context[0].as(Array)
      symbol = symbol.flatten
      symbol = symbol[0]

      if !@symbols[symbol]?
        id = LibMarpa.marpa_g_symbol_new(@grammar)
        if id < 0
          raise "Could not create symbol ID for #{symbol}"
        end

        @symbols[symbol] = id
      end

      context
    end

    def create_literal(context)
      string = context[0].as(String)
      regex = Regex.escape(string)
      if !@tokens[string]?
        @elements[string] = Regex.new(regex[1..-2])
      end

      context
    end

    def create_character_class(context)
      character_class = context[0].as(String)
      @elements[character_class] = Regex.new(character_class)
      context
    end

    def create_regex(context)
      regex = context[0].as(String)
      body, slash, flags = regex.rpartition("/")

      body = body[1..-1]
      flags = flags.split("")

      options = Regex::Options::None
      flags.each do |flag|
        case flag
        when "i"
          options = options | Regex::Options::IGNORE_CASE
        when "m"
          options = options | Regex::Options::MULTILINE
        when "x"
          options = options | Regex::Options::EXTENDED
        end
      end

      @elements[body] = Regex.new(body, options)
      context = body

      context
    end
  end
end
