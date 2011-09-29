require 'mongoid'

module Mongoid

  module Searchable

    extend ActiveSupport::Concern

    included do
      cattr_accessor :keywords_field, :searchable_fields
    end

    module ClassMethods

      # Defines the environment for searching this document,
      # typically called from within your model declaration.
      #
      # fields - Array, mix of references to the fields
      #  you would like to index and any *options*.
      #
      # options - Hash, list of options for keyword indexing:
      #
      #   :as - String, field to store keywords in.
      #   :index - Boolean, turn indexing on or off.
      #
      # Example:
      #
      # class Person
      #   include Mongoid::Document
      #   include Mongoid::Searchable
      #   field :name
      #   searchable :name
      # end
      #
      # Returns nothing.
      def searchable(*fields)
        options = { :as => :keywords, :index => true }.merge(fields.extract_options!)

        self.keywords_field = options[:as].to_sym
        self.searchable_fields = fields.map(&:to_s)

        field keywords_field
        index :keywords if options[:index]

        before_save :build_keywords

      end

      # Search for documents matching your query, given the previously
      # defined keyword fields.
      #
      # query - Integer, String, Array, Hash representing the query
      #  you wish to perform. This will be reduced to a string, sanitized
      #  and then split into keywords used for matching.
      #
      # options - Hash, containing options used for the query:
      #
      #   :match - Symbol, :all or :any, how to match results.
      #   :exact - Boolean, require exact word match (or not).
      #
      # Returns Mongoid::Criteria.
      def search(query, options={})
        keywords = clean_keywords(query)
        options[:match] ||= :all
        options[:exact] ||= false

        if options[:exact]
          match = keywords
        else
          match = keywords.collect{|k| /#{Regexp.escape(k)}/ }
        end

        raise "Please define one or more fields as searchable before attempting to search." if keywords_field.nil? or searchable_fields.nil?

        if keywords.any?
          if options[:match].to_sym == :all
            all_in(keywords_field.to_sym => match)
          elsif options[:match].to_sym == :any
            any_in(keywords_field.to_sym => match)
          else
            raise "Please specify either :all or :any to match."
          end
        else
          where()
        end
      end

      # Takes a String, Numeric, Array or Hash and reduces it to a
      # sanitized array of keywords, recursively if necessary.
      #
      # value - String, Numeric, Array or Hash of data to sanitize.
      #
      # Returns Array.
      def clean_keywords(value)
        words = []

        if value.is_a?(String) or value.is_a?(Numeric)
          words << value.to_s.downcase.gsub(/<\/?[^>]*>/, '').split(' ').map { |s| s.gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, '') }.select { |s| s.length >= 2 }
        elsif value.is_a?(Array) && value.any?
          value.each do |v|
            words << clean_keywords(v)
          end
        elsif value.is_a?(Hash) && value.any?
          value.each do |k,v|
            words << clean_keywords(v)
          end
        end

        words.flatten.uniq
      end

    end

    module InstanceMethods

      # Builds a list of keywords contained in the document given the
      # keyword fields previously declared and stores them in the
      # keywords field
      #
      # Returns nothing.
      def build_keywords
        keywords = []
        self.class.searchable_fields.each do |f|
          keywords << self.class.clean_keywords(send("#{f}"))
        end
        write_attribute(self.class.keywords_field, keywords.flatten.uniq)
      end

    end

  end

end
