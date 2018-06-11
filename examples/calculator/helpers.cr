class Calculator < Marpa::Actions
  def paren(context)
    context = context[1]
    context
  end

  def exponentiate(context)
    left_side = context[0].as(String).to_i
    right_side = context[2].as(String).to_i

    context = "#{left_side ** right_side}"
    context
  end

  def multiply(context)
    left_side = context[0].as(String).to_i
    right_side = context[2].as(String).to_i

    context = "#{left_side * right_side}"
    context
  end

  def divide(context)
    left_side = context[0].as(String).to_i
    right_side = context[2].as(String).to_i

    context = "#{left_side.to_f / right_side.to_f}"
    context
  end

  def add(context)
    left_side = context[0].as(String).to_i
    right_side = context[2].as(String).to_i

    context = "#{left_side + right_side}"
    context
  end

  def subtract(context)
    left_side = context[0].as(String).to_i
    right_side = context[2].as(String).to_i

    context = "#{left_side - right_side}"
    context
  end

  def reduce(context)
    context = context[0]
  end
end
