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

def read_rooms
  @room_section.each {|line|
    if line.start_with?("#")
      #must be vnum
      thisRoom = Room.new;
      thisRoom.vnum = line.delete "#";
      @rooms << thisRoom;
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
read_rooms;
puts @rooms;
#puts @room_section;
#puts @area;