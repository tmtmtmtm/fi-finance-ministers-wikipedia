# frozen_string_literal: true

require_relative './wikipedia_table_row'

# A Row in a Wikipedia Table of Officeholders
class WikipediaOfficeholderRow < WikipediaTableRow
  field :id do
    wikidata_ids_in(name_cell).first
  end

  field :name do
    link_titles_in(name_cell).first
  end

  field :start_date do
    return unless start_date_str

    dateclass.new(start_date_str).to_ymd
  end

  field :end_date do
    return unless end_date_str

    dateclass.new(end_date_str).to_ymd
  end

  field :replaces do
  end

  field :replaced_by do
  end

  field :cabinet do
    wikidata_ids_in(cabinet_cell).first
  end

  field :cabinetLabel do
    link_titles_in(cabinet_cell).first
  end

  private

  def name_cell
    tds[columns.index('name')]
  end

  def cabinet_cell
    tds[columns.index('cabinet')]
  end
end
