# frozen_string_literal: true

require 'json'
require 'rubygems'
require 'open-uri'

# [LGA]
#
# Local Government Area
class LGA
  @array_header = []
  @array_values = []
  @hash = {}

  class << self
    def all
      row_n = 0
      header = []
      lgas = []
      # For each line
      File.foreach('public/csv/2010-consumption.csv') do |f|
        row_n += 1
        CSV.parse(f) do |row|
          header = row if row_n == 1
          lgas.push(LGA.new(header, row)) if row_n > 1
        end
      end
      lgas
    end
  end

  #
  #
  # @return [Numeric]
  def initialize(array_header = [], array_values = [])
    @array_header = array_header unless array_header.nil?
    @array_values = array_values unless array_values.nil?
    @hash = {}
    @array_header.each_index do |i|
      @hash[@array_header[i].tr(' ', '_').downcase] = if @array_header[i].tr(' ', '_').casecmp('lga').zero?
                                                        @array_values[i]
                                                      else
                                                        @array_values[i].to_i
                                                      end
    end
    to_object(@hash) unless array_header.nil? || array_values.nil?
  end

  # rubocop:disable Metrics/LineLength

  # Sets hash as instance methods
  #
  # @param [Hash] Hash
  # @return [void]
  def to_object(hash)
    hash.each do |k, v|
      instance_variable_set("@#{k}", v) ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") }) ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc { instance_variable_set("@#{k}", v) }) ## create the setter that sets the instance variable
    end
  end

  # rubocop:enable Metrics/LineLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength

  # Returns JSON formatted
  #
  # @param [Hash] args
  # @return [String]
  def to_json(*)
    @hash.merge(
      total_energy: total_energy,
      total_customers: total_customers,
      total_energy_per_customer: total_energy_per_customer,
      total_energy_per_resident: total_energy_per_resident,
      total_residential_energy: total_residential_energy,
      total_residential_energy_per_customer:
        total_residential_energy_per_customer,
      total_residential_energy_per_resident:
        total_residential_energy_per_resident,
      residential_energy_per_customer: residential_energy_per_customer,
      residential_energy_per_resident: residential_energy_per_resident,
      residential_controlled_load_energy_per_customer:
        residential_controlled_load_energy_per_customer,
      residential_controlled_load_energy_per_resident:
        residential_controlled_load_energy_per_resident,
      total_business_energy: total_business_energy,
      total_business_customers: total_business_customers,
      total_business_energy_per_customer: total_business_energy_per_customer,
      small_business_energy_per_customer: small_business_energy_per_customer,
      large_business_energy_per_customer: large_business_energy_per_customer
    ).to_json(*)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  #
  #
  # @return [Numeric]
  def total_energy
    total_residential_energy + total_business_energy
  end

  #
  #
  # @return [Numeric]
  def total_customers
    residential_customers + total_business_customers
  end

  #
  #
  # @return [Numeric]
  def total_energy_per_customer
    total_energy.to_f / total_customers
  end

  #
  #
  # @return [Numeric]
  def total_energy_per_resident
    total_energy.to_f / population
  end

  #
  #
  # @return [Numeric]
  def total_residential_energy
    residential_energy + residential_controlled_load_energy
  end

  #
  #
  # @return [Numeric]
  def total_residential_energy_per_customer
    total_residential_energy.to_f / residential_customers
  end

  #
  #
  # @return [Numeric]
  def total_residential_energy_per_resident
    total_residential_energy.to_f / population
  end

  #
  #
  # @return [Numeric]
  def residential_energy_per_customer
    residential_energy.to_f / residential_customers
  end

  #
  #
  # @return [Numeric]
  def residential_energy_per_resident
    residential_energy.to_f / population
  end

  #
  #
  # @return [Numeric]
  def residential_controlled_load_energy_per_customer
    residential_controlled_load_energy.to_f / residential_controlled_load_customers
  end

  #
  #
  # @return [Numeric]
  def residential_controlled_load_energy_per_resident
    residential_controlled_load_energy.to_f / population
  end

  #
  #
  # @return [Numeric]
  def total_business_energy
    small_business_energy + large_business_energy
  end

  #
  #
  # @return [Numeric]
  def total_business_customers
    small_business_customers + large_business_customers
  end

  #
  #
  # @return [Numeric]
  def total_business_energy_per_customer
    total_business_energy.to_f / total_business_customers
  end

  #
  #
  # @return [Numeric]
  def small_business_energy_per_customer
    small_business_energy.to_f / total_business_customers
  end

  #
  #
  # @return [Numeric]
  def large_business_energy_per_customer
    large_business_energy.to_f / total_business_customers
  end

  #
  #
  # @return [Numeric]
  def lga_name
    lga.split.collect(&:capitalize).join(' ')
  end
end
