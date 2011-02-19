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
    @hash.to_json(*args)
  end
  
  def total_energy
    total_energy = self.total_residential_energy + self.total_business_energy
  end

  def total_residential_energy
    total_residential_energy = self.residential_energy + self.residential_controlled_load_energy
  end

  def total_business_energy
    total_business_energy = self.small_business_energy + self.large_business_energy
  end

  def total_business_customers
    total = self.small_business_customers + self.large_business_customers
  end

  def total_customers
    total = self.residential_customers + self.total_business_customers
  end
end