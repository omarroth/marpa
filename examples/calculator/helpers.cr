def calculate(item)
  item.delete("(")
  item.delete(")")

  if item.is_a? Array
    if item.size == 1
      item = calculate(item[0])
    elsif item.size == 3
      left_side = calculate(item[0]).as(Int32)
      operator = item[1]
      right_side = calculate(item[2]).as(Int32)

      case operator
      when "**"
        item = left_side ** right_side
      when "*"
        item = left_side * right_side
      when "/"
        item = left_side / right_side
      when "+"
        item = left_side + right_side
      when "-"
        item = left_side - right_side
      end
    end
  else
    item = item.to_i32
  end

  return item
end
