require 'sinatra'

class Room
  attr_accessor :vnum, :room_name, :description, :exits
  def initialize
    @vnum = 0;
    @exits = [0,0,0,0,0,0];
  end
end

class GameWorld
  
  def initialize
    @area = Array.new;
    @room_section = Array.new;
    @rooms = Array.new;
  end
  
  def load_ALL_the_areas
    # begin
    read_area; # load in file
    isolate_rooms; # excerpt out rooms section of file
    read_rooms; # go through isolate and pull out all rooms
    # end ...until we run out of .are files in the directory.
    return_string = "";
    @rooms.each { |i| 
      return_string << '<p><h3>#<a name="' + i.vnum.to_s + '">' + i.vnum.to_s + " " + i.room_name + "</h3></p>";
      return_string << "<p>" + i.description + "</p>";
      return_string << "<p>Exits: "
      i.exits.each {|room|
        if room == 0
          next;
        end
        return_string << '<a href="#' + room.to_s + '">' + room.to_s + "</a> "
      }
      return_string << "</p>";
    }
    return return_string;
  end
  
  def read_area
    content = "";
    reading_rooms = false;
    areaFile = File.new("./area/ravens.are", "r");
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
        reading_rooms = true;
      end
      }
  end

  def read_rooms
    
    read_line = "";
    roomsCounter = 0;
    exitNum = 0;
    edOver = false;
    begin # main reading loop
      #'#3074'
      read_line = @room_section.shift;
      if read_line.chomp == "#0" # must be the end of the ROOMS section
        break;
      end
      thisRoom = Room.new;
      room_desc_string = "";
      
      read_line = read_line.delete "#"  
      thisRoom.vnum = read_line.to_i;
      roomsCounter += 1;
    
      #'Entrance to the Castle~'
      thisRoom.room_name = @room_section.shift.chomp.delete "~";
    
      #'You are standing on a gravel path which leads to the castle.'
      #'~'
      begin # reading description lines loop
        read_line = "";
        read_line << @room_section.shift;
        if read_line.chomp == "~"
          break;
        end
        room_desc_string << read_line;
      end until false # end reading description lines loop
      
      thisRoom.description = room_desc_string;

    # I don't remember what the next line does.  It's always just "0 0 1" in the file.
      read_line = @room_section.shift;
    
    # now to read exits
    # typical section:
    #  D1
    #  ~
    #  ~
    #  0 0 3036
      $stdout << "Beginning an exit for room " + thisRoom.vnum.to_s + "\n\r"; 
      begin # scanning for exits loop
        read_line = "";
        read_line << @room_section.shift; #D2
        $stdout << "D?  " + read_line + "\n\r";
        if read_line.chomp == "S" # handling nonexit data
          break; # ran out of exits
        elsif read_line.chomp[0] == "M" # I don't even remember what these are
          next; #carry on
        elsif read_line.chomp == "E" #extended room description!  ack
          #bugger these things
          $stdout << "stupid ed";
          edOver = false;
          @room_section.shift; # read and discard edesc name
          
          begin #read in lines, throw them away
            ; # do nothing
          end until @room_section.shift.chomp == "~"
          
          next; #keep going looking for exits
        end # handling nonexit data
        $stdout << "OK, valid exit in direction " + read_line[1] + "\n\r"
        exitNum = Integer(read_line[1]);  #i.e. the "2"
        2.times {@room_section.shift} # 2x ~
        read_line = @room_section.shift.chomp! #0 0 3036
        if (read_line[0] != "0" && read_line[0] != "1" && read_line[0] != "2")# might have exit description, feh, skip line
          $stdout << "Had to skip " + read_line;
          read_line = @room_section.shift.chomp!
        end
        #read_line.slice!(0..5);
        #thisRoom.exits[exitNum] = Integer(read_line);
        $stdout << "Looks like exit is to " + read_line[-4,4] + "\n\r"
        $stdout << "Inserting at " + exitNum.to_s + " vnum " + read_line[-4, 4] + "\n\r" 
        thisRoom.exits[exitNum] = Integer(read_line[-4, 4]) #cheating -- not all vnums 4 digits
      end until false # scanning for exits loop
      $stdout << "Finished reading exits for " + thisRoom.vnum.to_s
     
      @rooms << thisRoom;
      
    end until false # main reading loop
    $stdout << "Finished reading rooms.  There were " + roomsCounter.to_s + " rooms in this area."
  end # read_rooms method
end #class

# begin Sinatra executable
get '/' do
  Balfeymere = GameWorld.new;
  erb '<%=Balfeymere.load_ALL_the_areas %>'
end