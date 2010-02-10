Dir.glob('models/shape_records/*') do |file|
  require file
end
Dir.glob('models/control_tags/*') do |file|
  require file
end

require 'advanced_file_reader.rb'
require 'tags/tag.rb'
require 'tags/tag_actions.rb'
require 'swf_math.rb'

DICTIONARY = {}

def get_dictionary
  return DICTIONARY
end

file_stream = File.open(ARGV[0], "r")
f = AdvancedFileReader.new( file_stream )

signature_1 = f.get_u8
signature_2 = f.get_u8
signature_3 = f.get_u8

if signature_1 != 'F'[0]
  raise "Please Export an Uncompressed SWF file"
end

if signature_2 != 'W'[0]
  raise "Expected second byte to be 'W'"
end

if signature_3 != 'S'[0]
  raise "Expected third byte to be 'S'"
end

version = f.get_u8

puts "Flash Version: #{version}"

num_bytes_total = f.get_u32 

puts "Num Bytes total: #{num_bytes_total}"

frame = Rect.new(f)

puts "Frame Size: #{frame.xmax/20} x #{frame.ymax/20}"

frame_rate_1 = f.get_u8
frame_rate_2 = f.get_u8
frame_rate = 0.1*frame_rate_1 + frame_rate_2
puts "Frame Rate: #{frame_rate}"

#frame_count_1 = f.getc
#frame_count_2 = f.getc
frame_count = f.get_u16#frame_count_1 + 256*frame_count_2
puts "Frame Count: #{frame_count}"

output = File.open("output/unpacked.xml", "w")
while !f.eof?
  puts "  BEGIN TAG"
  tag_code, tag_length = get_tag(f)
  
  puts "tag_len: #{tag_length}, tag code: #{tag_code}"
  
  tag = Tag.new(tag_code, tag_length, f)
  #tag.tag_code = tag_code
  #tag.tag_length = tag_length
  output.write tag.to_xml
  #handle_tag( tag_code, tag_length, f )
  #f.skip_to_next_byte
  puts "  END TAG"
  puts ""
end

f.close
output.close


# d = get_dictionary
# d.each do |key, value|
#   puts "Key: #{key}"
#   if value.is_a? Shape
#     output = File.open("output/#{key}.svg", "w")
#     output.write value.to_svg
#     output.close
#   end
# end
