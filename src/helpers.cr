def metag_grammar
  rules = {} of String => Array(Rule)

  rules["G1"] = [
    {"lhs" => "statements", "rhs" => ["statement"], "min" => "1"},
    {"lhs" => "statement", "rhs" => ["start rule"]},
    {"lhs" => "statement", "rhs" => ["priority rule"]},
    {"lhs" => "statement", "rhs" => ["quantified rule"]},
    {"lhs" => "statement", "rhs" => ["discard rule"]},

    {"lhs" => "start rule", "rhs" => ["':start'", "op declare bnf", "symbol"]},
    {"lhs" => "priority rule", "rhs" => ["lhs", "op declare", "alternatives"]},
    {"lhs" => "quantified rule", "rhs" => ["lhs", "op declare", "single symbol", "quantifier", "adverb list"]},
    {"lhs" => "discard rule", "rhs" => ["':discard'", "op declare match", "single symbol"]},

    {"lhs" => "op declare", "rhs" => ["op declare bnf"]},
    {"lhs" => "op declare", "rhs" => ["op declare match"]},

    {"lhs" => "alternatives", "rhs" => ["rhs"], "min" => "1", "separator" => "op equal priority", "proper" => "1"},
    {"lhs" => "adverb list", "rhs" => ["adverb item"], "min" => "0"},
    {"lhs" => "adverb item", "rhs" => ["separator specification"]},
    {"lhs" => "adverb item", "rhs" => ["proper specification"]},

    {"lhs" => "separator specification", "rhs" => ["'separator'", "'=>'", "single symbol"]},
    {"lhs" => "proper specification", "rhs" => ["'proper'", "'=>'", "boolean"]},

    {"lhs" => "lhs", "rhs" => ["symbol name"]},
    {"lhs" => "rhs", "rhs" => ["rhs primary"], "min" => "1"},
    {"lhs" => "rhs primary", "rhs" => ["single symbol"]},
    {"lhs" => "rhs primary", "rhs" => ["single quoted string"]},
    {"lhs" => "rhs primary", "rhs" => ["parenthesized rhs primary list"]},
    {"lhs" => "parenthesized rhs primary list", "rhs" => ["'('", "rhs list", "')'"]},
    {"lhs" => "rhs list", "rhs" => ["rhs primary"], "min" => "1"},
    {"lhs" => "single symbol", "rhs" => ["symbol"]},
    {"lhs" => "single symbol", "rhs" => ["character class"]},
    {"lhs" => "symbol", "rhs" => ["symbol name"]},
    {"lhs" => "symbol name", "rhs" => ["bare name"]},
    {"lhs" => "symbol name", "rhs" => ["bracketed name"]},
    {"lhs" => "[:start]", "rhs" => ["statements"]},
  ]

  rules["L0"] = [
    {"lhs" => "whitespace", "rhs" => ["[\\s]+"]},
    {"lhs" => "op declare bnf", "rhs" => ["'::='"]},
    {"lhs" => "op declare match", "rhs" => ["'~'"]},
    {"lhs" => "op equal priority", "rhs" => ["'|'"]},
    {"lhs" => "boolean", "rhs" => ["[01]"]},
    {"lhs" => "bare name", "rhs" => ["[\\w]+"]},
    {"lhs" => "bracketed name", "rhs" => ["'<'", "bracketed name string", "'>'"]},
    {"lhs" => "bracketed name string", "rhs" => ["[\\s\\w]+"]},
    {"lhs" => "single quoted string", "rhs" => ["[']", "string without single quote", "[']"]},
    {"lhs" => "string without single quote", "rhs" => ["[^\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]+"]},
    {"lhs" => "character class", "rhs" => ["'['", "cc elements", "']'"]},
    {"lhs" => "cc elements", "rhs" => ["[^\\x5d\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]+"]},
    {"lhs" => "[:discard]", "rhs" => ["whitespace"]},
    {"lhs" => "quantifier", "rhs" => ["[*+]"]},
  ]

  return rules
end

def json_grammar
  rules = {} of String => Array(Rule)

  rules["G1"] = [
    {"lhs" => "json", "rhs" => ["object"]},
    {"lhs" => "json", "rhs" => ["array"]},
    {"lhs" => "object", "rhs" => ["lcurly", "members", "rcurly"]},

    {"lhs" => "members", "rhs" => ["pair"], "min" => "0", "separator" => "comma", "proper" => "1"},
    {"lhs" => "pair", "rhs" => ["string", "colon", "value"]},

    {"lhs" => "value", "rhs" => ["string"]},
    {"lhs" => "value", "rhs" => ["object"]},
    {"lhs" => "value", "rhs" => ["number"]},
    {"lhs" => "value", "rhs" => ["array"]},
    {"lhs" => "value", "rhs" => ["true"]},
    {"lhs" => "value", "rhs" => ["false"]},
    {"lhs" => "value", "rhs" => ["null"]},

    {"lhs" => "array", "rhs" => ["lsquare", "elements", "rsquare"]},
    {"lhs" => "elements", "rhs" => ["value"], "min" => "0", "separator" => "comma", "proper" => "1"},

    {"lhs" => "[:start]", "rhs" => ["json"]},
  ]

  rules["L0"] = [
    {"lhs" => "lcurly", "rhs" => ["'{'"]},
    {"lhs" => "rcurly", "rhs" => ["'}'"]},

    {"lhs" => "lsquare", "rhs" => ["'['"]},
    {"lhs" => "rsquare", "rhs" => ["']'"]},

    {"lhs" => "comma", "rhs" => ["','"]},
    {"lhs" => "colon", "rhs" => ["':'"]},

    {"lhs" => "string", "rhs" => ["/\"[^\"]*\"/"]},
    {"lhs" => "number", "rhs" => ["/-?[\\d]+[.\\d+]*/"]},

    {"lhs" => "true", "rhs" => ["'true'"]},
    {"lhs" => "false", "rhs" => ["'false'"]},
    {"lhs" => "null", "rhs" => ["'null'"]},

    {"lhs" => "whitespace", "rhs" => ["[ \\t\\n]+"]},
    {"lhs" => "[:discard]", "rhs" => ["whitespace"]},
  ]

  return rules
end