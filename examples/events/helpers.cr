class Events < Marpa::Events
  property size

  def initialize(input : String)
    @input = input
    @size = 0
  end

  def string_length(context)
    position, length = context
    @size = @input[position - length, length].to_i

    return
  end

  def text(context)
    position = context[0]

    text = @input[position, @size]
    return {text, "text"}
  end
end
