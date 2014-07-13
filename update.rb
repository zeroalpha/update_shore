#!/usr/bin/env ruby

require 'optparse'
require 'pp'
require 'pry'

NUMBER_RX = /\-\-(\d+)\-\-/

options = {
  verbose: false,
  playlist_file: "1AAList.m3u8",
  playlist_url: "http://www.youtube.com/watch?list=PLpr-NGsAGodEbDePSO3wivni39lgdLQjW",
  action: :update,
  playlist_index_start: nil,
  playlist_index_stop: nil
}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-d DIRECTORY","--directory DIRECTORY", "Specify a Download Directory") do |d|
    options[:dir] = d
  end

  opts.on("-f NAME", "--playlist-file NAME", "Specify a NAME for the *.m3u file") do |f|
    options[:playlist_file] = f
  end

  opts.on("-pl PLAYLIST", "--playlist-url PLAYLIST", "Specify a PLAYLIST to download") do |pl|
    options[:playlist_url] = pl
  end

  opts.on("--pl-start INDEX",Integer, "Begin downloading of the playlist at the specified INDEX") do |pl_start|
    options[:playlist_index_start] = pl_start
  end

  opts.on("--pl-stop INDEX",Integer, "End downloading of the playlist at the specified INDEX") do |pl_stop|
    options[:playlist_index_stop] = pl_stop
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

end.parse!

if options[:verbose]
  pp options
  pp ARGV
end

if options[:dir] then
  Dir.chdir options[:dir]
else
  puts "Need a directory"
  exit 1
end

possible_playlist_files = Dir.glob "*.m3u*"
if possible_playlist_files.size > 0
  PLAYLIST_FILE = possible_playlist_files[0]
end

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
else
  options[:action] = :init
  puts "No Playlist found"
end

PLAYLIST_FILE = options[:playlist_file] unless options[:playlist_file] == "1AAList.m3u8"

command = case options[:action]
          when :init
            "youtube-dl -f 18 -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{options[:playlist_url]}"
          when :update
            puts "No Playlist found" and exit if num == "nothing"
            "youtube-dl -f 18 --playlist-start #{num} -o \"%(title)s--%(playlist_index)s--%(id)s.%(ext)s\"  #{options[:playlist_url]}"
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

puts "Creating playlist #{PLAYLIST_FILE}"
s = ""
#binding.pry
files.each do |f|
  s << f[1] << "\n"
end

File.write PLAYLIST_FILE,s
