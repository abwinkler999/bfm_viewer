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
    if content = "#ROOMS"
      reading_a_room = true;
    end
  else
    puts "File could not be opened!"
  end
end

def scrape_rooms
  @area.each {|line|
    if line == "#ROOMS"
      reading_rooms = true;
    end
    if reading_rooms
    end
  }
end

# begin
@area = Array.new;
@rooms = Array.new;
puts("Welcome to BFM Area Viewer");
read_area;
scrape_rooms;
#puts @area;