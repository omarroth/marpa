require "../../src/marpa.cr"
require "option_parser"

# Note: There is currently no way to access multiple parses of the given input,
# or to indicate precedence in the grammar, so the parse may differ significantly
# from that of something like http://nlp.stanford.edu:8080/parser/index.jsp
# This also means that it is difficult to add unknown words automagically.

grammar = File.read("english.bnf")
input = File.read("sample.english")

OptionParser.parse! do |parser|
  parser.banner = "Usage: english [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-p STRING", "--puts=STRING", "Input string") { |string| input = string }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
end

parser = Marpa::Parser.new
stack = parser.parse(grammar, input, tag = true)
stack = stack.as(Array)
stack.each do |sentence|
  sentence = sentence.as(Array)
  sentence = sentence.flatten
  sentence = sentence.join(" ")

  puts sentence
end
