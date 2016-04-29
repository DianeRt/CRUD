ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'
require 'database_cleaner'

Dir.glob('./app/{controllers,models}/*.rb').each { |file| require file }

include Rack::Test::Methods
DatabaseCleaner.strategy = :transaction