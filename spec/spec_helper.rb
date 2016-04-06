ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

Dir.glob('./app/{controllers}/*.rb').each { |file| require file }

include Rack::Test::Methods