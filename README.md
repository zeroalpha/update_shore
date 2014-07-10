Description
============

A Ruby Script which downloads a Playlist from Youtube using youtube-dl to a folder
and creates a playlist file.

Once a playlist files exists, it will only download new videos from the youtube playlist

    ruby update_shore.rb -d <download_directory>

The only Advantage over using youtube-dl directly is, that it is NOT trying to download the entire playlist every time it is run

Todo
============
- useful parametermanagement
  - ~~variable playlist-url~~
  - variable video quality
- ~~decide whether to initialize or update a directory on existence of a playlist-file (m3u/m3u8)~~
