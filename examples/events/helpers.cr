class Events < Marpa::Events
  property size

  def initialize
    @size = 0
  end

  def string_length(context)
    @size = context.values.last_value.to_i
  end

  def text(context)
    position = context.position
    text = context.input[position, @size]

    context.matches << {text, "text"}
  end
end
