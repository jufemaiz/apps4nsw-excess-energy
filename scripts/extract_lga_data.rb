#!/usr/bin/env ruby
require 'csv'
require 'yaml'

# Extract LGA data from CSV
lgas = []
row_n = 0
header = []

File.foreach('public/csv/2010-consumption.csv') do |f|
  row_n += 1
  CSV.parse(f) do |row|
    if row_n == 1
      header = row
    elsif row_n > 1
      lga_hash = {}
      header.each_with_index do |col, i|
        lga_hash[col.downcase.gsub(' ', '_')] = row[i]
      end
      lgas << lga_hash
    end
  end
end

# Write to Jekyll data file
File.write('_data/lgas.yml', lgas.to_yaml)
puts "Extracted #{lgas.length} LGAs to _data/lgas.yml"
