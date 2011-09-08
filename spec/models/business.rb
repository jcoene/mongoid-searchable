class Business
  include Mongoid::Document
  include Mongoid::Searchable

  field :name
  field :street

  searchable :name, :street, :as => :search_fields, :index => false
end
