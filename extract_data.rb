require './excess_energy'
require 'yaml'

# Extract all LGA data
lgas_data = LGA.all.map do |lga|
  {
    'lga_code' => lga.lga_code,
    'lga_name' => lga.lga_name,
    'population' => lga.population,
    'residential_customers' => lga.residential_customers,
    'total_energy' => lga.total_energy,
    'total_residential_energy' => lga.total_residential_energy,
    'total_business_energy' => lga.total_business_energy
    # Add other fields as needed
  }
end

File.write('_data/lgas.yml', lgas_data.to_yaml)
puts "Extracted #{lgas_data.length} LGAs to _data/lgas.yml"