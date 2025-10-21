# Jekyll plugin to generate polygon JSON files
Jekyll::Hooks.register :site, :post_write do |site|
  require 'nokogiri'
  require 'json'
  
  # Read KML file and generate polygon JSON
  f = File.open('_data/LGA10aAust.kml')
  doc = Nokogiri::XML(f)
  f.close
  doc.remove_namespaces!
  
  placemarks = {}
  lga_codes = site.data['lgas'].map { |lga| lga['lga_code'] }
  
  doc.xpath('//Placemark').each do |p|
    lga_code = p.xpath(".//Data[@name='LGA_CODE10']//value")[0].content.to_i
    if lga_codes.include?(lga_code)
      placemarks[lga_code] = p.xpath('.//coordinates').map do |c|
        c.content.split(' ').map do |m|
          [m.split(',')[1].to_f, m.split(',')[0].to_f]
        end
      end
    end
  end
  
  # Write main polygons file
  File.write(File.join(site.dest, 'polygons.json'), [placemarks].to_json)
  
  # Write individual LGA polygon files
  placemarks.each do |lga_code, coords|
    File.write(File.join(site.dest, "polygons/#{lga_code}.json"), [{lga_code => coords}].to_json)
  end
end