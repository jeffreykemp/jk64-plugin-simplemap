function render_map (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
return apex_plugin.t_region_render_result
as
    subtype plugin_attr is varchar2(32767);

    -- Variables
    l_result apex_plugin.t_region_render_result;
    l_html varchar2(32767);
    l_lat NUMBER;
    l_lng NUMBER;
    l_js_params varchar2(1000);

    -- Plugin attributes (application level)
    l_api_key       plugin_attr := p_plugin.attribute_01;

    -- Component attributes
    l_latlong       plugin_attr := p_region.attribute_01;
    l_zoom          plugin_attr := p_region.attribute_02;
    l_region_height plugin_attr := p_region.attribute_03;
    l_item_name     plugin_attr := p_region.attribute_04;
    l_marker_zoom   plugin_attr := p_region.attribute_05;
    l_icon          plugin_attr := p_region.attribute_06;
    l_sign_in       plugin_attr := p_region.attribute_07;
    l_geocode_item  plugin_attr := p_region.attribute_08;
    l_country       plugin_attr := p_region.attribute_09;
    
begin
    -- debug information will be included
    if apex_application.g_debug then
        apex_plugin_util.debug_region (
            p_plugin => p_plugin,
            p_region => p_region,
            p_is_printer_friendly => p_is_printer_friendly);
    end if;

    IF l_api_key IS NOT NULL THEN
        l_js_params := '?key=' || l_api_key;
        IF l_sign_in = 'Y' THEN
            l_js_params := l_js_params || '&'||'signed_in=true';
        END IF;
    END IF;

    APEX_JAVASCRIPT.add_library
      (p_name           => 'js' || l_js_params
      ,p_directory      => 'https://maps.googleapis.com/maps/api/'
      ,p_version        => null
      ,p_skip_extension => true);
    
    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,',')-1));
    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,',')+1));
    
    l_html := q'[
<script>
var map_#REGION#, marker_#REGION#;
function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}
function geocode_#REGION#(geocoder) {
  var address = $v("#GEOCODEITEM#");
  geocoder.geocode({"address": address#COUNTRY_RESTRICT#}
  , function(results, status) {
    if (status === google.maps.GeocoderStatus.OK) {
      var pos = results[0].geometry.location;
      apex.debug("#REGION# geocode ok");
      map_#REGION#.setCenter(pos);
      map_#REGION#.panTo(pos);
      if ("#MARKERZOOM#" != "") {
        map_#REGION#.setZoom(#MARKERZOOM#);
      }
      setMarker_#REGION#(pos.lat(), pos.lng())
      if ("#ITEM#" !== "") {
        $s("#ITEM#",pos.lat()+","+pos.lng());
      }
    } else {
      apex.debug("#REGION# geocode was unsuccessful for the following reason: "+status);
    }
  });
}
function setMarker_#REGION#(lat,lng) {
  if (lat !== null && lng !== null) {
    var oldpos = marker_#REGION#?marker_#REGION#.getPosition():new google.maps.LatLng(0,0);
    if (lat == oldpos.lat() && lng == oldpos.lng()) {
      apex.debug("#REGION# marker not changed");
    } else {
      var pos = new google.maps.LatLng(lat,lng);
      map_#REGION#.panTo(pos);
      if ("#MARKERZOOM#" != "") {
        map_#REGION#.setZoom(#MARKERZOOM#);
      }
      if (marker_#REGION#) {
        marker_#REGION#.setMap(map_#REGION#);
        marker_#REGION#.setPosition(pos);
      } else {
        marker_#REGION# = new google.maps.Marker({map: map_#REGION#, position: pos, icon: "#ICON#"});
      }
    }
  } else if (marker_#REGION#) {
    marker_#REGION#.setMap(null);
  }
}
function initMap_#REGION#() {
  var myOptions = {
    zoom: #ZOOM#,
    center: new google.maps.LatLng(#LAT#,#LNG#),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map_#REGION# = new google.maps.Map(document.getElementById("map_#REGION#_container"),myOptions);
  if ("#ITEM#" !== "") {
    var val = $v("#ITEM#");
    if (val !== null && val.indexOf(",") > -1) {
      var arr = val.split(",");
      setMarker_#REGION#(arr[0],arr[1]);
    }
    $("##ITEM#").change(function(){ 
      var latlng = this.value;
      if (latlng !== null && latlng !== undefined && latlng.indexOf(",") > -1) {
        var arr = latlng.split(",");
        setMarker_#REGION#(arr[0],arr[1]);
      }    
    });
  }
  google.maps.event.addListener(map_#REGION#, "click", function (event) {
    var lat = event.latLng.lat()
       ,lng = event.latLng.lng();
    setMarker_#REGION#(lat,lng);
    if ("#ITEM#" !== "") {
      $s("#ITEM#",lat+","+lng);
    }
    apex.jQuery("##REGION#").trigger("mapclick", {map:map_#REGION#, lat:lat, lng:lng});
  });
  if ("#GEOCODEITEM#" != "") {
    var geocoder = new google.maps.Geocoder();
    $("##GEOCODEITEM#").change(function(){
      geocode_#REGION#(geocoder);
    });
  }
  apex.jQuery("##REGION#").trigger("maploaded", {map:map_#REGION#});
}
r_#REGION#(function(){
  initMap_#REGION#();
});
</script>
<div id="map_#REGION#_container" style="min-height:#HEIGHT#px"></div>
]';
  
  l_html := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    l_html
    ,'#LAT#',              TO_CHAR(l_lat,'fm999.9999999999999999'))
    ,'#LNG#',              TO_CHAR(l_lng,'fm999.9999999999999999'))
    ,'#ZOOM#',             l_zoom)
    ,'#HEIGHT#',           l_region_height)
    ,'#ITEM#',             l_item_name)
    ,'#MARKERZOOM#',       l_marker_zoom)
    ,'#ICON#',             l_icon)
    ,'#REGION#',           CASE
                           WHEN p_region.static_id IS NOT NULL
                           THEN p_region.static_id
                           ELSE 'R'||p_region.id
                           END)
    ,'#GEOCODEITEM#',      l_geocode_item)
    ,'#COUNTRY_RESTRICT#', CASE WHEN l_country IS NOT NULL
                           THEN ',componentRestrictions:{country:"'||l_country||'"}'
                           END);
    
  sys.htp.p(l_html);

  return l_result;
end render_map;