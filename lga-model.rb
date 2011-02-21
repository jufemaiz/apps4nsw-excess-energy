class LGA
  require 'rubygems'
  require 'open-uri'
  require 'json'
  
  @array_header = []
  @array_values = []
  @hash = {}
  def initialize(array_header = nil,array_values = nil)
    @array_header = array_header unless array_header.nil?
    @array_values = array_values unless array_values.nil?
    @hash = {}
    @array_header.each_index do |i|
      if @array_header[i].gsub(" ","_").downcase == 'lga'
        @hash[@array_header[i].gsub(" ","_").downcase] = @array_values[i]
      else
        @hash[@array_header[i].gsub(" ","_").downcase] = @array_values[i].to_i
      end
    end
    self.to_object(@hash) unless (array_header.nil? || array_values.nil?)
  end
  
  def find_all(options = {})

    @row_number = 0
    @lgas_header = []
    @lgas = []

    # For each line
    IO.foreach("public/csv/2010-consumption.csv") do |f|
      @row_number += 1
      if @row_number == 1
        FasterCSV.parse(f) do |row|
          @lgas_header = row
        end
      elsif @row_number > 1
        FasterCSV.parse(f) do |row|
          @lgas.push LGA.new(@lgas_header,row)
        end
      end
    end
    return @lgas 
  end
  
  def to_object(hash)
    hash.each do |k,v|
      self.instance_variable_set("@#{k}", v)  ## create and initialize an instance variable for this key/value pair
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})  ## create the getter that returns the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})  ## create the setter that sets the instance variable
    end
  end
  
  def to_json(*args)
    @hash.merge({
      :total_energy => self.total_energy,
      :total_customers => self.total_customers,
      :total_energy_per_customer => self.total_energy_per_customer,
      :total_energy_per_resident => self.total_energy_per_resident,

      :total_residential_energy => self.total_residential_energy,
      :total_residential_energy_per_customer => self.total_residential_energy_per_customer,
      :total_residential_energy_per_resident => self.total_residential_energy_per_resident,
      :residential_energy_per_customer => self.residential_energy_per_customer,
      :residential_energy_per_resident => self.residential_energy_per_resident,
      :residential_controlled_load_energy_per_customer => self.residential_controlled_load_energy_per_customer,
      :residential_controlled_load_energy_per_resident => self.residential_controlled_load_energy_per_resident,

      :total_business_energy => self.total_business_energy,
      :total_business_customers => self.total_business_customers,
      :total_business_energy_per_customer => self.total_business_energy_per_customer,
      :small_business_energy_per_customer => self.small_business_energy_per_customer,
      :large_business_energy_per_customer => self.large_business_energy_per_customer
    }).to_json(*args)
  end
  
  def total_energy
    total_energy = self.total_residential_energy + self.total_business_energy
  end
  def total_customers
    total = self.residential_customers + self.total_business_customers
  end
  def total_energy_per_customer
    total_energy_per_customer = self.total_energy.to_f / self.total_customers
  end
  def total_energy_per_resident
    total_energy_per_resident = self.total_energy.to_f / self.population
  end

  def total_residential_energy
    total_residential_energy = self.residential_energy + self.residential_controlled_load_energy
  end
  def total_residential_energy_per_customer
    total_residential_energy_per_customer = self.total_residential_energy.to_f / self.residential_customers
  end
  def total_residential_energy_per_resident
    total_residential_energy_per_resident = self.total_residential_energy.to_f / self.population
  end
  def residential_energy_per_customer
    total_residential_energy_per_customer = self.residential_energy.to_f / self.residential_customers
  end
  def residential_energy_per_resident
    total_residential_energy_per_resident = self.residential_energy.to_f / self.population
  end
  def residential_controlled_load_energy_per_customer
    residential_controlled_load_energy_per_customer = self.residential_controlled_load_energy.to_f / self.residential_controlled_load_customers
  end
  def residential_controlled_load_energy_per_resident
    total_residential_energy_per_resident = self.residential_controlled_load_energy.to_f / self.population
  end

  def total_business_energy
    total_business_energy = self.small_business_energy + self.large_business_energy
  end
  def total_business_customers
    total = self.small_business_customers + self.large_business_customers
  end
  def total_business_energy_per_customer
    total_business_energy_per_customer = self.total_business_energy.to_f / self.total_business_customers
  end
  def small_business_energy_per_customer
    small_business_energy_per_customer = self.small_business_energy.to_f / self.total_business_customers
  end
  def large_business_energy_per_customer
    large_business_energy_per_customer = self.large_business_energy.to_f / self.total_business_customers
  end

  def lga_name
    self.lga.split(" ").collect{|w| w.capitalize}.join(" ")
  end
end