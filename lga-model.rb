# frozen_string_literal: true

require 'rubygems'
require 'open-uri'
require 'json'

class LGA
  @array_header = []
  @array_values = []
  @hash = {}

  def initialize(array_header = nil, array_values = nil)
    @array_header = array_header unless array_header.nil?
    @array_values = array_values unless array_values.nil?
    @hash = {}
    @array_header.each_index do |i|
      if @array_header[i].tr(' ', '_').casecmp('lga').zero?
        @hash[@array_header[i].tr(' ', '_').downcase] = @array_values[i]
      else
        @hash[@array_header[i].tr(' ', '_').downcase] = @array_values[i].to_i
      end
    end
    to_object(@hash) unless array_header.nil? || array_values.nil?
  end

  def find_all(_options = {})
    @row_number = 0
    @lgas_header = []
    @lgas = []

    # For each line
    IO.foreach('public/csv/2010-consumption.csv') do |f|
      @row_number += 1
      if @row_number == 1
        FasterCSV.parse(f) do |row|
          @lgas_header = row
        end
      elsif @row_number > 1
        FasterCSV.parse(f) do |row|
          @lgas.push LGA.new(@lgas_header, row)
        end
      end
    end
    @lgas
  end

  def to_object(hash)
    hash.each do |k, v|
      instance_variable_set("@#{k}", v) ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc { instance_variable_get("@#{k}") }) ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc { |v| instance_variable_set("@#{k}", v) }) ## create the setter that sets the instance variable
    end
  end

  def to_json(*args)
    @hash.merge(
      total_energy: total_energy,
      total_customers: total_customers,
      total_energy_per_customer: total_energy_per_customer,
      total_energy_per_resident: total_energy_per_resident,

      total_residential_energy: total_residential_energy,
      total_residential_energy_per_customer: total_residential_energy_per_customer,
      total_residential_energy_per_resident: total_residential_energy_per_resident,
      residential_energy_per_customer: residential_energy_per_customer,
      residential_energy_per_resident: residential_energy_per_resident,
      residential_controlled_load_energy_per_customer: residential_controlled_load_energy_per_customer,
      residential_controlled_load_energy_per_resident: residential_controlled_load_energy_per_resident,

      total_business_energy: total_business_energy,
      total_business_customers: total_business_customers,
      total_business_energy_per_customer: total_business_energy_per_customer,
      small_business_energy_per_customer: small_business_energy_per_customer,
      large_business_energy_per_customer: large_business_energy_per_customer
    ).to_json(*args)
  end

  def total_energy
    total_energy = total_residential_energy + total_business_energy
  end

  def total_customers
    total = residential_customers + total_business_customers
  end

  def total_energy_per_customer
    total_energy_per_customer = total_energy.to_f / total_customers
  end

  def total_energy_per_resident
    total_energy_per_resident = total_energy.to_f / population
  end

  def total_residential_energy
    total_residential_energy = residential_energy + residential_controlled_load_energy
  end

  def total_residential_energy_per_customer
    total_residential_energy_per_customer = total_residential_energy.to_f / residential_customers
  end

  def total_residential_energy_per_resident
    total_residential_energy_per_resident = total_residential_energy.to_f / population
  end

  def residential_energy_per_customer
    total_residential_energy_per_customer = residential_energy.to_f / residential_customers
  end

  def residential_energy_per_resident
    total_residential_energy_per_resident = residential_energy.to_f / population
  end

  def residential_controlled_load_energy_per_customer
    residential_controlled_load_energy_per_customer = residential_controlled_load_energy.to_f / residential_controlled_load_customers
  end

  def residential_controlled_load_energy_per_resident
    total_residential_energy_per_resident = residential_controlled_load_energy.to_f / population
  end

  def total_business_energy
    total_business_energy = small_business_energy + large_business_energy
  end

  def total_business_customers
    total = small_business_customers + large_business_customers
  end

  def total_business_energy_per_customer
    total_business_energy_per_customer = total_business_energy.to_f / total_business_customers
  end

  def small_business_energy_per_customer
    small_business_energy_per_customer = small_business_energy.to_f / total_business_customers
  end

  def large_business_energy_per_customer
    large_business_energy_per_customer = large_business_energy.to_f / total_business_customers
  end

  def lga_name
    lga.split(' ').collect(&:capitalize).join(' ')
  end
end
