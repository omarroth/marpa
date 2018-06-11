require "option_parser"
require "../../src/marpa"
require "./helpers"

grammar = File.read("calculator.bnf")
input = "5 * (3 + 2)"

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
actions = Calculator.new
result = parser.parse(input, grammar, actions)
puts result
