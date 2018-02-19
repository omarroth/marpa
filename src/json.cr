config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))
LibMarpa.marpa_g_force_valued(g)

s_begin_object = LibMarpa.marpa_g_symbol_new(g)
s_end_object = LibMarpa.marpa_g_symbol_new(g)
s_begin_array = LibMarpa.marpa_g_symbol_new(g)
s_end_array = LibMarpa.marpa_g_symbol_new(g)
s_value_separator = LibMarpa.marpa_g_symbol_new(g)
s_name_separator = LibMarpa.marpa_g_symbol_new(g)
s_string = LibMarpa.marpa_g_symbol_new(g)
s_number = LibMarpa.marpa_g_symbol_new(g)
s_true = LibMarpa.marpa_g_symbol_new(g)
s_false = LibMarpa.marpa_g_symbol_new(g)
s_null = LibMarpa.marpa_g_symbol_new(g)
s_array = LibMarpa.marpa_g_symbol_new(g)
s_member = LibMarpa.marpa_g_symbol_new(g)
s_value = LibMarpa.marpa_g_symbol_new(g)
s_object = LibMarpa.marpa_g_symbol_new(g)

s_object_contents = LibMarpa.marpa_g_symbol_new(g)
s_array_contents = LibMarpa.marpa_g_symbol_new(g)

symbol_name = {} of Int32 => String
symbol_name[s_begin_object] = "s_begin_object"
symbol_name[s_end_object] = "s_end_object"
symbol_name[s_begin_array] = "s_begin_array"
symbol_name[s_end_array] = "s_end_array"
symbol_name[s_value_separator] = "s_value_separator"
symbol_name[s_name_separator] = "s_name_separator"
symbol_name[s_string] = "s_string"
symbol_name[s_number] = "s_number"
symbol_name[s_true] = "s_true"
symbol_name[s_false] = "s_false"
symbol_name[s_null] = "s_null"
symbol_name[s_array] = "s_array"
symbol_name[s_member] = "s_member"
symbol_name[s_value] = "s_value"
symbol_name[s_object] = "s_object"

symbol_name[s_object_contents] = "s_object_contents"
symbol_name[s_array_contents] = "s_array_contents"

symbol_name[-1] = "nil"

rhs = [0, 0, 0, 0]

rhs[0] = s_false
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_null
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_true
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_object
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_array
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_number
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)
rhs[0] = s_string
LibMarpa.marpa_g_rule_new(g, s_value, rhs, 1)

rhs[0] = s_begin_array
rhs[1] = s_array_contents
rhs[2] = s_end_array
LibMarpa.marpa_g_rule_new(g, s_array, rhs, 3)

rhs[0] = s_begin_object
rhs[1] = s_object_contents
rhs[2] = s_end_object
LibMarpa.marpa_g_rule_new(g, s_object, rhs, 3)

LibMarpa.marpa_g_sequence_new(g, s_array_contents, s_value, s_value_separator, 0, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_object_contents, s_member, s_value_separator, 0, LibMarpa::MARPA_PROPER_SEPARATION)

rhs[0] = s_string
rhs[1] = s_name_separator
rhs[2] = s_value
LibMarpa.marpa_g_rule_new(g, s_member, rhs, 3)

LibMarpa.marpa_g_start_symbol_set(g, s_value)
LibMarpa.marpa_g_precompute(g)

r = LibMarpa.marpa_r_new(g)
LibMarpa.marpa_r_start_input(r)

input =
  %(["asdf", "asdf"])
# %([[[[[[[[[[[[[[[]]]]]]]]]],[[[[[[[[]]]]]]]]]]]]])
# %([1, "abc\ndef", -2.3, null, [], true, false, false ,[1, 2e5, 3], {}, { "a": 1, "b": 2 }])
# %q([[]])

tokens = [
  { %r((?<s_begin_object>\{)), "s_begin_object" },
  { %r((?<s_end_object>\})), "s_end_object" },
  { %r((?<s_begin_array>\[)), "s_begin_array" },
  { %r((?<s_end_array>\])), "s_end_array" },
  { %r((?<s_value_separator>,)), "s_value_separator" },
  { %r((?<s_name_separator>:)), "s_name_separator" },
  { %r((?<s_string>\"[^\"]+\")), "s_string" },
  { %r((?<s_number>-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)), "s_number" },
  { %r((?<s_true>true)), "s_true" },
  { %r((?<s_false>false)), "s_false" },
  { %r((?<s_null>null)), "s_null" },
  { %r((?<s_none>[ \t]+)), "s_none" },
  { %r((?<s_none>\n)), "s_none" },
  { %r((?<s_mismatch>.)), "s_mismatch" },
]

# LEXER
token_regex = Regex.union(tokens.map { |a| a[0] })
token_values = {} of Int32 => String

input.scan(token_regex) do |match|
  position = match.begin || 0
  symbol = match.to_h.compact.to_a[1][0]
  value = match.to_h.compact.to_a[1][1]

  if symbol == "s_none"
    # Do nothing
  elsif symbol == "s_mismatch"
    raise "Lexing error at #{position}"
  else
    status = LibMarpa.marpa_r_alternative(r, symbol_name.key(symbol), position + 1, 1)

    if status != LibMarpa::MarpaErrorCode::MARPA_ERR_NONE
      buffer = uninitialized Int32[128]
      size = LibMarpa.marpa_r_terminals_expected(r, buffer)
      slice = buffer.to_slice[0, size]

      msg = "Unexpected symbol at #{position}, expected:\n"
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

puts pretty(state)
