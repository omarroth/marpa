require "./lib_marpa"

class Methods
  def addone(x : Int32)
    return x + 1
  end
end

actions = Methods.new
list = {"addone" => ->(x : Int32) { actions.addone(10) }}

puts list["addone"].call(10)
