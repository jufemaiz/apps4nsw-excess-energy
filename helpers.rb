# frozen_string_literal: true

require 'csv'
require 'sinatra'

# Helpers!
helpers Sinatra::Partials

helpers do
  ALLOWED_SORT_KEYS = %i[
    residential_energy
    residential_controlled_load_energy
    large_business_energy
    small_business_energy
  ]
  ALLOWED_NORMALISE_KEYS = %i[
    population
    residential_customers
  ]
  # Sorts an array of lgas by a given key. Returns existing if the keys are
  # not valid (nil is valid `:normalised_by` value)
  #
  # @param [Array<LGA>] lgas
  # @param [Symbol] sort_by
  # @param [Symbol] normalised_by
  # @return [Array<LGA>]
  def sort_lgas_by(lgas, sort_by, normalised_by = nil)
    if !ALLOWED_SORT_KEYS.include?(sort_by) ||
      (normalised_by && !ALLOWED_NORMALISE_KEYS.include?(normalised_by))
      return lgas
    end

    if normalised_by
      return lgas.sort do |x, y|
        (y.send(sort_by) / y.send(normalised_by)) <=>
          (x.send(sort_by) / x.send(normalised_by))
      end
    end
    lgas.sort{ |x,y| y.send(sort_by) <=> x.send(sort_by) }
  end

  def get_lgas
    row_number = 0
    lgas_header = []
    lgas = []

    # For each line
    IO.foreach('public/csv/2010-consumption.csv') do |f|
      row_number += 1
      if row_number == 1
        CSV.parse(f) do |row|
          lgas_header = row
        end
      elsif row_number > 1
        CSV.parse(f) do |row|
          lgas.push LGA.new(lgas_header, row)
        end
      end
    end
    # Return the lgas
    lgas
  end

  # For a given set of lgas, return a hash of max/mins
  def lgas_stats(lgas)
    lgas_max_mins = nil
    unless lgas.nil? || lgas.empty?
      lgas_max_mins = { total: { energy: nil, customers: nil, population: nil }, residential: { total: { energy: nil, customers: nil }, normal: { energy: nil, customers: nil }, controlled_load: { energy: nil, customers: nil } }, business: { total: { energy: nil, customers: nil }, small: { energy: nil, customers: nil }, large: { energy: nil, customers: nil } } }
      # Totals
      lgas_max_mins[:total][:energy] = max_min_average_median(@lgas.collect(&:total_energy))
      lgas_max_mins[:total][:customers] = max_min_average_median(@lgas.collect(&:total_customers))
      lgas_max_mins[:total][:population] = max_min_average_median(@lgas.collect(&:population))
      lgas_max_mins[:total][:per_customer] = max_min_average_median(@lgas.collect(&:total_energy_per_customer))
      lgas_max_mins[:total][:per_resident] = max_min_average_median(@lgas.collect(&:total_energy_per_resident))

      # Residential
      lgas_max_mins[:residential][:total][:energy] = max_min_average_median(@lgas.collect(&:total_residential_energy))
      lgas_max_mins[:residential][:total][:customers] = max_min_average_median(@lgas.collect(&:residential_customers))
      lgas_max_mins[:residential][:total][:per_customer] = max_min_average_median(@lgas.collect(&:total_residential_energy_per_customer))
      lgas_max_mins[:residential][:total][:per_resident] = max_min_average_median(@lgas.collect(&:total_residential_energy_per_resident))

      lgas_max_mins[:residential][:normal][:energy] = max_min_average_median(@lgas.collect(&:residential_energy))
      lgas_max_mins[:residential][:normal][:customers] = max_min_average_median(@lgas.collect(&:residential_customers))
      lgas_max_mins[:residential][:normal][:per_customer] = max_min_average_median(@lgas.collect(&:residential_energy_per_customer))
      lgas_max_mins[:residential][:normal][:per_resident] = max_min_average_median(@lgas.collect(&:residential_energy_per_resident))

      lgas_max_mins[:residential][:controlled_load][:energy] = max_min_average_median(@lgas.collect(&:residential_controlled_load_energy))
      lgas_max_mins[:residential][:controlled_load][:customers] = max_min_average_median(@lgas.collect(&:residential_controlled_load_customers))
      lgas_max_mins[:residential][:controlled_load][:per_customer] = max_min_average_median(@lgas.collect(&:residential_controlled_load_energy_per_customer))
      lgas_max_mins[:residential][:controlled_load][:per_resident] = max_min_average_median(@lgas.collect(&:residential_controlled_load_energy_per_resident))

      # Business
      lgas_max_mins[:business][:total][:energy] = max_min_average_median(@lgas.collect(&:total_business_energy))
      lgas_max_mins[:business][:total][:customers] = max_min_average_median(@lgas.collect(&:total_business_customers))
      lgas_max_mins[:business][:total][:per_customer] = max_min_average_median(@lgas.collect(&:total_business_energy_per_customer))

      lgas_max_mins[:business][:small][:energy] = max_min_average_median(@lgas.collect(&:small_business_energy))
      lgas_max_mins[:business][:small][:customers] = max_min_average_median(@lgas.collect(&:small_business_customers))
      lgas_max_mins[:business][:small][:per_customer] = max_min_average_median(@lgas.collect(&:small_business_energy_per_customer))

      lgas_max_mins[:business][:large][:energy] = max_min_average_median(@lgas.collect(&:large_business_energy))
      lgas_max_mins[:business][:large][:customers] = max_min_average_median(@lgas.collect(&:large_business_customers))
      lgas_max_mins[:business][:large][:per_customer] = max_min_average_median(@lgas.collect(&:large_business_energy_per_customer))

    end
    lgas_max_mins
  end

  def max_min_average_median(ar)
    unless ar.nil? || ar.length <= 0
      { all: ar, max: ar.max, min: ar.min, average: ar.inject { |sum, el| sum + el }.to_f / ar.size }
    end
  end

  def commify(number)
    if number.to_s =~ /^\d*(\.(\d+)?)?/
      split = number.to_s.split('.')
      number = split[0].gsub(/(\d)(?=(\d{3})+$)/, '\1,')
      number += '.' + split[1][0..1] unless split[1].nil?
    end
    number
  end

  def get_params
    params = {}
    request.query_string.split('&').each do |q|
      params[q.split('=')[0]] = q.split('=')[1].split('+')
    end
    params
  end

  # Include = Heading defincitions;
  # Exclude = Value to exclude
  def create_params(inc, exc)
    query_string = ''
    unless inc.empty?
      query_string = '?'
      get_params.each_pair do |k, v|
        # If the included list includes this query component
        if inc.include?(k)
          # Add/Remove if it includes this one, otherwise leave as is then add to query
          if inc.include?(exc[0])
            v = v.delete(exc[1]) if v.include?(exc[1])
            v.compact
          end
          query_string = query_string + k + '=' + v.join('+') + '&'
        # Otherwise, if the current requirement isn't there, add it
        elsif !inc.include?(exc[0])
          v = v.delete(exc[1]) if v.include?(exc[1])
          v.compact
          query_string = query_string + k + '=' + v.join('+') + '&'
        end
      end
    end
    query_string
  end

  def color_gradient(value, details)
    max = 'ff3333'
    average = 'ffe539'
    # average = "39a9ff"
    min = '49cd6e'
    color_gradient = min
    value.to_f! if value.class == 'Fixnum'
    # puts value.class

    percent = value / (details[:max])
    percent_max_min_lower = (value - details[:min]).to_f / (details[:average] - details[:min])
    percent_max_min_upper = (value - details[:average]).to_f / (details[:max] - details[:average])

    puts "value: #{value}\n percentage: #{percent}\npercent_max_min_lower: #{percent_max_min_lower}\npercent_max_min_upper: #{percent_max_min_upper}"

    if value <= details[:min]
      color_gradient = min
    elsif value == details[:average]
      color_gradient = average
    elsif value >= details[:max]
      color_gradient = max
    elsif value > details[:min] && value < details[:average]
      red =   (min[0..1].hex.to_i + percent_max_min_lower * (average[0..1].hex.to_i - min[0..1].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      green = (min[2..3].hex.to_i + percent_max_min_lower * (average[2..3].hex.to_i - min[2..3].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      blue =  (min[4..5].hex.to_i + percent_max_min_lower * (average[4..5].hex.to_i - min[4..5].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      puts "red: #{red}"
      puts "green: #{green}"
      puts "blue: #{blue}"
      color_gradient = red + green + blue
    elsif value > details[:average] && value < details[:max]
      red =   (average[0..1].hex.to_i + percent_max_min_upper * (max[0..1].hex.to_i - average[0..1].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      green = (average[2..3].hex.to_i + percent_max_min_upper * (max[2..3].hex.to_i - average[2..3].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      blue =  (average[4..5].hex.to_i + percent_max_min_upper * (max[4..5].hex.to_i - average[4..5].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      puts "red: #{red}"
      puts "green: #{green}"
      puts "blue: #{blue}"
      color_gradient = red + green + blue
    end
    color_gradient
  end
end
