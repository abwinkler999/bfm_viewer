require 'sinatra'

class Room
  attr_accessor :vnum, :room_name, :description, :exits
  def initialize
    @vnum = 0;
  end
end

class GameWorld
  
  def initialize
    @area = Array.new;
    @room_section = Array.new;
    @rooms = Array.new;
  end
  
  def load_ALL_the_areas
    puts("Welcome to BFM Area Viewer");
    "Welcome to BFM Area Viewer".length.times do #too lazy to count
      print "-";
    end
    puts("\n\r");
    # begin
    read_area; # load in file
    isolate_rooms; # excerpt out rooms section of file
    read_rooms; # go through isolate and pull out all rooms
    #@rooms.each { |i| puts i.vnum.to_s + " " + i.room_name }
      #@rooms[i].room_name }
    #puts @rooms.inspect;
    #puts @rooms[12].description;
    #puts @room_section;
    #puts @area;
    # end until we run out of .are files in the directory.
  end
  
  def read_area
    content = "";
    reading_rooms = false;
    puts("Opening file ravens.are now...");
    areaFile = File.new("ravens.are", "r");
    if areaFile
      #IO.foreach("ravens.are") { |line| @area << line }
      IO.foreach(areaFile) { |line| @area << line }
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
        puts "Found rooms section...";
        reading_rooms = true;
      end
      }
  end

  def read_rooms
  
    read_line = "";
    roomsCounter = 0;
    begin
      #'#3074'
      read_line = @room_section.shift;
      if read_line.chomp == "#0" #end of ROOMS section
        break;
      end
      thisRoom = Room.new;
      room_desc_string = "";
      
      read_line = read_line.delete "#"  
      thisRoom.vnum = read_line.to_i;
      #puts "Reading room " + thisRoom.vnum.to_s + "...";
      roomsCounter += 1;
    
      #'Entrance to the Castle~'
      thisRoom.room_name = @room_section.shift.chomp.delete "~";
      #puts "It is called '" + thisRoom.room_name + "'.\n\r";
    
      #'You are standing on a gravel path which leads to the castle.'
      #'~'
      begin
        read_line = "";
        read_line << @room_section.shift;
        room_desc_string << read_line;
      end until read_line.chomp == "~"
      
      thisRoom.description = room_desc_string;
    # code to ignore exits, for now
      begin
        read_line = @room_section.shift;
      end until read_line.chomp == "S"  # end of room
      
      @rooms << thisRoom;
    end until false #ran out of rooms
    puts "Finished reading rooms.  There were " + roomsCounter.to_s + " rooms in this area.";
  end # reading rooms loop
end

# main
#Balfeymere = GameWorld.new;
#Balfeymere.load_ALL_the_areas;

get '/' do
  Balfeymere = GameWorld.new;
  Balfeymere.load_ALL_the_areas;
end
