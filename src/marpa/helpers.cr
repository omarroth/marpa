module Marpa
  class Parser
    alias RecArray = String | Array(RecArray)

    # Build up state given list
    def build_meta_grammar(actions)
      actions.create_symbol([["statements"]])
      actions.start_rule([":start", "::=", [[["statements"]]]])
      actions.create_symbol([["statements"]])
      actions.create_symbol([["statement"]])
      actions.quantified_rule([[[["statements"]]], ["::="], [[["statement"]]], ["+"], [] of String])
      actions.create_symbol([["statement"]])
      actions.create_symbol([["<start rule>"]])
      actions.create_symbol([["<priority rule>"]])
      actions.create_symbol([["<quantified rule>"]])
      actions.create_symbol([["<discard rule>"]])
      actions.create_symbol([["<empty rule>"]])
      actions.priority_rule([[[["statement"]]], ["::="], [[[[[[[["<start rule>"]]]]], [] of String], "|", [[[[[["<priority rule>"]]]]], [] of String], "|", [[[[[["<quantified rule>"]]]]], [] of String], "|", [[[[[["<discard rule>"]]]]], [] of String], "|", [[[[[["<empty rule>"]]]]], [] of String]]]])
      actions.create_symbol([["<start rule>"]])
      actions.create_literal(["':start'"])
      actions.create_symbol([["<op declare bnf>"]])
      actions.create_symbol([["<single symbol>"]])
      actions.priority_rule([[[["<start rule>"]]], ["::="], [[[[["':start'"], [[[["<op declare bnf>"]]]], [[[["<single symbol>"]]]]], [[["action", "=>", "start_rule"]]]]]]])
      actions.create_symbol([["<priority rule>"]])
      actions.create_symbol([["lhs"]])
      actions.create_symbol([["<op declare>"]])
      actions.create_symbol([["priorities"]])
      actions.priority_rule([[[["<priority rule>"]]], ["::="], [[[[[[[["lhs"]]]], [[[["<op declare>"]]]], [[[["priorities"]]]]], [[["action", "=>", "priority_rule"]]]]]]])
      actions.create_symbol([["<quantified rule>"]])
      actions.create_symbol([["lhs"]])
      actions.create_symbol([["<op declare>"]])
      actions.create_symbol([["<single symbol>"]])
      actions.create_symbol([["quantifier"]])
      actions.create_symbol([["<adverb list>"]])
      actions.priority_rule([[[["<quantified rule>"]]], ["::="], [[[[[[[["lhs"]]]], [[[["<op declare>"]]]], [[[["<single symbol>"]]]], [[[["quantifier"]]]], [[[["<adverb list>"]]]]], [[["action", "=>", "quantified_rule"]]]]]]])
      actions.create_symbol([["<discard rule>"]])
      actions.create_literal(["':discard'"])
      actions.create_symbol([["<op declare match>"]])
      actions.create_symbol([["<single symbol>"]])
      actions.priority_rule([[[["<discard rule>"]]], ["::="], [[[[["':discard'"], [[[["<op declare match>"]]]], [[[["<single symbol>"]]]]], [[["action", "=>", "discard_rule"]]]]]]])
      actions.create_symbol([["<empty rule>"]])
      actions.create_symbol([["lhs"]])
      actions.create_symbol([["<op declare>"]])
      actions.create_symbol([["<adverb list>"]])
      actions.priority_rule([[[["<empty rule>"]]], ["::="], [[[[[[[["lhs"]]]], [[[["<op declare>"]]]], [[[["<adverb list>"]]]]], [[["action", "=>", "empty_rule"]]]]]]])
      actions.create_symbol([["priorities"]])
      actions.create_symbol([["alternatives"]])
      actions.create_symbol([["<op loosen>"]])
      actions.quantified_rule([[[["priorities"]]], ["::="], [[["alternatives"]]], ["+"], [[["separator", "=>", [[["<op loosen>"]]]]], [["proper", "=>", "1"]]]])
      actions.create_symbol([["alternatives"]])
      actions.create_symbol([["alternative"]])
      actions.create_symbol([["<op equal priority>"]])
      actions.quantified_rule([[[["alternatives"]]], ["::="], [[["alternative"]]], ["+"], [[["separator", "=>", [[["<op equal priority>"]]]]], [["proper", "=>", "1"]]]])
      actions.create_symbol([["alternative"]])
      actions.create_symbol([["rhs"]])
      actions.create_symbol([["<adverb list>"]])
      actions.priority_rule([[[["alternative"]]], ["::="], [[[[[[[["rhs"]]]], [[[["<adverb list>"]]]]], [] of String]]]])
      actions.create_symbol([["<adverb list>"]])
      actions.create_symbol([["<adverb item>"]])
      actions.quantified_rule([[[["<adverb list>"]]], ["::="], [[["<adverb item>"]]], ["*"], [] of String])
      actions.create_symbol([["<adverb item>"]])
      actions.create_symbol([["action"]])
      actions.create_symbol([["<separator specification>"]])
      actions.create_symbol([["<proper specification>"]])
      actions.priority_rule([[[["<adverb item>"]]], ["::="], [[[[[[[["action"]]]]], [] of String], "|", [[[[[["<separator specification>"]]]]], [] of String], "|", [[[[[["<proper specification>"]]]]], [] of String]]]])
      actions.create_symbol([["action"]])
      actions.create_literal(["'action'"])
      actions.create_literal(["'=>'"])
      actions.create_symbol([["<action name>"]])
      actions.priority_rule([[[["action"]]], ["::="], [[[[["'action'"], ["'=>'"], [[[["<action name>"]]]]], [] of String]]]])
      actions.create_symbol([["<action name>"]])
      actions.create_character_class(["[\\w]"])
      actions.quantified_rule([[[["<action name>"]]], ["~"], ["[\\w]"], ["+"], [] of String])
      actions.create_symbol([["<separator specification>"]])
      actions.create_literal(["'separator'"])
      actions.create_literal(["'=>'"])
      actions.create_symbol([["<single symbol>"]])
      actions.priority_rule([[[["<separator specification>"]]], ["::="], [[[[["'separator'"], ["'=>'"], [[[["<single symbol>"]]]]], [] of String]]]])
      actions.create_symbol([["<proper specification>"]])
      actions.create_literal(["'proper'"])
      actions.create_literal(["'=>'"])
      actions.create_symbol([["boolean"]])
      actions.priority_rule([[[["<proper specification>"]]], ["::="], [[[[["'proper'"], ["'=>'"], [[[["boolean"]]]]], [] of String]]]])
      actions.create_symbol([["lhs"]])
      actions.create_symbol([["symbol"]])
      actions.priority_rule([[[["lhs"]]], ["::="], [[[[[[[["symbol"]]]]], [] of String]]]])
      actions.create_symbol([["rhs"]])
      actions.create_symbol([["<rhs primary>"]])
      actions.quantified_rule([[[["rhs"]]], ["::="], [[["<rhs primary>"]]], ["+"], [] of String])
      actions.create_symbol([["<rhs primary>"]])
      actions.create_symbol([["<single symbol>"]])
      actions.create_symbol([["<single quoted string>"]])
      actions.create_symbol([["<parenthesized rhs primary list>"]])
      actions.priority_rule([[[["<rhs primary>"]]], ["::="], [[[[[[[["<single symbol>"]]]]], [] of String], "|", [[[[[["<single quoted string>"]]]]], [[["action", "=>", "create_literal"]]]], "|", [[[[[["<parenthesized rhs primary list>"]]]]], [] of String]]]])
      actions.create_symbol([["<parenthesized rhs primary list>"]])
      actions.create_literal(["'('"])
      actions.create_symbol([["<rhs list>"]])
      actions.create_literal(["')'"])
      actions.priority_rule([[[["<parenthesized rhs primary list>"]]], ["::="], [[[[["'('"], [[[["<rhs list>"]]]], ["')'"]], [] of String]]]])
      actions.create_symbol([["<rhs list>"]])
      actions.create_symbol([["<rhs primary>"]])
      actions.quantified_rule([[[["<rhs list>"]]], ["::="], [[["<rhs primary>"]]], ["+"], [] of String])
      actions.create_symbol([["<single symbol>"]])
      actions.create_symbol([["symbol"]])
      actions.create_symbol([["<character class>"]])
      actions.create_symbol([["<regex>"]])
      actions.priority_rule([[[["<single symbol>"]]], ["::="], [[[[[[[["symbol"]]]]], [] of String], "|", [[[[[["<character class>"]]]]], [[["action", "=>", "create_character_class"]]]], "|", [[[[[["<regex>"]]]]], [[["action", "=>", "create_regex"]]]]]]])
      actions.create_symbol([["symbol"]])
      actions.create_symbol([["<symbol name>"]])
      actions.priority_rule([[[["symbol"]]], ["::="], [[[[[[[["<symbol name>"]]]]], [[["action", "=>", "create_symbol"]]]]]]])
      actions.create_symbol([["<symbol name>"]])
      actions.create_symbol([["<bare name>"]])
      actions.create_symbol([["<bracketed name>"]])
      actions.priority_rule([[[["<symbol name>"]]], ["::="], [[[[[[[["<bare name>"]]]]], [] of String], "|", [[[[[["<bracketed name>"]]]]], [] of String]]]])
      actions.create_symbol([["whitespace"]])
      actions.discard_rule([":discard", "~", [[["whitespace"]]]])
      actions.create_symbol([["whitespace"]])
      actions.create_character_class(["[\\s]"])
      actions.quantified_rule([[[["whitespace"]]], ["~"], ["[\\s]"], ["+"], [] of String])
      actions.create_symbol([["<op declare>"]])
      actions.create_symbol([["<op declare bnf>"]])
      actions.create_symbol([["<op declare match>"]])
      actions.priority_rule([[[["<op declare>"]]], ["::="], [[[[[[[["<op declare bnf>"]]]]], [] of String], "|", [[[[[["<op declare match>"]]]]], [] of String]]]])
      actions.create_symbol([["<op declare bnf>"]])
      actions.create_literal(["'::='"])
      actions.priority_rule([[[["<op declare bnf>"]]], ["~"], [[[[["'::='"]], [] of String]]]])
      actions.create_symbol([["<op declare match>"]])
      actions.create_literal(["'~'"])
      actions.priority_rule([[[["<op declare match>"]]], ["~"], [[[[["'~'"]], [] of String]]]])
      actions.create_symbol([["<op equal priority>"]])
      actions.create_literal(["'|'"])
      actions.priority_rule([[[["<op equal priority>"]]], ["~"], [[[[["'|'"]], [] of String]]]])
      actions.create_symbol([["<op loosen>"]])
      actions.create_literal(["'||'"])
      actions.priority_rule([[[["<op loosen>"]]], ["~"], [[[[["'||'"]], [] of String]]]])
      actions.create_symbol([["quantifier"]])
      actions.create_literal(["'*'"])
      actions.create_literal(["'+'"])
      actions.priority_rule([[[["quantifier"]]], ["::="], [[[[["'*'"]], [] of String], "|", [[["'+'"]], [] of String]]]])
      actions.create_symbol([["boolean"]])
      actions.create_character_class(["[01]"])
      actions.priority_rule([[[["boolean"]]], ["~"], [[[[[["[01]"]]], [] of String]]]])
      actions.create_symbol([["<bare name>"]])
      actions.create_character_class(["[\\w]"])
      actions.quantified_rule([[[["<bare name>"]]], ["~"], ["[\\w]"], ["+"], [] of String])
      actions.create_symbol([["<bracketed name>"]])
      actions.create_literal(["'<'"])
      actions.create_symbol([["<bracketed name string>"]])
      actions.create_literal(["'>'"])
      actions.priority_rule([[[["<bracketed name>"]]], ["~"], [[[[["'<'"], [[[["<bracketed name string>"]]]], ["'>'"]], [] of String]]]])
      actions.create_symbol([["<bracketed name string>"]])
      actions.create_character_class(["[\\s\\w]"])
      actions.quantified_rule([[[["<bracketed name string>"]]], ["~"], ["[\\s\\w]"], ["+"], [] of String])
      actions.create_symbol([["<single quoted string>"]])
      actions.create_character_class(["[']"])
      actions.create_symbol([["<string without single quote>"]])
      actions.create_character_class(["[']"])
      actions.priority_rule([[[["<single quoted string>"]]], ["~"], [[[[[["[']"]], [[[["<string without single quote>"]]]], [["[']"]]], [] of String]]]])
      actions.create_symbol([["<string without single quote>"]])
      actions.create_character_class(["[^'\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]"])
      actions.quantified_rule([[[["<string without single quote>"]]], ["~"], ["[^'\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]"], ["+"], [] of String])
      actions.create_symbol([["<regex>"]])
      actions.create_regex(["/\\/.*\\/[imx]{0,3}/"])
      actions.priority_rule([[[["<regex>"]]], ["~"], [[[[["\\/.*\\/[imx]{0,3}"]], [] of String]]]])
      actions.create_symbol([["<character class>"]])
      actions.create_literal(["'['"])
      actions.create_symbol([["<cc elements>"]])
      actions.create_literal(["']'"])
      actions.priority_rule([[[["<character class>"]]], ["~"], [[[[["'['"], [[[["<cc elements>"]]]], ["']'"]], [] of String]]]])
      actions.create_symbol([["<cc elements>"]])
      actions.create_character_class(["[^\\x5d\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]"])
      actions.quantified_rule([[[["<cc elements>"]]], ["~"], ["[^\\x5d\\x0A\\x0B\\x0C\\x0D\\x{0085}\\x{2028}\\x{2029}]"], ["+"], [] of String])
      actions.create_symbol([["<hash comment>"]])
      actions.discard_rule([":discard", "~", [[["<hash comment>"]]]])
      actions.create_symbol([["<hash comment>"]])
      actions.create_regex(["/#[^\\n]*/"])
      actions.priority_rule([[[["<hash comment>"]]], ["~"], [[[[["#[^\\n]*"]], [] of String]]]])

      return actions
    end
  end
end
