$(document).ready ->
  latlng = new google.maps.LatLng(-33.867, 151.206)
  myOptions = { zoom: 10, center: latlng, mapTypeId: google.maps.MapTypeId.ROADMAP }
  window.map = new google.maps.Map(document.getElementById("map"),myOptions)
  window.bounds = new google.maps.LatLngBounds()

  mapCanvas = $('#mapCanvas')
  mapCanvas.css({'display':'block'})
  
  $('#controller span', mapCanvas).click (ev) ->
    ev.preventDefault()
    ev.stopPropagation()
    center = window.map.getCenter()
    el = $(this.parentNode.parentNode)
    if el.hasClass('collapsed')
      el.animate {'height':'500px'},1000, () ->
        el.attr('innerHtml','Contract')
        google.maps.event.trigger(window.map, 'resize')
        window.map.setCenter(center)
    else
      el.animate {'height':'100px'},1000, () ->
        el.attr('innerHtml','Expand')
        google.maps.event.trigger(window.map, 'resize')
        window.map.setCenter(center)
    el.toggleClass('collapsed')
  true
  
  $.get '/js/json/polygons.json', (data) ->
    $("#content h1").html(data)
    true
  true