$(document).ready(function() {
	// Individual page
  	mapCanvas = $('#mapCanvas');
	if(mapCanvas.length > 0) {

		var latlng, mapCanvas, myOptions;
		latlng = new google.maps.LatLng(-33.867, 151.206);
		myOptions = {
	    	zoom: 10,
	    	center: latlng,
	    	mapTypeId: google.maps.MapTypeId.ROADMAP
	  	};
	  	window.map = new google.maps.Map(document.getElementById("map"), myOptions);
	  	window.bounds = new google.maps.LatLngBounds();

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
	  	$.getJSON('/polygons/' + lga['lga_code'] + '.json', function(data) {
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
	}
	mapCanvas = $('#mapCanvasFull');
	if(mapCanvas.length > 0) {

		var latlng, mapCanvas, myOptions;
		latlng = new google.maps.LatLng(-33.867, 151.206);
		myOptions = {
	    	zoom: 10,
	    	center: latlng,
	    	mapTypeId: google.maps.MapTypeId.ROADMAP
	  	};
	  	window.map = new google.maps.Map(document.getElementById("map"), myOptions);
	  	window.bounds = new google.maps.LatLngBounds();

		$("#content").css({'padding':'0'});
		// Set the height - need to ensure onchange of window size this is recalled
		$("#mapCanvasFull").css({'height':((window.innerHeight - $("#footer")[0].clientHeight - $("#header")[0].clientHeight)+'px')})

	  	$.getJSON('/polygons.json', function(data) {
			var lgas = {};
			$.each(data[0], function(i,lga) {
				console.log(i);
				$.each(lga, function(j,v) {
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
				});
			});
			map.fitBounds(bounds);
	  	});
	}
	// If we're doing head2head
	if($('#content .head2head').length > 0) {
		$('#content .lga').each(function(){

			var lga = $(this);

			var latlng, myOptions;
			latlng = new google.maps.LatLng(-33.867, 151.206);
			myOptions = {
		    	zoom: 10,
		    	center: latlng,
		    	mapTypeId: google.maps.MapTypeId.ROADMAP,
				panControl: false,
				zoomControl: true,
				scaleControl: true,
				mapTypeControl: false,
				streetViewControl: false
		  	};

			if(lga[0].id == 'lga1') {
			  	window.map1 = new google.maps.Map(lga.find('.map')[0], myOptions);
			  	window.bounds1 = new google.maps.LatLngBounds();
				$.getJSON('/polygons/' + lga1['lga_code'] + '.json', function(data) {
					console.log(data);
					$.each(data[0][lga1['lga_code']+''], function(i,v) {
						var latlngs = [];
						bounds = new google.maps.LatLngBounds();
						$.each(v, function(index,value){
							var marker = new google.maps.LatLng(value[0], value[1]);
							latlngs.push(marker);
							bounds1.extend(marker);
						});

						var lga_overlay = new google.maps.Polygon({
					    	paths: latlngs,
					    	strokeColor: "#498FCD",
					    	strokeOpacity: 0.8,
					    	strokeWeight: 2,
					    	fillColor: "#498FCD",
					    	fillOpacity: 0.35
					  	});
					  	lga_overlay.setMap(map1);
						map1.fitBounds(bounds1);
					});
			  	});
			} else if (lga[0].id == 'lga2') {
			  	window.map2 = new google.maps.Map(lga.find('.map')[0], myOptions);
			  	window.bounds2 = new google.maps.LatLngBounds();
				$.getJSON('/polygons/' + lga2['lga_code'] + '.json', function(data) {
					console.log(data);
					$.each(data[0][lga2['lga_code']+''], function(i,v) {
						var latlngs = [];
						bounds = new google.maps.LatLngBounds();
						$.each(v, function(index,value){
							var marker = new google.maps.LatLng(value[0], value[1]);
							latlngs.push(marker);
							bounds2.extend(marker);
						});

						var lga_overlay = new google.maps.Polygon({
					    	paths: latlngs,
					    	strokeColor: "#498FCD",
					    	strokeOpacity: 0.8,
					    	strokeWeight: 2,
					    	fillColor: "#498FCD",
					    	fillOpacity: 0.35
					  	});
					  	lga_overlay.setMap(map2);
						map2.fitBounds(bounds2);
					});
			  	});
			}
		});
	}
});
