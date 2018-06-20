require "option_parser"
require "../../src/marpa"
require "./helpers"

grammar = File.read("events.bnf")
input = %q(A2(A2(S3(Hey)S13(Hello, World!))S5(Ciao!)))

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
events = Events.new
puts parser.parse(input, grammar, events: events)
