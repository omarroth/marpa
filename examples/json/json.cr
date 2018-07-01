require "option_parser"
require "../../src/marpa"
require "./helpers"

grammar = File.read("json.bnf")
input = %q([1,"abc\nd\"ef\ufea1",true,-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])

OptionParser.parse! do |parser|
  parser.banner = "Usage: json [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-p STRING", "--puts=STRING", "Input string") { |string| input = string }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
end

parser = Marpa::Parser.new
actions = JSONActions.new
stack = parser.parse(input, grammar, actions)
json = actions.json

puts json
