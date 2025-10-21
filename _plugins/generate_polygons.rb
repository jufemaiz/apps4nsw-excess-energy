# frozen_string_literal: true

# Jekyll plugin to generate polygon JSON files
Jekyll::Hooks.register :site, :post_write do |site|
  require 'nokogiri'
  require 'json'

  kml_path = '_data/lgas.yml'
  unless File.exist?(kml_path)
    puts "Warning: KML file not found at #{kml_path}, skipping polygon generation"
    next
  end

  # Create polygons directory
  polygons_dir = File.join(site.dest, 'polygons')
  FileUtils.mkdir_p(polygons_dir)

  # Read KML file and generate polygon JSON
  f = File.open(kml_path)
  doc = Nokogiri::XML(f)
  f.close
  doc.remove_namespaces!

  placemarks = {}
  lga_codes = site.data['lgas'].map { |lga| lga['lga_code'] }

  doc.xpath('//Placemark').each do |p|
    lga_code_element = p.xpath(".//Data[@name='LGA_CODE10']//value")[0]
    next unless lga_code_element

    lga_code = lga_code_element.content.to_i
    next unless lga_codes.include?(lga_code)

    placemarks[lga_code] = p.xpath('.//coordinates').map do |c|
      c.content.split.map do |m|
        coords = m.split(',')
        next if coords.length < 2
        [coords[1].to_f, coords[0].to_f]
      end.compact
    end
  end

  # Write main polygons file
  File.write(File.join(site.dest, 'polygons.json'), [placemarks].to_json)

  # Write individual LGA polygon files
  placemarks.each do |lga_code, coords|
    File.write(File.join(polygons_dir, "#{lga_code}.json"), [{ lga_code => coords }].to_json)
  end

  puts "Generated polygon files for #{placemarks.length} LGAs"
end
