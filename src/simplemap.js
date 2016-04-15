var simplemap = {

geocode : function (opt,geocoder) {
  apex.debug("simplemap.geocode");
  geocoder.geocode(
    {address: $v(opt.geocodeItem)
    ,componentRestrictions: opt.country!==""?{country:opt.country}:{}
  }, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      apex.debug(opt.regionId+" geocode ok");
      var pos = results[0].geometry.location;
      simplemap.setMarker(opt,pos.lat(),pos.lng())
      if (opt.syncItem!=="") {
        $s(opt.syncItem,pos.lat()+","+pos.lng());
      }
    } else {
      apex.debug(opt.regionId+" geocode was unsuccessful for the following reason: "+status);
    }
  });
},

setMarker : function (opt,lat,lng) {
  apex.debug("simplemap.setMarker");
  if (lat!==null && lng!==null) {
    var oldpos = opt.marker?opt.marker.getPosition():new google.maps.LatLng(0,0);
    if (lat==oldpos.lat() && lng==oldpos.lng()) {
      apex.debug(opt.regionId+" marker not changed");
    } else {
      apex.debug(opt.regionId+" move marker");
      var pos = new google.maps.LatLng(lat,lng);
      opt.map.panTo(pos);
      if (opt.markerZoom) {
        opt.map.setZoom(opt.markerZoom);
      }
      if (opt.marker) {
        opt.marker.setMap(opt.map);
        opt.marker.setPosition(pos);
      } else {
        opt.marker = new google.maps.Marker({map: opt.map, position: pos, icon: opt.icon});
      }
    }
  } else if (opt.marker) {
    apex.debug(opt.regionId+" remove marker");
    opt.marker.setMap(null);
  }
},

getAddress : function (opt,lat,lng) {
  apex.debug("simplemap.getAddress");
	var latlng = {lat: lat, lng: lng};
	opt.geocoder.geocode({'location': latlng}, function(results, status) {
		if (status === google.maps.GeocoderStatus.OK) {
			for (i=0; i<results.length; i++) {
				apex.debug(opt.regionId+" result["+i+"]="+results[i].formatted_address+" ("+results[i].types.join()+")");
			}
			if (results[1]) {
				$s(opt.addressItem,results[0].formatted_address);
			} else {
				window.alert('Insufficient results found');
			}
		} else if (status === google.maps.GeocoderStatus.ZERO_RESULTS) {
			window.alert("No results found");
		} else {
			window.alert('Geocoder failed due to: ' + status);
		}
	});
},

init : function (opt) {
  apex.debug("simplemap.init");
	var myOptions = {
		zoom: opt.initZoom,
		center: new google.maps.LatLng(opt.initLat,opt.initLng),
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	opt.map = new google.maps.Map(document.getElementById(opt.container),myOptions);
	if (opt.mapstyle) {
		opt.map.setOptions({styles: opt.mapstyle});
	}
  if (opt.readonly) {
    //disable zoom/pan if readonly
    opt.map.setOptions({
       disableDefaultUI: true
      ,draggable: false
      ,zoomControl: false
      ,scrollwheel: false
      ,disableDoubleClickZoom: true
    });
  }
	if (opt.syncItem!=="") {
		var val = $v(opt.syncItem);
		if (val!==null && val.indexOf(",") > -1) {
			var arr = val.split(",");
			simplemap.setMarker(opt,arr[0],arr[1]);
		}
		$("#"+opt.syncItem).change(function(){ 
			var latlng = this.value;
			if (latlng!==null && latlng!==undefined && latlng.indexOf(",") > -1) {
				var arr = latlng.split(",");
				simplemap.setMarker(opt,arr[0],arr[1]);
			}    
		});
	}
	if (opt.addressItem!=="") {
		opt.geocoder = new google.maps.Geocoder;
	}
  if (!opt.readonly) {
    google.maps.event.addListener(opt.map, "click", function (event) {
      var lat = event.latLng.lat()
         ,lng = event.latLng.lng();
      simplemap.setMarker(opt,lat,lng);
      if (opt.syncItem!=="") {
        $s(opt.syncItem,lat+","+lng);
      }
      if (opt.addressItem!=="") {
        simplemap.getAddress(opt,lat,lng);
      }
      apex.jQuery("#"+opt.regionId).trigger("mapclick", {map:opt.map, lat:lat, lng:lng});
    });
  }
	if (opt.geocodeItem!="") {
		var geocoder = new google.maps.Geocoder();
		$("#"+opt.geocodeItem).change(function(){
			simplemap.geocode(opt,geocoder);
		});
	}
	if (opt.geolocate) {
		if (navigator.geolocation) {
			apex.debug(opt.regionId+" geolocate");
			navigator.geolocation.getCurrentPosition(function(position) {
				var pos = {
					lat: position.coords.latitude,
					lng: position.coords.longitude
				};
				opt.map.panTo(pos);
				if (opt.geolocateZoom) {
				  opt.map.setZoom(opt.geolocateZoom);
				}
				apex.jQuery("#"+opt.regionId).trigger("geolocate", {map:opt.map, lat:pos.lat, lng:pos.lng});
			});
		} else {
			apex.debug(opt.regionId+" browser does not support geolocation");
		}
	}
	apex.jQuery("#"+opt.regionId).trigger("maploaded", {map:opt.map});
}

}