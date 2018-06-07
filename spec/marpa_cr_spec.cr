require "./spec_helper"

describe Marpa do
  it "parses json" do
    parser = Marpa::Parser.new

    grammar = File.read("examples/json/json.bnf")
    input = %q([1,"abc\nd\"ef",true,-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])

    parser = Marpa::Parser.new
    stack = parser.parse(grammar, input)
    json = node_to_json(stack)

    reference = JSON.parse(input)

    json.to_s.should eq reference.to_s
  end

  it "compares generated grammar with original" do
    parser = Marpa::Parser.new

    grammar = File.read("src/marpa/metag.bnf")
    stack = parser.parse(grammar, grammar)
    rules = parser.stack_to_rules(stack)

    rules.should eq parser.metag_grammar
  end

  it "tests precedence" do
    parser = Marpa::Parser.new

    grammar = <<-'END_BNF'
    :start ::= Script
    Script ::= Expression+ separator => comma
    comma ~ ','

    Expression ::= Number
      | Expression '*' Expression
      || Expression '+' Expression

    Number ~ [\d]+
    
    whitespace ~ [\s]+
    :discard ~ whitespace
    END_BNF

    # TODO: Update spec with actions to test result of expression
    # `1 + 2 * 3 == 7`
    stack = parser.parse(grammar, "1 + 1 * 1")
    stack.should eq [[["1"], "+", [["1"], "*", ["1"]]]]

    stack = parser.parse(grammar, "1 * 1 + 1")
    stack.should eq [[[["1"], "*", ["1"]], "+", ["1"]]]
  end

  it "tests nulled rules" do
    parser = Marpa::Parser.new

    grammar = <<-END_BNF
    :start ::= S
    S ::= 'a'
    S ::= 
    END_BNF

    stack = parser.parse(grammar, "")
    stack.should eq [] of String

    stack = parser.parse(grammar, "a")
    stack.should eq ["a"]
  end
end
