class Room
  attr_accessor :vnum, :room_name, :description, :exits
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
    if line.chomp == "#SPECIALS"
      reading_rooms = false;
    end
    if reading_rooms
      unless line == "\n"
        @room_section << line;
      end


    end
    if line.chomp == "#ROOMS"
      puts "Found rooms section...\n\r";
      reading_rooms = true;
    end

  }
end

def read_rooms
  thisRoom = Room.new;
  room_desc_string = "";
  #puts @room_section.shift;
  
  #'#3074'
  thisRoom.vnum = @room_section.shift.chomp.delete "#";
  puts "Reading room " + thisRoom.vnum + "...";
  if Integer(thisRoom.vnum) == 3074
    return 0;
  end

  #'Entrance to the Castle~'
  thisRoom.room_name = @room_section.shift.chomp.delete "~";
  puts "It is called '" + thisRoom.room_name + "'...";

  #'You are standing on a gravel path which leads to the castle.'
  #'~'
  puts "First room section is: " + @room_section[0];
  puts "Chomped it looks like: " + @room_section[0].chomp;
  begin
    #room_desc_string << @room_section.shift.chomp;
    room_desc_string << @room_section.shift;
    puts "Read in so far: " + room_desc_string;
    if room_desc_string == "#3075"
      return 0;
    end
  end while room_desc_string != "~"
  
  thisRoom.description = room_desc_string;
  
  
  @rooms << thisRoom;
=begin
  @room_section.each {|line|
    if line.start_with?("#")
      #must be vnum
      thisRoom = Room.new;
      thisRoom.vnum = line.delete "#";
      @rooms << thisRoom;
    end
  }
=end
end

# begin
@area = Array.new;
@room_section = Array.new;
@rooms = Array.new;
puts("Welcome to BFM Area Viewer");
read_area;
isolate_rooms;
read_rooms;
#puts @rooms.inspect;
#puts @rooms[0].description;
#puts @room_section;
#puts @area;