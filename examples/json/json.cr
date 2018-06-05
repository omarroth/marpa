require "json"
require "option_parser"
require "../../src/marpa"
require "./helpers"

grammar = File.read("json.bnf")
input = %q([1,"abc\nd\"ef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])

OptionParser.parse! do |parser|
  parser.banner = "Usage: json [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-p STRING", "--puts=STRING", "Input string") { |string| input = string }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

parser = Marpa::Parser.new
stack = parser.parse(grammar, input)
json = node_to_json(stack)

reference = JSON.parse(input)

# Note here that the generated json and reference are not of exactly the same type.
# Because of this json == reference is false even though they are still represented
# the same internally.
puts "JSON parse is identical to that of the standard lib? #{json.to_s == reference.to_s}"
