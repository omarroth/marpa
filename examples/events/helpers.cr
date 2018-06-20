class Events < Marpa::Events
  property size

  def initialize
    @size = 0
  end

  def string_length(context)
    input, position, length = context
    @size = input[position - length, length].to_i

    return
  end

  def text(context)
    input, position = context

    text = input[position, @size]
    return text
  end
end
