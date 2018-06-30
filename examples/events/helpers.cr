class Events < Marpa::Events
  property size

  def initialize(input : String)
    @input = input
    @size = 0
  end

  def string_length(context)
    position = context.position
    length = context.values.last_value.size

    @size = @input[position - length, length].to_i
  end

  def text(context)
    position = context.position
    text = @input[position, @size]

    context.matches << {text, "text"}
  end
end
