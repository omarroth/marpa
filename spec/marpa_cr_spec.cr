require "./spec_helper"

describe Marpa do
  it "parses json" do
    # parser = Marpa::Parser.new

    # grammar = File.read("examples/json/json.bnf")
    # input = %q([1,"abc\nd\"ef",true,-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])

    # parser = Marpa::Parser.new
    # stack = parser.parse(grammar, input)
    # json = node_to_json(stack)

    # reference = JSON.parse(input)

    # json.to_s.should eq reference.to_s
  end

  it "compares generated grammar with original" do
    parser = Marpa::Parser.new

    meta_grammar = Marpa::Builder.new
    meta_grammar = parser.build_meta_grammar(meta_grammar)

    input = File.read("src/marpa/metag.bnf")

    grammar = Marpa::Builder.new
    parser.parse(input, meta_grammar, grammar)

    # grammar.symbols.should eq meta_grammar.symbols
    # grammar.rules.should eq meta_grammar.rules
  end

  it "tests precedence" do
    parser = Marpa::Parser.new

    grammar = File.read("examples/calculator/calculator.bnf")

    stack = parser.parse("(10 + 4) - 6 * 3", grammar)
    result = calculate(stack)
    result.should eq -4

    stack = parser.parse("3 * 5 + 1", grammar)
    result = calculate(stack)
    result.should eq 16
  end

  it "tests nulled rules" do
    parser = Marpa::Parser.new

    grammar = <<-END_BNF
    :start ::= S
    S ::= 'a'
    S ::= 
    END_BNF

    stack = parser.parse("", grammar)
    stack.should eq [] of String

    stack = parser.parse("a", grammar)
    stack.should eq ["a"]
  end
end
