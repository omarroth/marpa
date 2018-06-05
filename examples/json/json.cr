require "../../src/marpa.cr"
require "option_parser"
require "json"

# Alias (almost) identical to that used in the standard library
alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(String, Type)

grammar = File.read("json.bnf")
input = %q([1,"abc\nd\"ef",-2.3,null,[],[1,2,3],{},{"a":1,"b":2}])

OptionParser.parse! do |parser|
  parser.banner = "Usage: json [arguments]"
  parser.on("-i FILE", "--input=FILE", "Input file") { |file| input = File.read(file) }
  parser.on("-p STRING", "--puts=STRING", "Input string") { |string| input = string }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

stack = parse(grammar, input)
json = node_to_json(stack)

reference = JSON.parse(input)

# Note here that the generated json and reference are not of exactly the same type.
# Because of this json == reference is false even though they are still represented
# the same internally.
puts "JSON parse is identical to that of the standard lib? #{json.to_s == reference.to_s}"
puts json

def node_to_json(node)
  if node.is_a?(Array)
    if node[0]?.try &.== "["
      output = [] of Type

      body = node[1].as(Array(RecArray))
      body.delete(",")

      body.each do |leaf|
        output << node_to_json(leaf).as(Type)
      end
    elsif node[0]?.try &.== "{"
      output = {} of String => Type

      body = node[1].as(Array(RecArray))
      body.delete(",")

      body.each do |leaf|
        key = node_to_json(leaf[0]).as(String)
        value = node_to_json(leaf[2]).as(Type)

        output[key] = value
      end
    else
      output = node_to_json(node[0])
    end
  elsif node == "null"
    output = nil
  elsif node == "true"
    output = true
  elsif node == "false"
    output = false
  elsif node =~ /^-?[\d]+[.\d+]*/
    output = node.to_i64?
    output ||= node.to_f64?
  else
    output = node.as(String)
    output = output[1..-2]

    output = output.gsub("\\'", "'")
    output = output.gsub("\\\"", "\"")
    output = output.gsub("\\\\", "\\")
    output = output.gsub("\\n", "\n")
    output = output.gsub("\\r", "\r")
    output = output.gsub("\\t", "\t")
    output = output.gsub("\\b", "\b")
    output = output.gsub("\\f", "\f")
    output = output.gsub("\\v", "\v")
    output = output.gsub("\\0", "\0")
  end

  return output
end
