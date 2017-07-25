require 'sinatra/base'

Dir.glob('./app/*.rb').each { |file| require file }
Dir.glob('./app/parser/*.rb').each { |file| require file }

map('/api/v1') { run RouterV1 }
