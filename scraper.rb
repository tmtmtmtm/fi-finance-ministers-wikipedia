#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/date_dotted'
require_relative 'lib/date_partial'
require_relative 'lib/unspan_all_tables'
require_relative 'lib/wikipedia_table_row'
require_relative 'lib/remove_notes'

# The Wikipedia page with a list of officeholders
class ListPage < Scraped::HTML
  decorator RemoveNotes
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  field :officeholders do
    office_holders_with_replacements
  end

  private

  def list
    noko.xpath('.//table[.//th[contains(
      translate(., "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"),
    "hallitus")]]').first
  end

  def raw_office_holders
    @raw_office_holders ||= begin
      list.xpath('.//tr[td]').map { |td| fragment(td => HolderItem) }.reject(&:empty?).map(&:to_h).uniq(&:to_s)
    end
  end

  def office_holders_with_replacements
    raw_office_holders.each_cons(2) do |prev, cur|
      cur[:replaces] = prev[:id]
      prev[:replaced_by] = cur[:id]
    end
    raw_office_holders
  end
end


# Each officeholder in the list
class HolderItem < WikipediaTableRow
  field :id do
    wikidata_ids_in(tds[1]).first
  end

  field :name do
    link_titles_in(tds[1]).first
  end

  field :start_date do
    dates[0]
  end

  field :end_date do
    dates[1]
  end

  field :replaces do
  end

  field :replaced_by do
  end

  field :cabinet do
    wikidata_ids_in(tds[4]).first
  end

  field :cabinetLabel do
    link_titles_in(tds[4]).first
  end

  def empty?
    tds[0].text.to_i.zero?
  end

  private

  def dates
    tds[3].text.tidy.split(/\s*–\s*/).map { |str| Date::Dotted.new(str).to_ymd }
  end
end

url = ARGV.first || abort("Usage: #{$0} <url to scrape>")
data = Scraped::Scraper.new(url => ListPage).scraper.officeholders

header = data[1].keys.to_csv
rows = data.map { |row| row.values.to_csv }
puts header + rows.join
