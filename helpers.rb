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
  ].freeze
  ALLOWED_NORMALISE_KEYS = %i[
    population
    residential_customers
  ].freeze
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
    lgas.sort { |x, y| y.send(sort_by) <=> x.send(sort_by) }
  end

  # For a given set of lgas, return a hash of max/mins
  def lgas_stats(lgas)
    return nil if lgas.nil? || lgas.empty?

    lgas_max_mins = { total: { energy: nil, customers: nil, population: nil }, residential: { total: { energy: nil, customers: nil }, normal: { energy: nil, customers: nil }, controlled_load: { energy: nil, customers: nil } }, business: { total: { energy: nil, customers: nil }, small: { energy: nil, customers: nil }, large: { energy: nil, customers: nil } } }
    # Totals
    lgas_max_mins[:total][:energy] = statistical_data(@lgas.collect(&:total_energy))
    lgas_max_mins[:total][:customers] = statistical_data(@lgas.collect(&:total_customers))
    lgas_max_mins[:total][:population] = statistical_data(@lgas.collect(&:population))
    lgas_max_mins[:total][:per_customer] = statistical_data(@lgas.collect(&:total_energy_per_customer))
    lgas_max_mins[:total][:per_resident] = statistical_data(@lgas.collect(&:total_energy_per_resident))

    # Residential
    lgas_max_mins[:residential][:total][:energy] = statistical_data(@lgas.collect(&:total_residential_energy))
    lgas_max_mins[:residential][:total][:customers] = statistical_data(@lgas.collect(&:residential_customers))
    lgas_max_mins[:residential][:total][:per_customer] = statistical_data(@lgas.collect(&:total_residential_energy_per_customer))
    lgas_max_mins[:residential][:total][:per_resident] = statistical_data(@lgas.collect(&:total_residential_energy_per_resident))

    lgas_max_mins[:residential][:normal][:energy] = statistical_data(@lgas.collect(&:residential_energy))
    lgas_max_mins[:residential][:normal][:customers] = statistical_data(@lgas.collect(&:residential_customers))
    lgas_max_mins[:residential][:normal][:per_customer] = statistical_data(@lgas.collect(&:residential_energy_per_customer))
    lgas_max_mins[:residential][:normal][:per_resident] = statistical_data(@lgas.collect(&:residential_energy_per_resident))

    lgas_max_mins[:residential][:controlled_load][:energy] = statistical_data(@lgas.collect(&:residential_controlled_load_energy))
    lgas_max_mins[:residential][:controlled_load][:customers] = statistical_data(@lgas.collect(&:residential_controlled_load_customers))
    lgas_max_mins[:residential][:controlled_load][:per_customer] = statistical_data(@lgas.collect(&:residential_controlled_load_energy_per_customer))
    lgas_max_mins[:residential][:controlled_load][:per_resident] = statistical_data(@lgas.collect(&:residential_controlled_load_energy_per_resident))

    # Business
    lgas_max_mins[:business][:total][:energy] = statistical_data(@lgas.collect(&:total_business_energy))
    lgas_max_mins[:business][:total][:customers] = statistical_data(@lgas.collect(&:total_business_customers))
    lgas_max_mins[:business][:total][:per_customer] = statistical_data(@lgas.collect(&:total_business_energy_per_customer))

    lgas_max_mins[:business][:small][:energy] = statistical_data(@lgas.collect(&:small_business_energy))
    lgas_max_mins[:business][:small][:customers] = statistical_data(@lgas.collect(&:small_business_customers))
    lgas_max_mins[:business][:small][:per_customer] = statistical_data(@lgas.collect(&:small_business_energy_per_customer))

    lgas_max_mins[:business][:large][:energy] = statistical_data(@lgas.collect(&:large_business_energy))
    lgas_max_mins[:business][:large][:customers] = statistical_data(@lgas.collect(&:large_business_customers))
    lgas_max_mins[:business][:large][:per_customer] = statistical_data(@lgas.collect(&:large_business_energy_per_customer))

    lgas_max_mins
  end

  # For an array of numbers, return a Hash of statistical data
  #
  # @param [Array<Numeric>] arg
  # @return Hash
  def statistical_data(arg)
    return nil if arg.nil? || !arg.any?

    variance = variance(arg)
    {
      all: arg,
      max: arg.max,
      min: arg.min,
      average: arg.sum.to_f / arg.length.to_f,
      variance: variance,
      standard_deviation: Math.sqrt(variance)
    }
  end

  # For an array of numbers, return the variance
  #
  # @param [Array<Numeric>] arg
  # @return Numeric
  def variance(arg)
    m = arg.sum.to_f / arg.length.to_f
    arg.inject(0) { |accum, i| accum + (i - m) ** 2 } / (arg.length - 1).to_f
  end

  # Commifies a number
  #
  # @param [Numeric] number
  # @return [String]
  def commify(number)
    return number unless /^\d*(\.(\d+)?)?/.match?(number.to_s)

    split = number.to_s.split('.')
    number = split[0].gsub(/(\d)(?=(\d{3})+$)/, '\1,')
    number += '.' + split[1][0..1] unless split[1].nil?
    number
  end

  # Returns params
  #
  # @return [Hash]
  def get_params
    params = {}
    request.query_string.split('&').each do |q|
      params[q.split('=')[0]] = q.split('=')[1].split('+')
    end
    params
  end

  # Build a parameter string, given an inclusive and exclusive set
  #
  # @param [Array<String, Symbol>] inc includes these keys
  # @param [Array<String, Symbol>] exc excludes these keys
  # @return [String]
  def create_params(inc, exc)
    return '' if inc.empty?

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
    query_string
  end

  # Provides a colour inf hex form for
  #
  # @param [Numeric] value
  # @param [Hash] opts
  # @option opts [Numeric] :min
  # @option opts [Numeric] :max
  # @option opts [Numeric] :average
  # @return [String]
  def color_gradient(value, opts)
    max = 'ff3333'
    average = 'ffe539'
    # average = "39a9ff"
    min = '49cd6e'
    color_gradient = min
    value.to_f! if value.class == 'Fixnum'
    # puts value.class

    percent = value / opts[:max]
    percent_max_min_lower = (value - opts[:min]).to_f / (opts[:average] - opts[:min])
    percent_max_min_upper = (value - opts[:average]).to_f / (opts[:max] - opts[:average])

    case
    when value <= opts[:min]
      return min
    when value == opts[:average]
      return average
    when value >= opts[:max]
      return max
    when value > opts[:min] && value < opts[:average]
      red = (min[0..1].hex.to_i + percent_max_min_lower * (average[0..1].hex.to_i - min[0..1].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      green = (min[2..3].hex.to_i + percent_max_min_lower * (average[2..3].hex.to_i - min[2..3].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      blue = (min[4..5].hex.to_i + percent_max_min_lower * (average[4..5].hex.to_i - min[4..5].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      return [red, green, blue].join('')
    when value > opts[:average] && value < opts[:max]
      red = (average[0..1].hex.to_i + percent_max_min_upper * (max[0..1].hex.to_i - average[0..1].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      green = (average[2..3].hex.to_i + percent_max_min_upper * (max[2..3].hex.to_i - average[2..3].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      blue = (average[4..5].hex.to_i + percent_max_min_upper * (max[4..5].hex.to_i - average[4..5].hex.to_i)).to_i.to_s(16).rjust(2, '0')
      return [red, green, blue].join('')
    end
  end
end

# rubocop:enable Metrics/BlockLength, Metrics/LineLength, Metrics/PerceivedComplexity
