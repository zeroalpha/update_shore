#require 'pry'

unless ARGV[0] && ARGV[1]
  puts "update_shore.rb <action> <folder>"
  puts "-i  Initialize Folder"
  puts "-u  Update Folder"
  exit
end

Dir.chdir ARGV[1]

PLAYLIST = "1AAList.m3u8"
NUMBER_RX = /\-\-(\d+)\-\-/

print "looking for last video ... "
list = File.read PLAYLIST
num = "nothing"
list.each_line{|line| m = line.match(NUMBER_RX) ; num = m[1].to_i if m}
puts "Found #{num}"

list = "http://www.youtube.com/watch?list=PLpr-NGsAGodEbDePSO3wivni39lgdLQjW"
puts "Updating Video Files"
#youtube_log = `youtube-dl -f 18 #{list}`

command = case ARGV[0]
  when "-i" 
    "youtube-dl -f 18 -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{list}"
  when "-u" 
    puts "No Playlist found" and exit if num == "nothing"
    "youtube-dl -f 18 --playlist-start #{num} -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{list}"
  else
    exit
  end

io = IO.popen command

until io.eof? 
  puts io.readline
end

#File.write "youtube-dl.log",youtube_log
puts "Sorting files"
files = Dir.glob("./*")
#Shore, Stein, Papier #26 - Der Ägypter-zYX_BPTV38g.mp4
files.map! do |f|
  if m = f.match(NUMBER_RX) then
    f = [m[1].to_i,f]
  else
    f = [9999,f] 
  end
  f
end

files.sort_by!{|x| x[0]}

puts "Creating playlist"
s = ""
files.each do |f|
  s << f[1] << "\n"
end

File.write "1AAList.m3u8",s
