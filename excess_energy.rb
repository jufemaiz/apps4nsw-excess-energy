# frozen_string_literal: true

# excess_energy.rb

require 'rubygems'
require 'dotenv/load'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'sinatra'

require 'coffee-script'
require 'haml'
require 'sass'

set :haml, format: :html5

require './lga-model'
require './partials'

require './helpers'

@@local = false

# ----------------------------------
# Homepage
# ----------------------------------

get '/' do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :index
end

# ----------------------------------
# Map
# ----------------------------------

get %r{/map(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :map
end

# ----------------------------------
# LGA Browse
# ----------------------------------

get %r{/lgas(\/)?} do
  unless params[:lgas].nil?
    if params[:lgas].length == 1
      redirect "/lgas/#{params[:lgas][0]}"
    elsif
      redirect "/lgas/#{params[:lgas][0]}?lgas=#{params[:lgas][1]}"
    end
  end

  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :lgas_index
end

# ----------------------------------
# LGA Show
# ----------------------------------

get %r{/lgas/(\d{5})(\/.*)?} do
  unless params[:lgas].nil?
    redirect "/lgas/#{params[:captures][0]},#{params[:lgas]}"
  end

  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  @lgas.each do |lga|
    @lga = lga if lga.lga_code == params[:captures][0].to_i
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

get %r{/lgas/(\d{5}),(\d{5})(\/.*)?} do
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

get %r{/energy(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy
end

# ----------------------------------
# Energy - Residential - Total
# ----------------------------------

get %r{/energy/residential(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_residential
end

# ----------------------------------
# Energy - Residential - Normal
# ----------------------------------

get %r{/energy/residential/normal(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_residential_normal
end

# ----------------------------------
# Energy - Residential - Hot Water
# ----------------------------------

get %r{/energy/residential/hot-water(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_residential_hot_water
end

# ----------------------------------
# Energy - Business - Total
# ----------------------------------

get %r{/energy/business(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_business
end

# ----------------------------------
# Energy - Business - Small
# ----------------------------------

get %r{/energy/business/small(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_business_small
end

# ----------------------------------
# Energy - Business - Large
# ----------------------------------

get %r{/energy/business/large(\/)?} do
  @lgas = get_lgas
  @lgas_stats = lgas_stats(@lgas)

  haml :energy_business_large
end

# ----------------------------------
# SCSS Custom Styling
# ----------------------------------

get %r{/polygons(\/(\d{5}))?.json} do
  @row_number = 0
  @lgas_header = []
  @lgas = []
  @params = params

  # For each line
  IO.foreach('public/csv/2010-consumption.csv') do |f|
    @row_number += 1
    if @row_number == 1
      CSV.parse(f) do |row|
        @lgas_header = row
      end
    elsif @row_number > 1
      CSV.parse(f) do |row|
        @lgas.push LGA.new(@lgas_header, row)
      end
    end
  end

  # Read XML
  f = File.open('public/csv/LGA10aAust.kml')
  doc = Nokogiri::XML(f)
  f.close
  doc.remove_namespaces!

  @placemarks = {}
  @lgas_numbers = @lgas.map(&:lga_code)
  @row_number = 0
  doc.xpath('//Placemark').each do |p|
    @row_number += 1
    # if @row_number < 10
    lga_code = p.xpath(".//Data[@name='LGA_CODE10']//value")[0].content.to_i
    if !params[:captures].nil? && !params[:captures][1].nil?
      if params[:captures][1].to_i == lga_code
        @placemarks[lga_code] = p.xpath('.//coordinates').map do |c|
          c.content.split(' ').map do |m|
            [m.split(',')[1].to_f, m.split(',')[0].to_f]
          end
        end
      end
    elsif @lgas_numbers.include? lga_code.to_i
      @placemarks[lga_code] = p.xpath('.//coordinates').map do |c|
        c.content.split(' ').map do |m|
          [m.split(',')[1].to_f, m.split(',')[0].to_f]
        end
      end
    end
    # end
  end
  @placemarks = [@placemarks]

  haml :polygon_json, layout: false
end

# ----------------------------------
# SCSS Custom Styling
# ----------------------------------

get '/css/energy.css' do
  sass :energy
end

get %r{(\/js\/[a-zA-Z0-9_\/\-\.]+\.coffee)\.js} do |filename|
  content_type :js
  puts options.public + filename
  base_name = options.public + filename
  if File.exist? base_name
    CoffeeScript.compile File.open(base_name, 'r', &:read)
  else
    File.open(base_name + '.js', 'r', &:read)
  end
end
