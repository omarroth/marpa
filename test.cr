n = 1
loop do
  time = Time.now

  input = "a"*2*n

  regex = ""
  regex += "a\?"*n
  regex += "a"*n

  regex = /#{regex}/

  regex.match(input)

  STDOUT << Time.now - time << " " << n << "\n"
  n += 1
end
