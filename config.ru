require 'sinatra/base'

Dir.glob('./app/{controllers,models}/*.rb').each { |file| require file }

run UsersController