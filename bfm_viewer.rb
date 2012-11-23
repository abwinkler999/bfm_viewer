require 'sinatra'

class Room
  attr_accessor :vnum, :room_name, :description, :exits, :eds
  def initialize
    @vnum = 0;
    @exits = [0,0,0,0,0,0];
    @eds = Hash.new;
  end
end

class GameWorld
  
  def get_the_last_number(roomLine)
    returnString = ""
    roomLine.each_line(' ') { |lineSegment|
      returnString = lineSegment;
    }
    returnString;
  end
  
  def decipher_exit(exit)
    case exit
    when 0
      return "North"
    when 1
      return "East"
    when 2
      return "South"
    when 3
      return "West"
    when 4
      return "Up"
    when 5
      return "Down"
    end
  end
      
  def initialize
    @room_section = Array.new;
    @rooms = Array.new;
  end
  
  def load_ALL_the_areas
    masterReturnString = ""
    Dir.foreach("area") { |some_area|
      if some_area.include? ".are" # only mud areas, please
        #current_areaFile = File.new(some_area);
        masterReturnString << load_an_area("area/" + some_area)
      end
    }
    return masterReturnString
  end
  
  def load_an_area(currentAreaFile)
    # begin
    @area = Array.new;
    read_area(currentAreaFile); # load in file
    isolate_rooms; # excerpt out rooms section of file
    read_rooms; # go through isolate and pull out all rooms
    # end ...until we run out of .are files in the directory.
    return_string = "";
    #@rooms.sort!
    @rooms.each { |i| 
      return_string << '<div><p><h3>#<a name="' + i.vnum.to_s + '">' + i.vnum.to_s + " " + i.room_name + "</h3></p>";
      return_string << '<p>' + i.description + '</p>';
      return_string << '<p>Exits: '
      i.exits.each_with_index {|exit, index|
        if exit == 0
          next;
        end
        return_string << '<span class="exit">' + decipher_exit(index) + ' to '
        return_string << '<a href="#' + exit.to_s + '">' + exit.to_s + "</a></span>"
      }
      return_string << '</p>'
      if i.eds.empty? == false
        return_string << '<p>Extra descriptions: ';
        i.eds.each {|key, value|
          return_string << '<span class="eds" title="' + value + '">' + key + "</span>";
        }
      end
      return_string << '</div>';
    }
    return return_string;
  end
  
  def read_area(currentAreaFile)
    reading_rooms = false;
    areaFile = File.new(currentAreaFile);
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
      $stdout << "Attempting to load exit for room " + thisRoom.vnum.to_s + "\n\r"; 
      begin # scanning for exits loop
        read_line = "";
        read_line << @room_section.shift; #D2
        $stdout << "D?  " + read_line + "\n\r";
        if read_line.chomp == "S" # handling nonexit data
          break; # ran out of exits
        elsif read_line.chomp[0] == "M" # Mana/healing rate bonuses
          $stdout << "Skipping mana/healing rates in room " + thisRoom.vnum.to_s + "\n\r"
          next; #carry on
        elsif read_line.chomp == "E" #extended room description!  ack
          #just like room descriptions
          $stdout << "There's an extended room description here.\n\r";
          i = 0; #REMOVE
          edOver = false;
          ed_desc = "";
          ed_name = @room_section.shift.chomp.delete "~"
          $stdout << "Recorded extended description called: " + ed_name + "\n\r";
          begin #read in lines, throw them away
            read_line = @room_section.shift;
            i = i + 1;
            if read_line.chomp == "~"
              break;
            end
            ed_desc << read_line;
          #end until false # end reading description lines loop
          end until (i > 25)
          thisRoom.eds[ed_name] = ed_desc;
          $stdout << "Description was: " + ed_desc + "\n\r";
          next; #keep going looking for exits
        end # handling nonexit data
        exitNum = Integer(read_line[1]);  #i.e. the "2"
        $stdout << "OK, valid exit in direction " + decipher_exit(exitNum) + "\n\r"
        2.times {@room_section.shift} # 2x ~
        read_line = @room_section.shift.chomp! #0 0 3036
        if (read_line[0] != "0" && read_line[0] != "1" && read_line[0] != "2" && read_line[0] != "9" && read_line[0..1] != "AB")# might have exit description, feh, skip line
          $stdout << "Had to skip " + read_line;
          read_line = @room_section.shift.chomp!
        end
        #read_line.slice!(0..5);
        #thisRoom.exits[exitNum] = Integer(read_line);
        $stdout << "Looks like exit is to " + get_the_last_number(read_line) + "\n\r"
        $stdout << "Inserting at " + decipher_exit(exitNum) + " vnum " + get_the_last_number(read_line) + "\n\r"
        thisRoom.exits[exitNum] = Integer(get_the_last_number(read_line))
        
      end until false # scanning for exits loop
      $stdout << "Finished reading exits for " + thisRoom.vnum.to_s + "\n\r"
     
      @rooms << thisRoom;
      
    end until false # main reading loop
    $stdout << "Finished reading rooms.  There were " + roomsCounter.to_s + " rooms in this area.\n\r"
  end # read_rooms method
end #class

# begin Sinatra executable
get '/' do
  @Balfeymere = GameWorld.new;
  erb :bfm_viewer
end