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

require 'lga-model'

@@local = false

# ----------------------------------
# Homepage
# ----------------------------------

get '/' do

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

   # @polygons = JSON.parse(File.open('public/js/json/polygons.json').read)
   haml :index
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

get '/polygons.json' do
    
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
     
     

    haml :polygon_json
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
  def EAID(iamsId)
    prefix = iamsId[0..1].upcase.sub(/^S0/,'SG')
    eaid = prefix + '000' + iamsId[2..(iamsId.length - 1)]
  end
  def iamsId(eaid)
    prefix = eaid[0..1].upcase.sub(/^S0/,'SG')
    iamsId = prefix + eaid[5..(eaid.length - 1)]
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