# frozen_string_literal: true

require 'csv'

module Scraped
  module Wikipedia
    # An extension to Scraped to represent a CSV version of a Wikipedia page
    class OfficeHolders
      def initialize(confighash)
        @url, @klass = confighash.to_a.first
      end

      def to_csv
        fields.to_csv + results.map { |row| row.values.to_csv }.join
      end

      private

      attr_reader :url, :klass

      def scraper
        @scraper ||= klass.new(response: Scraped::Request.new(url: url).response)
      end

      def results
        @results = scraper.officeholders
      end

      def fields
        results[1].keys
      end
    end
  end
end
