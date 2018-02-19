<<-BNF
:start        ::= rules
rules         ::= rule+

rule          ::= cmd_type user
               | cmd_type list_ref
               | user_list

user_list  ::= user '=' users
users      ::= user+

list_ref        ~ '@' username
user            ~ username

cmd_type        ~ 'Deny' | 'Allow'
username        ~ [\w]+

:discard        ~ ws
ws              ~ [\s]+
BNF

config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))
LibMarpa.marpa_g_force_valued(g)

s_rules = LibMarpa.marpa_g_symbol_new(g)
s_rule = LibMarpa.marpa_g_symbol_new(g)
s_cmd_type = LibMarpa.marpa_g_symbol_new(g)
s_user = LibMarpa.marpa_g_symbol_new(g)
s_list_ref = LibMarpa.marpa_g_symbol_new(g)
s_user_list = LibMarpa.marpa_g_symbol_new(g)
s_users = LibMarpa.marpa_g_symbol_new(g)
s_username = LibMarpa.marpa_g_symbol_new(g)
s_equals = LibMarpa.marpa_g_symbol_new(g)

symbol_name = {} of Int32 => String

symbol_name[s_rules] = "s_rules"
symbol_name[s_rule] = "s_rule"
symbol_name[s_cmd_type] = "s_cmd_type"
symbol_name[s_user] = "s_user"
symbol_name[s_list_ref] = "s_list_ref"
symbol_name[s_user_list] = "s_user_list"
symbol_name[s_users] = "s_users"
symbol_name[s_username] = "s_username"
symbol_name[s_equals] = "s_equals"

rhs = [0, 0, 0, 0]

rhs[0] = s_username
LibMarpa.marpa_g_rule_new(g, s_user, rhs, 1)

rhs[0] = s_user_list
LibMarpa.marpa_g_rule_new(g, s_rule, rhs, 1)

rhs[0] = s_cmd_type
rhs[1] = s_user
LibMarpa.marpa_g_rule_new(g, s_rule, rhs, 2)

rhs[0] = s_cmd_type
rhs[1] = s_list_ref
LibMarpa.marpa_g_rule_new(g, s_rule, rhs, 2)

rhs[0] = s_user
rhs[1] = s_equals
rhs[2] = s_users
LibMarpa.marpa_g_rule_new(g, s_user_list, rhs, 3)

LibMarpa.marpa_g_sequence_new(g, s_users, s_user, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
LibMarpa.marpa_g_sequence_new(g, s_rules, s_rule, -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)

LibMarpa.marpa_g_start_symbol_set(g, s_rules)
LibMarpa.marpa_g_precompute(g)

r = LibMarpa.marpa_r_new(g)
LibMarpa.marpa_r_start_input(r)

input = <<-INPUT
admins = admin root administrator peter
Deny baduser
Allow @admins
INPUT

tokens = [
  { %r((?<s_cmd_type>Deny|Allow)), "s_cmd_type" },
  { %r((?<s_list_ref>@[\w]+)), "s_list_ref" },
  { %r((?<s_username>[\w]+)), "s_username" },
  { %r((?<s_equals>=)), "s_equals" },
  { %r((?<s_none>[\s]+)), "s_none" },
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

values_sorted = token_values.to_a.sort_by { |a, b| b.size }
longest_token_length = values_sorted[-1][1].size + 1
alias RecArray = String | Array(RecArray)
stack = [] of RecArray

# stack = [] of {Int32, String}

loop do
  step_type = LibMarpa.marpa_v_step(value)

  case step_type
  when step_type.value < 0
    e = LibMarpa.marpa_g_error(g, p_error_string)
    raise "Event returned #{e}"
  when LibMarpa::MarpaStepType::MARPA_STEP_RULE
    rule = value.value

    start = rule.t_arg_0
    stop = rule.t_arg_n

    puts rule

    if stop - start > 0 || rule.t_rule_id == 1
      tmp = [] of RecArray
      tmp = stack[start..stop]
      stack.delete_at(start..stop)

      stack << tmp
    end
  when LibMarpa::MarpaStepType::MARPA_STEP_TOKEN
    token = value.value
    token_value = token_values[token.t_token_value - 1]
    puts token_value
    stack << token_value
  when LibMarpa::MarpaStepType::MARPA_STEP_NULLING_SYMBOL
    #
  when LibMarpa::MarpaStepType::MARPA_STEP_INACTIVE
    break
  when LibMarpa::MarpaStepType::MARPA_STEP_INITIAL
    #
  end
end

puts stack[0]