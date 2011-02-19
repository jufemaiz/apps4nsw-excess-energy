$(document).ready(function() {
	var latlng, mapCanvas, myOptions;
	latlng = new google.maps.LatLng(-33.867, 151.206);
	myOptions = {
    	zoom: 10,
    	center: latlng,
    	mapTypeId: google.maps.MapTypeId.ROADMAP
  	};
  	window.map = new google.maps.Map(document.getElementById("map"), myOptions);
  	window.bounds = new google.maps.LatLngBounds();
  	mapCanvas = $('#mapCanvas');
  	mapCanvas.css({'display': 'block'});
  	$('#controller span', mapCanvas).click(function(ev) {
    	var center, el;
    	ev.preventDefault();
    	ev.stopPropagation();
    	center = window.map.getCenter();
    	el = $(this.parentNode.parentNode);
    	if (el.hasClass('collapsed')) {
      		el.animate({'height': '500px'}, 1000, function() {
        		el.attr('innerHtml', 'Contract');
        		google.maps.event.trigger(window.map, 'resize');
				map.fitBounds(bounds);
        		window.map.setCenter(center);
				$('#controller span', mapCanvas).html('Contract');
      		});
    	} else {
      		el.animate({'height': '100px'}, 1000, function() {
        		el.attr('innerHtml', 'Expand');
        		google.maps.event.trigger(window.map, 'resize');
				map.fitBounds(bounds);
        		window.map.setCenter(center);
				$('#controller span', mapCanvas).html('Expand');
      		});
    	}
    	el.toggleClass('collapsed');
  	});
  	$.getJSON('/polygons.json', function(data) {
		$.each(data[0][lga['lga_code']+''], function(i,v) {
			var latlngs = [];
			bounds = new google.maps.LatLngBounds();
			$.each(v, function(index,value){
				var marker = new google.maps.LatLng(value[0], value[1]);
				latlngs.push(marker);
				bounds.extend(marker);
			});

			var lga_overlay = new google.maps.Polygon({
		    	paths: latlngs,
		    	strokeColor: "#498FCD",
		    	strokeOpacity: 0.8,
		    	strokeWeight: 2,
		    	fillColor: "#498FCD",
		    	fillOpacity: 0.35
		  	});
		  	lga_overlay.setMap(map);
			map.fitBounds(bounds);
		});
  	});
});
