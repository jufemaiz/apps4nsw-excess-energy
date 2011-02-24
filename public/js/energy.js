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
			    	strokeColor: "#2fb755",
			    	strokeOpacity: 0.8,
			    	strokeWeight: 2,
			    	fillColor: "#2fb755",
			    	fillOpacity: 0.35
			  	});
			  	lga_overlay.setMap(map);
				map.fitBounds(bounds);
			});
	  	});
	}
	
	// If we're doing the full page
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
			bounds = new google.maps.LatLngBounds();
			$.each(data[0], function(i,lga) {
				$.each(lga, function(j,v) {
					var latlngs = [];
					$.each(v, function(index,value){
						var marker = new google.maps.LatLng(value[0], value[1]);
						latlngs.push(marker);
						bounds.extend(marker);
					});

					var lga_overlay = new google.maps.Polygon({
				    	paths: latlngs,
				    	strokeColor: "#2fb755",
				    	strokeOpacity: 0.8,
				    	strokeWeight: 2,
				    	fillColor: "#2fb755",
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
					$.each(data[0][lga1['lga_code']+''], function(i,v) {
						var latlngs = [];
						bounds = new google.maps.LatLngBounds();
						$.each(v, function(index,value){
							var marker = new google.maps.LatLng(value[0], value[1]);
							latlngs.push(marker);
							bounds1.extend(marker);
						});
						// var color = $($('#lga1 span.percentage.color')[5]).css('background-color');
						var color = color_gradient(lga1['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
						var lga_overlay = new google.maps.Polygon({
					    	paths: latlngs,
					    	strokeColor: color,
					    	strokeOpacity: 0.8,
					    	strokeWeight: 2,
					    	fillColor: color,
					    	fillOpacity: 0.35
					  	});
						lga1['mapOverlay'] = lga_overlay;
					  	lga_overlay.setMap(map1);
						map1.fitBounds(bounds1);
					});
			  	});
			} else if (lga[0].id == 'lga2') {
			  	window.map2 = new google.maps.Map(lga.find('.map')[0], myOptions);
			  	window.bounds2 = new google.maps.LatLngBounds();
				$.getJSON('/polygons/' + lga2['lga_code'] + '.json', function(data) {
					$.each(data[0][lga2['lga_code']+''], function(i,v) {
						var latlngs = [];
						bounds = new google.maps.LatLngBounds();
						$.each(v, function(index,value){
							var marker = new google.maps.LatLng(value[0], value[1]);
							latlngs.push(marker);
							bounds2.extend(marker);
						});
						// var color = $($('#lga2 span.percentage.color')[5]).css('background-color');
						var color = color_gradient(lga2['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
						var lga_overlay = new google.maps.Polygon({
					    	paths: latlngs,
					    	strokeColor: color,
					    	strokeOpacity: 0.8,
					    	strokeWeight: 2,
					    	fillColor: color,
					    	fillOpacity: 0.35
					  	});
						lga2['mapOverlay'] = lga_overlay;
					  	lga_overlay.setMap(map2);
						map2.fitBounds(bounds2);
					});
			  	});
			}
			
			$('dl.control a').click(function(ev){
				ev.preventDefault();
				ev.stopPropagation();
				var el = $(ev.currentTarget);
				var href = el.attr('href').replace('#','');
				var color = [];
				switch(href) {
					case 'population':
						color[0] = color_gradient(lga1['population'],lga_stats['total']['population']);
						color[1] = color_gradient(lga2['population'],lga_stats['total']['population']);
						break;
					case 'total_customers':
						color[0] = color_gradient(lga1['total_customers'],lga_stats['total']['customers']);
						color[1] = color_gradient(lga2['total_customers'],lga_stats['total']['customers']);
						break;
					case 'total_energy':
						color[0] = color_gradient(lga1['total_energy'],lga_stats['total']['energy']);
						color[1] = color_gradient(lga2['total_energy'],lga_stats['total']['energy']);
						break;
					case 'total_energy_per_customer':
						color[0] = color_gradient(lga1['total_energy_per_customer'],lga_stats['total']['per_customer']);
						color[1] = color_gradient(lga2['total_energy_per_customer'],lga_stats['total']['per_customer']);
						break;
					case 'total_energy_per_resident':
						color[0] = color_gradient(lga1['total_energy_per_resident'],lga_stats['total']['per_resident']);
						color[1] = color_gradient(lga2['total_energy_per_resident'],lga_stats['total']['per_resident']);
						break;
					case 'total_residential_customers':
						color[0] = color_gradient(lga1['total_residential_customers'],lga_stats['residential']['total']['customers']);
						color[1] = color_gradient(lga2['total_residential_customers'],lga_stats['residential']['total']['customers']);
						break;
					case 'total_residential_energy':
						color[0] = color_gradient(lga1['total_residential_energy'],lga_stats['residential']['total']['energy']);
						color[1] = color_gradient(lga2['total_residential_energy'],lga_stats['residential']['total']['energy']);
						break;
					case 'total_residential_energy_per_customer':
						color[0] = color_gradient(lga1['total_residential_energy_per_customer'],lga_stats['residential']['total']['per_customer']);
						color[1] = color_gradient(lga2['total_residential_energy_per_customer'],lga_stats['residential']['total']['per_customer']);
						break;
					case 'total_residential_energy_per_resident':
						color[0] = color_gradient(lga1['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
						color[1] = color_gradient(lga2['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
						break;
					case 'total_business_customers':
						color[0] = color_gradient(lga1['total_business_customers'],lga_stats['business']['total']['customers']);
						color[1] = color_gradient(lga2['total_business_customers'],lga_stats['business']['total']['customers']);
						break;
					case 'total_business_energy':
						color[0] = color_gradient(lga1['total_business_energy'],lga_stats['business']['total']['energy']);
						color[1] = color_gradient(lga2['total_business_energy'],lga_stats['business']['total']['energy']);
						break;
					case 'total_business_energy_per_customer':
						color[0] = color_gradient(lga1['total_business_energy_per_customer'],lga_stats['business']['total']['per_customer']);
						color[1] = color_gradient(lga2['total_business_energy_per_customer'],lga_stats['business']['total']['per_customer']);
						break;
					default:
						return false;
				}
				lga1['mapOverlay'].setOptions({strokeColor:color[0], fillColor:color[0]});
				lga2['mapOverlay'].setOptions({strokeColor:color[1], fillColor:color[1]});
			});
		});

		if($('#lgaH2H').length > 0) {
			$('#update').click(function(){
				if($(this).hasClass('visible')) {
					$('#lgaH2H').css({'display':'none'});
					$(this).html('edit');
				} else {
					$('#lgaH2H').css({'display':'block'});
					$(this).html('hide');
				}
				$(this).toggleClass('visible');
			}).css({'display':''});
		}
		$('dl.control').hover(
			function(){
				$(this).addClass('open');
			},
			function(){
				$(this).removeClass('open');
			}
		);
	}
});

function color_gradient(value, details) {
	var max = "ff3333", average = "ffe539", min = "49cd6e", color_gradient = min;
	
	var percent = value / (details['max']);
    var percent_max_min_lower = (value - details['min']) / (details['average'] - details['min']);
    var percent_max_min_upper = (value - details['average']) / (details['max'] - details['average']);

	if(value <= details['min']){
      color_gradient = min;
	} else if (value == details['average']) {
		value == details['average'];
	    color_gradient = average;
	} else if (value >= details['max']) {
		color_gradient = max;
	} else if (value > details['min'] && value < details['average']) {
		var red =   pad(Math.round(parseInt(min.substring(0,2),16) + percent_max_min_lower * (parseInt(average.substring(0,2),16) - parseInt(min.substring(0,2),16))).toString(16),2);
		var green = pad(Math.round(parseInt(min.substring(2,4),16) + percent_max_min_lower * (parseInt(average.substring(2,4),16) - parseInt(min.substring(2,4),16))).toString(16),2);
		var blue =  pad(Math.round(parseInt(min.substring(4,6),16) + percent_max_min_lower * (parseInt(average.substring(4,6),16) - parseInt(min.substring(4,6),16))).toString(16),2);
		color_gradient = red + green + blue
	} else if (value > details['average'] && value < details['max']) {
		var red =   pad(Math.round(parseInt(average.substring(0,2),16) + percent_max_min_upper * (parseInt(max.substring(0,2),16) - parseInt(average.substring(0,2),16))).toString(16),2);
		var green = pad(Math.round(parseInt(average.substring(2,4),16) + percent_max_min_upper * (parseInt(max.substring(2,4),16) - parseInt(average.substring(2,4),16))).toString(16),2);
		var blue =  pad(Math.round(parseInt(average.substring(4,6),16) + percent_max_min_upper * (parseInt(max.substring(4,6),16) - parseInt(average.substring(4,6),16))).toString(16),2);
		color_gradient = red + green + blue
	}
    return "#" + color_gradient;
}

function pad(number, length) {
	var str = '' + number;
	while (str.length < length) { str = '0' + str; }
    return str;
}