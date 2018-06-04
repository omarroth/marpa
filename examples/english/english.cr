require "../../src/marpa.cr"
require "option_parser"

grammar = File.read("english.bnf")
input = File.read("sample.english")

OptionParser.parse! do |parser|
  parser.banner = "Usage: english [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-p STRING", "--puts=STRING", "Input string") { |string| input = string }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

stack = parse(grammar, input, tag = true)
stack = stack.as(Array(RecArray))
stack.each do |sentence|
  sentence = sentence.as(Array(RecArray))
  sentence = sentence.flatten
  sentence = sentence.join(" ")

  puts sentence
end
