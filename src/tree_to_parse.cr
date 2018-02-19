require "json"

tree = JSON.parse(File.read("src/bnf.json"))

config = uninitialized LibMarpa::MarpaConfig
LibMarpa.marpa_c_init(pointerof(config))

g = LibMarpa.marpa_g_new(pointerof(config))

symbols = {} of Int32 => String

tree.each do |leaf|
  leaf = leaf.as_a

  leaf.each do |item|
    id = LibMarpa.marpa_g_symbol_new(g)
    symbols[id] = item.to_s
  end

  rule = leaf.dup
  lhs = rule.first
  rule.shift

  rhs = rule.map { |a| symbols.key(a) }

  if rule[-1]? == "+"
    LibMarpa.marpa_g_sequence_new(g, symbols.key(lhs), symbols.key(rule[0]), -1, 1, LibMarpa::MARPA_PROPER_SEPARATION)
  elsif rule[-1]? == "*"
    LibMarpa.marpa_g_sequence_new(g, symbols.key(lhs), symbols.key(rule[0]), -1, 0, LibMarpa::MARPA_PROPER_SEPARATION)
  else
    LibMarpa.marpa_g_rule_new(g, symbols.key(lhs), rhs, rhs.size)
  end

  rhs = [] of Int32
end

# puts symbols

highest_rule_id = LibMarpa.marpa_g_highest_rule_id(g) + 1

highest_rule_id.times do |rule_id|
  lhs_id = LibMarpa.marpa_g_rule_lhs(g, rule_id)
  rule_length = LibMarpa.marpa_g_rule_length(g, rule_id)
  rhs = [] of String
  rule_length.times do |i|
    rhs_id = LibMarpa.marpa_g_rule_rhs(g, rule_id, i)
    rhs << symbols[rhs_id]
  end
  STDOUT << symbols[lhs_id] << " " << rhs << "\n"
end
