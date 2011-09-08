require 'mongoid'

module Mongoid

  module Searchable

    extend ActiveSupport::Concern

    included do
      cattr_accessor :keywords_field, :searchable_fields
    end

    module ClassMethods

      def searchable(*fields)
        options = { :as => :keywords, :index => true }.merge(fields.extract_options!)

        self.keywords_field = options[:as].to_sym
        self.searchable_fields = fields.map(&:to_s)

        field keywords_field
        index :keywords if options[:index]

        before_save :build_keywords

      end

      def search(query, options={})
        keywords = query.to_s.split(' ').map { |s| s.downcase.gsub(/[^a-z0-9]/, '') }.select { |s| s.length >= 2 }.uniq
        options[:match] ||= :all
        options[:exact] ||= false

        if options[:exact]
          match = keywords.collect{|k| /^#{Regexp.escape(k)}$/ }
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
            where()
          end
        else
          where()
        end
      end

    end

    module InstanceMethods

      def clean_keywords(value)
        words = []

        if value.is_a?(String) or value.is_a?(Numeric)
          words << value.to_s.split(' ').map { |s| s.downcase.gsub(/[^a-z0-9]/, '') }.select { |s| s.length >= 2 }
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

      def build_keywords
        keywords = []
        self.class.searchable_fields.each do |f|
          keywords << clean_keywords(send("#{f}"))
        end
        write_attribute(self.class.keywords_field, keywords.flatten.uniq)
      end

    end

  end

end
