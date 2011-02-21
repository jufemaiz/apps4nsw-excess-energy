require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'json'
require 'fastercsv'

require 'haml'
  set :haml, :format => :html5
require 'sass'
require 'coffee-script'
require 'partials'
require 'nokogiri'

require 'lga-model'

@@local = false

# ----------------------------------
# Homepage
# ----------------------------------

get '/' do

  # @row_number = 0
  # @lgas_header = []
  # @lgas = []
  
  # For each line
  # IO.foreach("public/csv/2010-consumption.csv") do |f|
  #   @row_number += 1
  #   if @row_number == 1
  #     FasterCSV.parse(f) do |row|
  #       @lgas_header = row
  #     end
  #   elsif @row_number > 1
  #     FasterCSV.parse(f) do |row|
  #       @lgas.push LGA.new(@lgas_header,row)
  #     end
  #   end
  #  end
  
  @lgas = get_lgas

  haml :index
end

# ----------------------------------
# LGA Browse
# ----------------------------------

get %r{/map(\/)?$} do  

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
  
  haml :map
end


# ----------------------------------
# LGA Browse
# ----------------------------------

get %r{/lgas(\/)?$} do  

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
  
  haml :lgas_index
end

# ----------------------------------
# LGA Show
# ----------------------------------

get %r{/lgas/(\d{5})(\/.*)?$} do
  
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
  
  @lgas.each do |lga|
    if lga.lga_code == params[:captures][0].to_i
      @lga = lga
    end
  end
  
  if @lga.nil?
    haml :lgas_index
  else
    haml :lgas_show
  end
end

# ----------------------------------
# LGA - Head to Head
# ----------------------------------

# ----------------------------------
# LGA Show
# ----------------------------------

get %r{/lgas/(\d{5}),(\d{5})(\/.*)?$} do
  
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)
  
  @lgas.each do |lga|
    if lga.lga_code == params[:captures][0].to_i
      @lga1 = lga
    elsif lga.lga_code == params[:captures][1].to_i
      @lga2 = lga
    end
  end
  
  if @lga1.nil? && @lga2.nil?
    haml :lgas_index
  elsif @lga1.nil?
    @lga = @lga2
    haml :lgas_show
  elsif @lga2.nil?
    @lga = @lga1
    haml :lgas_show
  else
    haml :lgas_head2head
  end
end

# ----------------------------------
# Energy - Total
# ----------------------------------

get %r{/energy(\/)?$} do  

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

   haml :energy
end

# ----------------------------------
# Energy - Residential - Total
# ----------------------------------

get %r{/energy/residential(\/)?$} do  

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

   haml :energy_residential

end

# ----------------------------------
# Energy - Residential - Normal
# ----------------------------------

get %r{/energy/residential/normal(\/)?$} do  

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

   haml :energy_residential_normal

end

# ----------------------------------
# Energy - Residential - Hot Water
# ----------------------------------

get %r{/energy/residential/hot-water(\/)?$} do  

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

   haml :energy_residential_hot_water

end

# ----------------------------------
# Energy - Business - Total
# ----------------------------------

get %r{/energy/business(\/)?$} do  

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

   haml :energy_business

end

# ----------------------------------
# Energy - Business - Small
# ----------------------------------

get %r{/energy/business/small(\/)?$} do  

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

   haml :energy_business_small

end

# ----------------------------------
# Energy - Business - Large
# ----------------------------------

get %r{/energy/business/large(\/)?$} do  

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

   haml :energy_business_large

end

# ----------------------------------
# SCSS Custom Styling
# ----------------------------------


get %r{/polygons(\/(\d{5}))?.json$} do  

  @row_number = 0
  @lgas_header = []
  @lgas = []
  @params = params

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

  # Read XML
  f = File.open( "public/csv/LGA10aAust.kml" )
  doc = Nokogiri::XML(f)
  f.close
  doc.remove_namespaces!

  @placemarks = {}
  @lgas_numbers = @lgas.map{|p| p.lga_code}
  @row_number = 0
  doc.xpath("//Placemark").each do |p|
    @row_number = @row_number + 1
    # if @row_number < 10
      lga_code = p.xpath(".//Data[@name='LGA_CODE10']//value")[0].content.to_i
      if !params[:captures].nil? && !params[:captures][1].nil?
        if params[:captures][1].to_i == lga_code
          @placemarks[lga_code] = p.xpath(".//coordinates").map{ |c|
            c.content.split(' ').map{ |m|
              [m.split(',')[1].to_f,m.split(',')[0].to_f]
            }
          }
        end
      elsif @lgas_numbers.include? lga_code.to_i
        @placemarks[lga_code] = p.xpath(".//coordinates").map{ |c|
          c.content.split(' ').map{ |m|
            [m.split(',')[1].to_f,m.split(',')[0].to_f]
          }
        }
      end
    # end
  end
  @placemarks = [@placemarks]

  haml :polygon_json, :layout => false
end

# ----------------------------------
# SCSS Custom Styling
# ----------------------------------

get '/css/energy.css' do
  sass :energy
end

get %r{^(\/js\/[a-zA-Z0-9_\/\-\.]+\.coffee)\.js} do |filename|
  content_type :js
  puts options.public + filename
  base_name = options.public + filename
  if File.exists? base_name
    CoffeeScript.compile File.open(base_name, 'r'){|f| f.read }
  else
    File.open(base_name + '.js', 'r'){|f| f.read }
  end
end

# 
# Helpers
# 

helpers Sinatra::Partials
helpers do
  def get_lgas
    row_number = 0
    lgas_header = []
    lgas = []

    # For each line
    IO.foreach("public/csv/2010-consumption.csv") do |f|
      row_number += 1
      if row_number == 1
        FasterCSV.parse(f) do |row|
          lgas_header = row
        end
      elsif row_number > 1
        FasterCSV.parse(f) do |row|
          lgas.push LGA.new(lgas_header,row)
        end
      end
     end
    # Return the lgas
    return lgas
  end


  # For a given set of lgas, return a hash of max/mins
  def lgas_stats(lgas)
    lgas_max_mins = nil
    unless lgas.nil? || lgas.length == 0
      lgas_max_mins = { :total => { :energy => nil, :customers => nil, :population => nil }, :residential => { :total  => { :energy => nil, :customers => nil }, :normal => { :energy => nil, :customers => nil }, :controlled_load => { :energy => nil, :customers => nil } }, :business => { :total  => { :energy => nil, :customers => nil }, :small => { :energy => nil, :customers => nil }, :large => { :energy => nil, :customers => nil } } }
      # Totals
      lgas_max_mins[:total][:energy] = max_min_mean_median(@lgas.collect{|l| l.total_energy})
      lgas_max_mins[:total][:customers] = max_min_mean_median(@lgas.collect{|l| l.total_customers})
      lgas_max_mins[:total][:population] = max_min_mean_median(@lgas.collect{|l| l.population})
      lgas_max_mins[:total][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.total_energy.to_f / l.total_customers})
      lgas_max_mins[:total][:per_resident] = max_min_mean_median(@lgas.collect{|l| l.total_energy.to_f / l.population})
      
      # Residential
      lgas_max_mins[:residential][:total][:energy] = max_min_mean_median(@lgas.collect{|l| l.total_residential_energy})
      lgas_max_mins[:residential][:total][:customers] = max_min_mean_median(@lgas.collect{|l| l.residential_customers})
      lgas_max_mins[:residential][:total][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.total_residential_energy.to_f / l.residential_customers})
      lgas_max_mins[:residential][:total][:per_resident] = max_min_mean_median(@lgas.collect{|l| l.total_residential_energy.to_f / l.population})
      
      lgas_max_mins[:residential][:normal][:energy] = max_min_mean_median(@lgas.collect{|l| l.residential_energy})
      lgas_max_mins[:residential][:normal][:customers] = max_min_mean_median(@lgas.collect{|l| l.residential_customers})
      lgas_max_mins[:residential][:normal][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.residential_energy.to_f / l.residential_customers})
      lgas_max_mins[:residential][:normal][:per_resident] = max_min_mean_median(@lgas.collect{|l| l.residential_energy.to_f / l.population})
      
      lgas_max_mins[:residential][:controlled_load][:energy] = max_min_mean_median(@lgas.collect{|l| l.residential_controlled_load_energy})
      lgas_max_mins[:residential][:controlled_load][:customers] = max_min_mean_median(@lgas.collect{|l| l.residential_controlled_load_customers})
      lgas_max_mins[:residential][:controlled_load][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.residential_controlled_load_energy.to_f / l.residential_controlled_load_customers})
      lgas_max_mins[:residential][:controlled_load][:per_resident] = max_min_mean_median(@lgas.collect{|l| l.residential_controlled_load_energy.to_f / l.population})
      
      # Business
      lgas_max_mins[:business][:total][:energy] = max_min_mean_median(@lgas.collect{|l| l.total_business_energy})
      lgas_max_mins[:business][:total][:customers] = max_min_mean_median(@lgas.collect{|l| l.total_business_customers})
      lgas_max_mins[:business][:total][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.total_business_energy.to_f / l.total_business_customers})

      lgas_max_mins[:business][:small][:energy] = max_min_mean_median(@lgas.collect{|l| l.small_business_energy})
      lgas_max_mins[:business][:small][:customers] = max_min_mean_median(@lgas.collect{|l| l.small_business_customers})
      lgas_max_mins[:business][:small][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.small_business_energy.to_f / l.small_business_customers})

      lgas_max_mins[:business][:large][:energy] = max_min_mean_median(@lgas.collect{|l| l.large_business_energy})
      lgas_max_mins[:business][:large][:customers] = max_min_mean_median(@lgas.collect{|l| l.large_business_customers})
      lgas_max_mins[:business][:large][:per_customer] = max_min_mean_median(@lgas.collect{|l| l.large_business_energy.to_f / l.large_business_customers})

    end
    lgas_max_mins
  end
  
  def max_min_mean_median(ar)
    puts "ar => #{ar.inspect}\n\n"
    unless ar.nil? || !(ar.length > 0)
      {:all => ar, :max => ar.max,:min => ar.min, :mean => ar.inject{ |sum, el| sum + el }.to_f / ar.size}
    end
  end
  
  def commify(number)
    if number.to_s.match(/^\d*(\.(\d+)?)?/)
      split = number.to_s.split('.')
      number = split[0].gsub(/(\d)(?=(\d{3})+$)/,'\1,')
      number += '.' + split[1][0..1] unless split[1].nil?
    end
    number
  end
  
  def get_params
    params = {}
    request.query_string.split('&').each do |q|
      params[q.split('=')[0]] = q.split('=')[1].split('+')
    end
    return params
  end
  
  # Include = Heading defincitions;
  # Exclude = Value to exclude
  def create_params(inc, exc)
    query_string = ""
    if inc.length > 0
      query_string = "?"
      get_params.each_pair do |k,v|
        # If the included list includes this query component
        if inc.include?(k)
          # Add/Remove if it includes this one, otherwise leave as is then add to query
          if inc.include?(exc[0])
            v = v.delete(exc[1]) if v.include?(exc[1])
            v.compact
          end
          query_string = query_string + k + "=" + v.join("+") + "&"
        # Otherwise, if the current requirement isn't there, add it
        elsif !inc.include?(exc[0])
          v = v.delete(exc[1]) if v.include?(exc[1])
          v.compact
          query_string = query_string + k + "=" + v.join("+") + "&"
        end
      end
    end
    return query_string
  end
  
end