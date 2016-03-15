function jk64plugin_geocode(opt,geocoder) {
  geocoder.geocode(
    {address: $v(opt.geocodeItem)
    ,componentRestrictions: opt.country!==""?{country:opt.country}:{}
  }, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      apex.debug(opt.regionId+" geocode ok");
      var pos = results[0].geometry.location;
      jk64plugin_setMarker(opt,pos.lat(),pos.lng())
      if (opt.syncItem!=="") {
        $s(opt.syncItem,pos.lat()+","+pos.lng());
      }
    } else {
      apex.debug(opt.regionId+" geocode was unsuccessful for the following reason: "+status);
    }
  });
}

function jk64plugin_setMarker(opt,lat,lng) {
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
}

function jk64plugin_initMap(opt) {
  var myOptions = {
    zoom: opt.initZoom,
    center: new google.maps.LatLng(opt.initLat,opt.initLng),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  opt.map = new google.maps.Map(document.getElementById(opt.container),myOptions);
  if (opt.syncItem!=="") {
    var val = $v(opt.syncItem);
    if (val!==null && val.indexOf(",") > -1) {
      var arr = val.split(",");
      jk64plugin_setMarker(opt,arr[0],arr[1]);
    }
    $("#"+opt.syncItem).change(function(){ 
      var latlng = this.value;
      if (latlng!==null && latlng!==undefined && latlng.indexOf(",") > -1) {
        var arr = latlng.split(",");
        jk64plugin_setMarker(opt,arr[0],arr[1]);
      }    
    });
  }
  google.maps.event.addListener(opt.map, "click", function (event) {
    var lat = event.latLng.lat()
       ,lng = event.latLng.lng();
    jk64plugin_setMarker(opt,lat,lng);
    if (opt.syncItem!=="") {
      $s(opt.syncItem,lat+","+lng);
    }
    apex.jQuery("#"+opt.regionId).trigger("mapclick", {map:opt.map, lat:lat, lng:lng});
  });
  if (opt.geocodeItem!="") {
    var geocoder = new google.maps.Geocoder();
    $("#"+opt.geocodeItem).change(function(){
      jk64plugin_geocode(opt,geocoder);
    });
  }
  apex.jQuery("#"+opt.regionId).trigger("maploaded", {map:opt.map});
}
