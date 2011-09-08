class City
  include Mongoid::Document
  include Mongoid::Searchable

  field :name, :type => String
  field :nickname, :type => String
  field :population, :type => Integer
  field :boroughs, :type => Array
  field :officials, :type => Hash

  searchable :name, :nickname, :population, :boroughs, :officials
end
