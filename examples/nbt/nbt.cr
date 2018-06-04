require "../../src/marpa.cr"
require "gzip"
require "zlib"

# Parser for Minecraft's NBT format http://wiki.vg/NBT

# This grammar cannot completely parse NBT because there is currently no support for
# languages that have Hollerith constants (length-prefixed values).
# For more information see http://jeffreykegler.github.io/Ocean-of-Awareness-blog/individual/2013/06/mixing-procedural.html

grammar = File.read("nbt.bnf")
# Handler for compression:
input = File.open("hello_world.nbt") do |file|
  header = file.gets(2)
  file.rewind

  case header
  when "\x78\x9c"
    # ZLib compressed
    Zlib::Reader.open(file) do |zlib|
      zlib.gets_to_end
    end
  when "\x1f\x8b"
    # GZIP compressed
    Gzip::Reader.open(file) do |gzip|
      gzip.gets_to_end
    end
  else
    # Uncompressed
    file.gets_to_end
  end
end

stack = parse(grammar, input)
puts stack
