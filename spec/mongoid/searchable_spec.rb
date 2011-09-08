require "spec_helper"

describe Mongoid::Searchable do

  let :city do
    City.create :name => 'New York',
                :nickname => 'The Big Apple',
                :population => 18_897_109,
                :boroughs => ['Manhattan', 'Brooklyn', 'Queens', 'The Bronx', 'Staten Island'],
                :officials => { 'Mayor' => 'Michael Bloomberg', 'Governor' => 'Andrew Cuomo' }
  end

  context 'keywords' do

    it 'exists and are accessible' do
      city.should respond_to :keywords
    end

    it 'are stored as an array' do
      city.keywords.should be_an_instance_of(Array)
    end

    it 'persist to database' do
      city.should be_an_instance_of(City)
      City.first.keywords.should include 'york'
    end

    it 'update on attribute change' do
      city.keywords.should include '18897109'
      city.update_attributes :population => 20_000_000
      city.keywords.should include '20000000'
      city.keywords.should_not include '18897109'
    end

    it 'store fields in lowercase' do
      city.keywords.to_s.should include 'manhattan'
    end

    it 'accept multi-word strings' do
      city.keywords.should include 'big'
      city.keywords.should include 'apple'
    end

    it 'accept integers' do
      city.keywords.should include '18897109'
    end

    it 'accept arrays' do
      city.keywords.should include 'staten'
    end

    it 'accept hashes' do
      city.keywords.should include 'bloomberg'
    end

    it 'can be stored in an alternate field' do
      business = Business.create :name => 'Cupcakes', :street => '123 Park Ave'
      business.should respond_to :search_fields
      business.search_fields.should include 'cupcakes'
    end

  end

  context 'indexing' do

    it 'should index the keywords field by default' do
      City.create :name => 'Los Angeles'
      City.collection.drop_indexes
      City.create_indexes
      City.collection.index_information.should have_key 'keywords_1'
    end

    it 'should not create an index if told not to' do
      Business.create :name => 'Bike Shop'
      Business.collection.drop_indexes
      Business.create_indexes
      Business.collection.index_information.should_not have_key 'search_fields_1'
    end

  end

  context 'searching' do

    before :each do
      city
    end

    it 'searches for all by default' do
      City.search('new california').length.should eql 0
    end

    it 'can search for any' do
      City.search('new california', :match => :any).length.should eql 1
    end

    it 'searches without exact word match by default' do
      City.search('Queen').length.should eql 1
    end

    it 'can search with exact word match' do
      City.search('Queen', :exact => true).length.should eql 0
      City.search('Queens', :exact => true).length.should eql 1
    end

    it 'can find more than 1 record' do
      City.create :name => 'Yorkshire'
      City.search('york').length.should eql 2
    end

    it 'can be chained to other criteria' do
      City.search('bronx').where(:population.gt => 10000).length.should eql 1
      City.search('bronx').where(:population.lt => 10000).length.should eql 0
    end

  end

end
