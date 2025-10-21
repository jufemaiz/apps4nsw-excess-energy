Jekyll::Hooks.register :site, :post_read do |site|
  site.data['lgas'].each do |lga|
    # Create individual LGA pages
    site.collections['lgas'].docs << Jekyll::Document.new(
      "_lgas/#{lga['lga_code']}.md",
      site: site,
      collection: site.collections['lgas']
    ).tap do |doc|
      doc.data.merge!({
        'layout' => 'lga',
        'title' => lga['lga_name'],
        'lga_code' => lga['lga_code'],
        'lga_data' => lga
      })
      doc.content = ""
    end
  end
end