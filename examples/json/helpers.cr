class JSONActions < Marpa::Actions
  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(String, Type)
  property json

  def initialize
    @stack = [] of Type
  end

  def json
    return @stack[0]
  end

  def do_string(context)
    body = context[1].as(String)

    body = body.gsub("\\'", "'")
    body = body.gsub("\\\"", "\"")
    body = body.gsub("\\/", "/")
    body = body.gsub("\\\\", "\\")
    body = body.gsub("\\n", "\n")
    body = body.gsub("\\r", "\r")
    body = body.gsub("\\t", "\t")
    body = body.gsub("\\b", "\b")
    body = body.gsub("\\f", "\f")
    body = body.gsub("\\v", "\v")
    body = body.gsub("\\0", "\0")
    body = body.gsub(/\\u[a-zA-Z0-9]{4}/) do |s|
      s.lchop("\\u").to_u32(base = 16).unsafe_chr
    end

    @stack << body
    ""
  end

  def do_number(context)
    body = context[0].as(String)

    number = body.to_i64?
    number ||= body.to_f64?

    @stack << number
    ""
  end

  def do_object(context)
    body = context[1].as(Array)
    body.delete ","

    object = {} of String => Type

    body = @stack.pop(body.size * 2)
    body.each_slice(2) do |pair|
      key, value = pair
      key = key.as(String)

      object[key] = value
    end

    @stack << object
    ""
  end

  def do_array(context)
    body = context[1].as(Array)
    body.delete ","

    array = [] of Type

    body = @stack.pop(body.size)
    body.each do |element|
      array << element
    end

    @stack << array
    ""
  end

  def do_null(context)
    @stack << nil
    ""
  end

  def do_true(context)
    @stack << true
    ""
  end

  def do_false(context)
    @stack << false
    ""
  end
end
