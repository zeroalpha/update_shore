#!/usr/bin/env ruby

unless %w{-i -u}.index(ARGV[0]) && ARGV[1]
  puts "update_shore.rb <action> <folder> [playlist_name]"
  puts "-i  Initialize Folder"
  puts "-u  Update Folder"
  exit
end

Dir.chdir ARGV[1]

PLAYLIST_FILE = ARGV[2] || "1AAList.m3u8"
NUMBER_RX = /\-\-(\d+)\-\-/
PLAYLIST = "http://www.youtube.com/watch?list=PLpr-NGsAGodEbDePSO3wivni39lgdLQjW"

#Reading Playlist to enable continuing from the end of the list
num = "nothing"
if File.exists? PLAYLIST_FILE then
  print "looking for last video ... "
  list = File.read PLAYLIST_FILE
  list.each_line do |line|
    m = line.match(NUMBER_RX)
    if m then
      m = m[1].to_i
      num = m if m > num.to_i
    end
  end
  puts "Found #{num}"
end


command = case ARGV[0]
          when "-i"
            "youtube-dl -f 18 -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{PLAYLIST}"
          when "-u"
            puts "No Playlist found" and exit if num == "nothing"
            "youtube-dl -f 18 --playlist-start #{num} -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{PLAYLIST}"
          else
            puts "Action needs to be -u or -i"
            exit
          end

puts "Starting youtube-dl"
io = IO.popen command

until io.eof?
  puts io.readline
end

puts "Sorting files"
#Gathering all Files in the working directory
files = Dir.glob("./*")

#evaluates to nil for every element which doesn't match NUMBER_RX
files.map! do |f|
  if m = f.match(NUMBER_RX)
    [m[1],f]
  end
end

files.delete nil
files.sort_by!{|f| f[0].to_i}

puts "Creating playlist"
s = ""
#binding.pry
files.each do |f|
  s << f[1] << "\n"
end

File.write PLAYLIST_FILE,s
