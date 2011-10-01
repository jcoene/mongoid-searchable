# Mongoid Searchable

Mongoid Searchable provides simple field search for your Mongoid models using the full-text search technique described in the [MongoDB documentation](http://www.mongodb.org/display/DOCS/Full+Text+Search+in+Mongo).

[![travis](https://secure.travis-ci.org/jcoene/mongoid-searchable.png)](http://travis-ci.org/jcoene/mongoid-searchable)

## 0.1.x Compatibility

Please note that version **0.2.0 has renamed the *search* method to *text_search* to avoid naming issues**. Sorry for the inconvenience but given the issues this can cause and limited alternative solutions, I figured that it would be prudent to make this change sooner rather than later.

## Getting Started

First, add mongoid-searchable to your Gemfile:

```ruby
gem 'mongoid-searchable'
```

Next, include the module and tell it how to search your model:

```ruby
class City
  include Mongoid::Document
  include Mongoid::Searchable

  field :name, :type => String
  field :population, :type => Integer
  field :boroughs, :type => Array
  field :officials, :type => Hash

  searchable :name, :population, :boroughs, :officials
end
```

You can now use the *search* method on your model to find what you're looking for:

```ruby
# Create a few example cities
City.create :name => 'New York, NY', :population => 18_897_109,
            :boroughs => ['Manhattan', 'Brooklyn', 'Queens', 'The Bronx', 'Staten Island'],
            :officials => { 'Mayor' => 'Michael Bloomberg', 'Governor' => 'Andrew Cuomo' }
City.create :name => 'Rochester, NY', :population => 1_098_201,
            :officials => { 'Mayor' => 'Thomas Richards', 'Governor' => 'Andrew Cuomo' }
City.create :name => 'Rochester, MN', :population => 186_011,
            :officials => { 'Mayor' => 'Ardell Brede', 'Governor' => 'Mark Dayton' }

City.text_search('ny')        # => 2 records
City.text_search('rochester') # => 2 records
City.text_search('manhattan') # => 1 record
```

You can also choose to match all or any tokens. The default is to match **all** terms:

```ruby
City.text_search('rochester ny')                 # => 1 record (defaults to all)
City.text_search('rochester ny', :match => :any) # => 3 records
```

We can match partial or exact words as well. The default is to match **partial** words:

```ruby
City.text_search('roch')                 # => 2 records
City.text_search('roch', :exact => true) # => 0 records
```

You can chain other criteria on to your search, as per Mongoid convention:

```ruby
City.text_search('ny').where(:population.gt => 2_000_000)      # => 1 record
City.text_search('rochester').where(:population.lt => 500_000) # => 1 record
```

## Customization

You can also pass additional arguments to *searchable* to provide more control over the behavior.

**Changing the field name:** You can specify the field to use for keyword storage using **as**. The default is to use the *keywords* field:

```ruby
class Person
  ...
  searchable :name, :as => :search_fields
  ...
end
```

**Turning off indexing:** You can also turn off indexing on your keyword field using **index**. This isn't recommended and defaults to *on*:

```ruby
class Person
  ...
  searchable :name, :index => false
  ...
end
```

## Enhancements and Pull Requests

If you find the project useful but it doesn't meet all of your needs, feel free to fork it and send a pull request.

## License

MIT license, go wild.
