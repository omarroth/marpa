def metag_grammar
  rules = {} of String => Array(Rule)

  rules["L0"] = [
    {"lhs" => "[:discard]", "rhs" => ["whitespace"]},
    {"lhs" => "whitespace", "rhs" => ["[\\s]+"]},
    {"lhs" => "<op declare bnf>", "rhs" => ["'::='"]},
    {"lhs" => "<op declare match>", "rhs" => ["'~'"]},
    {"lhs" => "<op equal priority>", "rhs" => ["'|'"]},
    {"lhs" => "boolean", "rhs" => ["[01]"]},
    {"lhs" => "<bare name>", "rhs" => ["[\\w]+"]},
    {"lhs" => "<bracketed name>", "rhs" => ["'<'", "<bracketed name string>", "'>'"]},
    {"lhs" => "<bracketed name string>", "rhs" => ["[\\s\\w]+"]},
    {"lhs" => "<single quoted string>", "rhs" => ["[']", "<string without single quote>", "[']"]},
    {"lhs" => "<string without single quote>", "rhs" => ["[^'\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]+"]},
    {"lhs" => "<regex>", "rhs" => ["/\\/.*\\/\\w*/"]},
    {"lhs" => "<character class>", "rhs" => ["'['", "<cc elements>", "']'"]},
    {"lhs" => "<cc elements>", "rhs" => ["[^\\x5d\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]+"]},
    {"lhs" => "[:discard]", "rhs" => ["<hash comment>"]},
    {"lhs" => "<hash comment>", "rhs" => ["/#[^\\n]*/"]},
  ]

  rules["G1"] = [
    {"lhs" => "[:start]", "rhs" => ["statements"]},
    {"lhs" => "statements", "rhs" => ["statement"], "min" => "1"},
    {"lhs" => "statement", "rhs" => ["<start rule>"]},
    {"lhs" => "statement", "rhs" => ["<priority rule>"]},
    {"lhs" => "statement", "rhs" => ["<quantified rule>"]},
    {"lhs" => "statement", "rhs" => ["<discard rule>"]},
    {"lhs" => "<start rule>", "rhs" => ["':start'", "<op declare bnf>", "<single symbol>"]},
    {"lhs" => "<priority rule>", "rhs" => ["lhs", "<op declare>", "alternatives"]},
    {"lhs" => "<quantified rule>", "rhs" => ["lhs", "<op declare>", "<single symbol>", "quantifier", "<adverb list>"]},
    {"lhs" => "<discard rule>", "rhs" => ["':discard'", "<op declare match>", "<single symbol>"]},
    {"lhs" => "<op declare>", "rhs" => ["<op declare bnf>"]},
    {"lhs" => "<op declare>", "rhs" => ["<op declare match>"]},
    {"lhs" => "alternatives", "rhs" => ["rhs"], "min" => "0", "separator" => "<op equal priority>", "proper" => "1"},
    {"lhs" => "<adverb list>", "rhs" => ["<adverb item>"], "min" => "0"},
    {"lhs" => "<adverb item>", "rhs" => ["<separator specification>"]},
    {"lhs" => "<adverb item>", "rhs" => ["<proper specification>"]},
    {"lhs" => "<separator specification>", "rhs" => ["'separator'", "'=>'", "<single symbol>"]},
    {"lhs" => "<proper specification>", "rhs" => ["'proper'", "'=>'", "boolean"]},
    {"lhs" => "lhs", "rhs" => ["<symbol name>"]},
    {"lhs" => "rhs", "rhs" => ["<rhs primary>"], "min" => "1"},
    {"lhs" => "<rhs primary>", "rhs" => ["<single symbol>"]},
    {"lhs" => "<rhs primary>", "rhs" => ["<single quoted string>"]},
    {"lhs" => "<rhs primary>", "rhs" => ["<parenthesized rhs primary list>"]},
    {"lhs" => "<parenthesized rhs primary list>", "rhs" => ["'('", "<rhs list>", "')'"]},
    {"lhs" => "<rhs list>", "rhs" => ["<rhs primary>"], "min" => "1"},
    {"lhs" => "<single symbol>", "rhs" => ["symbol"]},
    {"lhs" => "<single symbol>", "rhs" => ["<character class>"]},
    {"lhs" => "<single symbol>", "rhs" => ["<regex>"]},
    {"lhs" => "symbol", "rhs" => ["<symbol name>"]},
    {"lhs" => "<symbol name>", "rhs" => ["<bare name>"]},
    {"lhs" => "<symbol name>", "rhs" => ["<bracketed name>"]},
    {"lhs" => "quantifier", "rhs" => ["'*'"]},
    {"lhs" => "quantifier", "rhs" => ["'+'"]},
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

def english_grammar
  rules = {} of String => Array(Rule)

  rules["L0"] = [
    {"lhs" => "<NNP ALT>", "rhs" => ["/Victory|April|Winston|Smith|Hate|Week/"]},
    {"lhs" => "<WP ALT>", "rhs" => ["/what|who/i"]},
    {"lhs" => "<WRB ALT>", "rhs" => ["/where|do|how/i"]},
    {"lhs" => "<CC ALT>", "rhs" => ["/and|or/i"]},
    {"lhs" => "<CD ALT>", "rhs" => ["/fourty|one|two|three|four|five|six|seven|eight|nine|ten|eleven|eleventy|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred/i"]},
    {"lhs" => "<DT ALT>", "rhs" => ["/this|that|these|those|the|all|half|an|a|no/i"]},
    {"lhs" => "<FW ALT>", "rhs" => ["/a/"]},
    {"lhs" => "<IN ALT>", "rhs" => ["/if|on|above|during|than|at|for|of|into|in|as|out|over|past|by|through|though|from|with/i"]},
    {"lhs" => "<JJ ALT>", "rhs" => ["/real|several|right|left|varicose|electric|present|ruggedly|handsome|black|heavy|wide|enormous|indoor|coloured|old|boiled|gritty|vile|bright|untouched|many|good|full|strong|other|weak|kind|old|favorite|cold|difficult|wonderful|interested|fond|thirsty|busy|afraid|sure|sorry|quiet|glad|ready|sharp|much/i"]},
    {"lhs" => "<JJR ALT>", "rhs" => ["/more/i"]},
    {"lhs" => "<JJS ALT>", "rhs" => ["/best/i"]},
    {"lhs" => "<MD ALT>", "rhs" => ["/would|must/i"]},
    {"lhs" => "<NN ALT>", "rhs" => ["/grammar|way|ankle|ulcer|flat|preparation|drive|economy|part|daylight|current|lift|use|moustache|metre|meter|face|wall|display|poster|end|rag|cabbage|hallway|dust|swirl|glass|wind|effort|breast|chin|life|aspect|quarter|news|sausage|dog|book|pencil|address|name|color|size|day|today|milk|yard|picture|idea|something|girl|door|question|father|office|man|breakfast|egg|time|friend|tennis|child/i"]},
    {"lhs" => "<NNPS ALT>", "rhs" => ["/Mansions/"]},
    {"lhs" => "<NNS ALT>", "rhs" => ["/symbols|flights|hours|mats|doors|books|pencils|children|letters|o'clock|eggs|minutes|flowers|rice|rolls|clocks|features|stairs|times/"]},
    {"lhs" => "<PRP ALT>", "rhs" => ["/yourself|it|your|you|one|he|my|we|it|I|his|they|me|him/i"]},
    {"lhs" => "<RB ALT>", "rhs" => ["/up|even|about|also|not|very|exactly|there|just|now|n't|only|quickly|enough|too|large|simply|seldom|slowly/i"]},
    {"lhs" => "<RP ALT>", "rhs" => ["/up|along/"]},
    {"lhs" => "<TO ALT>", "rhs" => ["/to/i"]},
    {"lhs" => "<VB ALT>", "rhs" => ["/escape|eat|do|add|be|learn|get|hear|help|prevent|have|tell/i"]},
    {"lhs" => "<VBD ALT>", "rhs" => ["/said|was|were|slipped|had|made|went|wanted/i"]},
    {"lhs" => "<VBG ALT>", "rhs" => ["/working|helping|eating|going|manufacturing|striking|entering|trying/"]},
    {"lhs" => "<VBN ALT>", "rhs" => ["/precomputed|cutoff|nuzzled|smelt|been|tacked|depicted|resting/"]},
    {"lhs" => "<VBP ALT>", "rhs" => ["/are|have|suggest|want|am|'m|like|hate/i"]},
    {"lhs" => "<VBZ ALT>", "rhs" => ["/goes|likes|is|'s/i"]},
    {"lhs" => "<WDT ALT>", "rhs" => ["/what/i"]},
    {"lhs" => "word", "rhs" => ["/\\w+-?\\w+/"]},
    {"lhs" => "comma", "rhs" => ["','"]},
    {"lhs" => "hyphen", "rhs" => ["'-'"]},
    {"lhs" => "period", "rhs" => ["/\\.|\\?|\\!/"]},
    {"lhs" => "[:discard]", "rhs" => ["<hash comment>"]},
    {"lhs" => "<hash comment>", "rhs" => ["/#[^\\n]*/"]},
    {"lhs" => "[:discard]", "rhs" => ["whitespace"]},
    {"lhs" => "whitespace", "rhs" => ["[\\s]+"]},
  ]

  rules["G1"] = [
    {"lhs" => "[:start]", "rhs" => ["ROOTS"]},
    {"lhs" => "ROOTS", "rhs" => ["ROOT"], "min" => "1"},
    {"lhs" => "ROOT", "rhs" => ["TYPE", "period"]},
    {"lhs" => "TYPE", "rhs" => ["FRAG"]},
    {"lhs" => "TYPE", "rhs" => ["S"]},
    {"lhs" => "TYPE", "rhs" => ["SBARQ"]},
    {"lhs" => "TYPE", "rhs" => ["SQ"]},
    {"lhs" => "FRAG", "rhs" => ["SBARQ"]},
    {"lhs" => "FRAG", "rhs" => ["CC", "NP"]},
    {"lhs" => "SBARQ", "rhs" => ["WHADJP", "SQ"]},
    {"lhs" => "SBARQ", "rhs" => ["WHADVP", "SQ"]},
    {"lhs" => "SBARQ", "rhs" => ["WHNP", "SQ"]},
    {"lhs" => "SBAR", "rhs" => ["S"]},
    {"lhs" => "SBAR", "rhs" => ["WHADJP", "S"]},
    {"lhs" => "SBAR", "rhs" => ["WHNP", "S"]},
    {"lhs" => "SBAR", "rhs" => ["IN", "S"]},
    {"lhs" => "SQ", "rhs" => ["RB", "<NP SEQ>"]},
    {"lhs" => "SQ", "rhs" => ["VP", "<NP SEQ>"]},
    {"lhs" => "S", "rhs" => ["ADVP", "NP", "VP"]},
    {"lhs" => "S", "rhs" => ["NP", "ADVP", "VP"]},
    {"lhs" => "S", "rhs" => ["NP", "VP"]},
    {"lhs" => "S", "rhs" => ["PP", "NP", "VP"]},
    {"lhs" => "S", "rhs" => ["S", "VP"]},
    {"lhs" => "S", "rhs" => ["S", "','", "CC", "S"]},
    {"lhs" => "S", "rhs" => ["S", "','", "S"]},
    {"lhs" => "S", "rhs" => ["SBAR", "VP"]},
    {"lhs" => "S", "rhs" => ["VP"]},
    {"lhs" => "<JJ SEQ>", "rhs" => ["JJ"], "min" => "1"},
    {"lhs" => "<NNP SEQ>", "rhs" => ["NNP"], "min" => "1"},
    {"lhs" => "<NNPS SEQ>", "rhs" => ["NNPS"], "min" => "1"},
    {"lhs" => "<CD SEQ>", "rhs" => ["CD"], "min" => "1", "separator" => "hyphen"},
    {"lhs" => "NP", "rhs" => ["<JJ SEQ>"]},
    {"lhs" => "NP", "rhs" => ["<NNP SEQ>"]},
    {"lhs" => "NP", "rhs" => ["<NNPS SEQ>"]},
    {"lhs" => "NP", "rhs" => ["<CD SEQ>"]},
    {"lhs" => "NP", "rhs" => ["CD", "NP"]},
    {"lhs" => "NP", "rhs" => ["DT"]},
    {"lhs" => "NP", "rhs" => ["DT", "<JJ SEQ>", "NP"]},
    {"lhs" => "NP", "rhs" => ["DT", "NP"]},
    {"lhs" => "NP", "rhs" => ["JJS"]},
    {"lhs" => "NP", "rhs" => ["NN"]},
    {"lhs" => "NP", "rhs" => ["NN", "NP"]},
    {"lhs" => "NP", "rhs" => ["NNS"]},
    {"lhs" => "NP", "rhs" => ["NNS", "NP"]},
    {"lhs" => "NP", "rhs" => ["NP", "CC", "NP"]},
    {"lhs" => "NP", "rhs" => ["NP", "SBAR"]},
    {"lhs" => "NP", "rhs" => ["NP", "UCP"]},
    {"lhs" => "NP", "rhs" => ["NP", "','"]},
    {"lhs" => "NP", "rhs" => ["PRP"]},
    {"lhs" => "NP", "rhs" => ["PRP", "NP"]},
    {"lhs" => "NP", "rhs" => ["QP"]},
    {"lhs" => "NP", "rhs" => ["QP", "NP"]},
    {"lhs" => "NP", "rhs" => ["RB"]},
    {"lhs" => "VP", "rhs" => ["ADJP"]},
    {"lhs" => "VP", "rhs" => ["ADJP", "S"]},
    {"lhs" => "VP", "rhs" => ["MD", "VP"]},
    {"lhs" => "VP", "rhs" => ["NP"]},
    {"lhs" => "VP", "rhs" => ["NP", "VP"]},
    {"lhs" => "VP", "rhs" => ["PP"]},
    {"lhs" => "VP", "rhs" => ["PRT"]},
    {"lhs" => "VP", "rhs" => ["TO", "VP"]},
    {"lhs" => "VP", "rhs" => ["VB"]},
    {"lhs" => "VP", "rhs" => ["VB", "SBAR"]},
    {"lhs" => "VP", "rhs" => ["VB", "VP"]},
    {"lhs" => "VP", "rhs" => ["VBD"]},
    {"lhs" => "VP", "rhs" => ["VBD", "VP"]},
    {"lhs" => "VP", "rhs" => ["VBG"]},
    {"lhs" => "VP", "rhs" => ["VBG", "VP"]},
    {"lhs" => "VP", "rhs" => ["VBN"]},
    {"lhs" => "VP", "rhs" => ["VBN", "VP"]},
    {"lhs" => "VP", "rhs" => ["VBP", "ADJP", "ADVP"]},
    {"lhs" => "VP", "rhs" => ["VBP", "RB", "NP"]},
    {"lhs" => "VP", "rhs" => ["VBP", "S"]},
    {"lhs" => "VP", "rhs" => ["VBP", "VP"]},
    {"lhs" => "VP", "rhs" => ["VBZ", "ADJP"]},
    {"lhs" => "VP", "rhs" => ["VBZ", "RB", "NP"]},
    {"lhs" => "VP", "rhs" => ["VBZ", "S"]},
    {"lhs" => "VP", "rhs" => ["VBZ", "SBAR"]},
    {"lhs" => "VP", "rhs" => ["VBZ", "VP"]},
    {"lhs" => "VP", "rhs" => ["VP", "CC", "VP"]},
    {"lhs" => "ADVP", "rhs" => ["PP"], "min" => "1"},
    {"lhs" => "ADJP", "rhs" => ["IN", "PP"]},
    {"lhs" => "ADJP", "rhs" => ["JJ"]},
    {"lhs" => "ADJP", "rhs" => ["JJ", "PP"]},
    {"lhs" => "ADJP", "rhs" => ["JJ", "S"]},
    {"lhs" => "ADJP", "rhs" => ["NP", "JJ"]},
    {"lhs" => "ADJP", "rhs" => ["RB", "JJ"]},
    {"lhs" => "ADJP", "rhs" => ["RB", "JJ", "PP"]},
    {"lhs" => "ADJP", "rhs" => ["VBG"]},
    {"lhs" => "<NP SEQ>", "rhs" => ["NP"], "min" => "1"},
    {"lhs" => "WHNP", "rhs" => ["WP"]},
    {"lhs" => "WHNP", "rhs" => ["WDT", "NN"]},
    {"lhs" => "WHNP", "rhs" => ["WHADJP", "NNS"]},
    {"lhs" => "WHADJP", "rhs" => ["RB", "WP"]},
    {"lhs" => "WHADJP", "rhs" => ["WRB", "JJ"]},
    {"lhs" => "WHADVP", "rhs" => ["WRB"]},
    {"lhs" => "PP", "rhs" => ["FW", "NP"]},
    {"lhs" => "PP", "rhs" => ["IN"]},
    {"lhs" => "PP", "rhs" => ["RB"]},
    {"lhs" => "PP", "rhs" => ["IN", "NP"]},
    {"lhs" => "PP", "rhs" => ["TO", "NP"]},
    {"lhs" => "PRT", "rhs" => ["RP"]},
    {"lhs" => "UCP", "rhs" => ["ADJP", "':'", "NP"]},
    {"lhs" => "QP", "rhs" => ["JJR", "IN", "DT"]},
    {"lhs" => "QP", "rhs" => ["CD", "CC", "JJR"]},
    {"lhs" => "NNP", "rhs" => ["<NNP ALT>"]},
    {"lhs" => "NNP", "rhs" => ["word"]},
    {"lhs" => "WP", "rhs" => ["<WP ALT>"]},
    {"lhs" => "WP", "rhs" => ["word"]},
    {"lhs" => "WRB", "rhs" => ["<WRB ALT>"]},
    {"lhs" => "WRB", "rhs" => ["word"]},
    {"lhs" => "CC", "rhs" => ["<CC ALT>"]},
    {"lhs" => "CC", "rhs" => ["word"]},
    {"lhs" => "CD", "rhs" => ["<CD ALT>"]},
    {"lhs" => "CD", "rhs" => ["word"]},
    {"lhs" => "DT", "rhs" => ["<DT ALT>"]},
    {"lhs" => "DT", "rhs" => ["word"]},
    {"lhs" => "FW", "rhs" => ["<FW ALT>"]},
    {"lhs" => "FW", "rhs" => ["word"]},
    {"lhs" => "IN", "rhs" => ["<IN ALT>"]},
    {"lhs" => "IN", "rhs" => ["word"]},
    {"lhs" => "JJ", "rhs" => ["<JJ ALT>"]},
    {"lhs" => "JJ", "rhs" => ["word"]},
    {"lhs" => "JJR", "rhs" => ["<JJR ALT>"]},
    {"lhs" => "JJR", "rhs" => ["word"]},
    {"lhs" => "JJS", "rhs" => ["<JJS ALT>"]},
    {"lhs" => "JJS", "rhs" => ["word"]},
    {"lhs" => "MD", "rhs" => ["<MD ALT>"]},
    {"lhs" => "MD", "rhs" => ["word"]},
    {"lhs" => "NN", "rhs" => ["<NN ALT>"]},
    {"lhs" => "NN", "rhs" => ["word"]},
    {"lhs" => "NNPS", "rhs" => ["<NNPS ALT>"]},
    {"lhs" => "NNPS", "rhs" => ["word"]},
    {"lhs" => "NNS", "rhs" => ["<NNS ALT>"]},
    {"lhs" => "NNS", "rhs" => ["word"]},
    {"lhs" => "PRP", "rhs" => ["<PRP ALT>"]},
    {"lhs" => "PRP", "rhs" => ["word"]},
    {"lhs" => "RB", "rhs" => ["<RB ALT>"]},
    {"lhs" => "RB", "rhs" => ["word"]},
    {"lhs" => "RP", "rhs" => ["<RP ALT>"]},
    {"lhs" => "RP", "rhs" => ["word"]},
    {"lhs" => "TO", "rhs" => ["<TO ALT>"]},
    {"lhs" => "TO", "rhs" => ["word"]},
    {"lhs" => "VB", "rhs" => ["<VB ALT>"]},
    {"lhs" => "VB", "rhs" => ["word"]},
    {"lhs" => "VBD", "rhs" => ["<VBD ALT>"]},
    {"lhs" => "VBD", "rhs" => ["word"]},
    {"lhs" => "VBG", "rhs" => ["<VBG ALT>"]},
    {"lhs" => "VBG", "rhs" => ["word"]},
    {"lhs" => "VBN", "rhs" => ["<VBN ALT>"]},
    {"lhs" => "VBN", "rhs" => ["word"]},
    {"lhs" => "VBP", "rhs" => ["<VBP ALT>"]},
    {"lhs" => "VBP", "rhs" => ["word"]},
    {"lhs" => "VBZ", "rhs" => ["<VBZ ALT>"]},
    {"lhs" => "VBZ", "rhs" => ["word"]},
    {"lhs" => "WDT", "rhs" => ["<WDT ALT>"]},
    {"lhs" => "WDT", "rhs" => ["word"]},
  ]

  return rules
end
