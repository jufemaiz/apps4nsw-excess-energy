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
		$('.loading').css('display','none');

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
			bounds = new google.maps.LatLngBounds();
			var infowindows = [];
			$.each(data[0], function(i,lga) {
				var lga_overlays = [];
				var _lga = lgas[i+''];
				$.each(lga, function(j,v) {
					var latlngs = [];
					$.each(v, function(index,value){
						var marker = new google.maps.LatLng(value[0], value[1]);
						latlngs.push(marker);
						bounds.extend(marker);
					});
					var color = color_gradient(_lga['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
					var lga_overlay = new google.maps.Polygon({
				    	paths: latlngs,
				    	strokeColor: color,
				    	strokeOpacity: 1,
				    	strokeWeight: 2,
				    	fillColor: color,
				    	fillOpacity: 0.4
				  	});
				  	lga_overlay.setMap(map);
					lga_overlays.push(lga_overlay);
					var infowindow = new google.maps.InfoWindow({
					    content: "<h3><a href='/lgas/"+ _lga.lga_code +"'>" + _lga.lga + " (" + _lga.lga_code + ")</a></h3><dl><dt>Totals</dt><dd><dl><dt>Population</dt><dd>" + _lga.population + "</dd><dt>Total Customers</dt><dd>" + _lga.total_customers + "</dd><dt>Total Energy</dt><dd>" + _lga.total_energy + "</dd><dt>Total Energy per Customer</dt><dd>" + _lga.total_energy_per_customer + "</dd><dt>Total Energy per Resident</dt><dd>" + _lga.total_energy_per_resident + "</dd></dl></dd><!--<dt>Residential</dt><dd><dl><dt>Total Customers</dt><dd>" + _lga.residential_customers + "</dd><dt>Total Energy</dt><dd>" + _lga.total_residential_energy + "</dd><dt>per Customer</dt><dd>" + _lga.total_residential_energy_per_customer + "</dd><dt>per Resident</dt><dd>" + _lga.total_residential_energy_per_resident + "</dd></dl></dd><dt>Business</dt><dd><dl><dt>Total Customers</dt><dd>" + _lga.total_business_customers + "</dd><dt>Total Energy</dt><dd>" + _lga.total_business_energy + "</dd><dt>per Customer</dt><dd>" + _lga.total_business_energy_per_customer + "</dd></dl></dd>--></dl>"
					});
					google.maps.event.addListener(lga_overlay, 'click', function(event) {
						$.each(infowindows,function(){ this.close(); });
						infowindow.setPosition(event.latLng)
						infowindow.open(map);
					});
					infowindows.push(infowindow);
				});
				_lga['mapOverlays'] = lga_overlays;
			});
			map.fitBounds(bounds);
	  	});
	
		$('dl.control a').click(function(ev){
			ev.preventDefault();
			ev.stopPropagation();
			$('dl.control a').removeClass('active');
			var el = $(ev.currentTarget);
			var href = el.attr('href').replace('#','');
			$.each(lgas,function(){
				var color;
				switch(href) {
					case 'population':
						color = color_gradient(this['population'],lga_stats['total']['population']);
						break;
					case 'total_customers':
						color = color_gradient(this['total_customers'],lga_stats['total']['customers']);
						break;
					case 'total_energy':
						color = color_gradient(this['total_energy'],lga_stats['total']['energy']);
						break;
					case 'total_energy_per_customer':
						color = color_gradient(this['total_energy_per_customer'],lga_stats['total']['per_customer']);
						break;
					case 'total_energy_per_resident':
						color = color_gradient(this['total_energy_per_resident'],lga_stats['total']['per_resident']);
						break;
					case 'residential_customers':
						color = color_gradient(this['residential_customers'],lga_stats['residential']['total']['customers']);
						break;
					case 'total_residential_energy':
						color = color_gradient(this['total_residential_energy'],lga_stats['residential']['total']['energy']);
						break;
					case 'total_residential_energy_per_customer':
						color = color_gradient(this['total_residential_energy_per_customer'],lga_stats['residential']['total']['per_customer']);
						break;
					case 'total_residential_energy_per_resident':
						color = color_gradient(this['total_residential_energy_per_resident'],lga_stats['residential']['total']['per_resident']);
						break;
					case 'total_business_customers':
						color = color_gradient(this['total_business_customers'],lga_stats['business']['total']['customers']);
						break;
					case 'total_business_energy':
						color = color_gradient(this['total_business_energy'],lga_stats['business']['total']['energy']);
						break;
					case 'total_business_energy_per_customer':
						color = color_gradient(this['total_business_energy_per_customer'],lga_stats['business']['total']['per_customer']);
						break;
					default:
						return false;
				}
				$.each(this['mapOverlays'],function(){
					this.setOptions({strokeColor:color, fillColor:color});
				});
			});
			el.addClass('active');
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
					case 'residential_customers':
						color[0] = color_gradient(lga1['residential_customers'],lga_stats['residential']['total']['customers']);
						color[1] = color_gradient(lga2['residential_customers'],lga_stats['residential']['total']['customers']);
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
		
		$('.head2head .lga dl').each(function(){
			var el = $(this);
			el.find('dd').hover(
				function(){
					var el_on = $(this);
					var elements = $('.'+el_on[0].className);
					var lga1_showing = true;
					if(el_on.parentsUntil('.lga').last().parent()[0].id != 'lga1') {
						lga1_showing = false;
					}
					var left = (lga1_showing ? '-10px' : (-1 * (el.width() + 20) )+'px');
					var lga1_value = elements.first().find('span.number').html().replace(/,/g,'')*1;
					var lga2_value = elements.last().find('span.number').html().replace(/,/g,'')*1;
					var lga1_percent = Math.round(100 * lga1_value / lga2_value);
					var lga2_percent = Math.round(100 * lga2_value / lga1_value);
					var highlight = $('<div class="highlight"><div class="content"><div class="column span-12" style="text-align: right;"><span class="percent">' + (lga1_percent > 100 ? (lga1_percent - 100) + '%</span> <strong>more</strong> than ': (100 - lga1_percent) + '%</span> <strong>less</strong> than ' ) + lga2['lga'] + ' </div><div class="column span-12 last" style="text-align: left;"><span class="percent">' + (lga2_percent > 100 ? (lga2_percent - 100) + '%</span> <strong>more</strong> than ': (100 - lga2_percent) + '%</span> <strong>less</strong> than ' ) + lga1['lga'] + ' </div></div></div>');
					
					highlight.css({'position':'absolute', 'z-index':'75','top': '-'+(el_on.prev().height()+10)+'px', 'left':left, 'width':(2 * el_on.width() +10)+'px','padding':(el_on.prev().height() + el_on.height() + 10)+'px 10px 10px 10px', 'border':'2px solid #ccc', '-moz-border-radius':'10px', '-webkit-border-radius':'10px', 'border-radius':'10px', 'background':'#fff' });

					el_on.append(highlight);
					$('.'+el_on[0].className).prev().css({'position':'relative', 'z-index':'100'});
					$('.'+el_on[0].className).find('span').css({'z-index':'101'});
					$('.'+el_on[0].className).find('span.number').css({'z-index':'102'});
				},
				function(){
					var el_off = $(this);
					el_off.find('.highlight').remove();
					$('.lga').find('dt').css({'z-index':'0'});
					$('.lga').find('span').css({'z-index':'50'});
					$('.lga').find('span.number').css({'z-index':'51'});
				}
			);
		});
	}
	$('dl.control').hover(
		function(){
			$(this).addClass('open');
		},
		function(){
			$(this).removeClass('open');
		}
	);
	
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