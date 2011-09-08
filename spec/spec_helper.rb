require "rubygems"
require "bundler/setup"

require "rspec"

require File.expand_path("../../lib/mongoid/searchable", __FILE__)

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('mongoid-searchable-test')
end

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
