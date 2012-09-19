class Room
  attr_accessor :vnum, :description, :exits
end

def read_area
  puts("Opening file now...")
  areaFile = File.new("ravens.are", "r");
  content = ""
  reading_rooms = false;
  if areaFile
    IO.foreach("ravens.are") { |line| @area << line }
  else
    puts "File could not be opened!"
  end
end

def isolate_rooms
  reading_rooms = false;
  @area.each {|line|
    if line.chomp == "#ROOMS"
      reading_rooms = true;
    end
    if line.chomp == "#SPECIALS"
      reading_rooms = false;
    end
    if reading_rooms
      @room_section << line;
    end
  }
end

# begin
@area = Array.new;
@room_section = Array.new;
@rooms = Array.new;
puts("Welcome to BFM Area Viewer");
read_area;
isolate_rooms;
puts @room_section;
#puts @area;