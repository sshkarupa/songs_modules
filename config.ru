#\ -w -o 0.0.0.0 -p 3000
require 'sinatra/base'

require './app.rb'
require './main.rb'
require './song.rb'

map('/songs') { run SongController }
map('/') { run Website }
