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

    -- Component attributes
    l_latlong       plugin_attr := p_region.attribute_01;
    l_zoom          plugin_attr := p_region.attribute_02;
    l_region_height plugin_attr := p_region.attribute_03;
    l_item_name     plugin_attr := p_region.attribute_04;
    l_marker_zoom   plugin_attr := p_region.attribute_05;
    l_lat NUMBER;
    l_lng NUMBER;
begin
    -- debug information will be included
    if apex_application.g_debug then
        apex_plugin_util.debug_region (
            p_plugin => p_plugin,
            p_region => p_region,
            p_is_printer_friendly => p_is_printer_friendly);
    end if;
    
    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,',')-1));
    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,',')+1));
    
    l_html := q'[
<script>
var map, marker;
function setMarker(map,lat,lng) {
  if (lat !== null && lng !== null) {
    var pos = new google.maps.LatLng(lat,lng);
    map.panTo(pos);
    if ("#MARKERZOOM#" != "") {
      map.setZoom(#MARKERZOOM#);
    }
    if (marker) {
      marker.setMap(map);
      marker.setPosition(pos);
    } else {
      marker = new google.maps.Marker({map: map, position: pos});
    }
  } else if (marker) {
    marker.setMap(null);
  }
}
function initMap() {
  var itemname = "#ITEM#"
     ,lat = #LAT#
     ,lng = #LNG#
  var latlng = new google.maps.LatLng(lat,lng);
  var myOptions = {
    zoom: #ZOOM#,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("#REGION_ID#_map"),myOptions);
  if (itemname !== "") {
    var val = $v(itemname);
    if (val !== null && val.indexOf(",") > -1) {
      var arr = val.split(",");
      setMarker(map,arr[0],arr[1]);
    }
    $("#"+itemname).change(function(){ 
      var latlng = this.value;
      if (latlng !== null && latlng !== undefined && latlng.indexOf(",") > -1) {
        var arr = latlng.split(",");
        setMarker(map,arr[0],arr[1]);
      }    
    });
  }
  google.maps.event.addListener(map, 'click', function (event) {
    var lat = event.latLng.lat()
       ,lng = event.latLng.lng();
    setMarker(map,lat,lng);
    if ("#ITEM#" !== "") {
      $s("#ITEM#",lat+","+lng);
    }
    apex.jQuery("##REGION_ID#").trigger("mapclick", {lat:lat, lng:lng});
  });
}
window.onload = function() {
  initMap();
}
</script>
<div id="#REGION_ID#_map" style="min-height:#HEIGHT#px"></div>
]';
  
  l_html := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_html
    ,'#LAT#',          l_lat)
    ,'#LNG#',          l_lng)
    ,'#ZOOM#',         l_zoom)
    ,'#HEIGHT#',       l_region_height)
    ,'#ITEM#',         l_item_name)
    ,'#MARKERZOOM#',   l_marker_zoom)
    ,'#REGION_ID#',    CASE
                       WHEN p_region.static_id IS NOT NULL
                       THEN p_region.static_id
                       ELSE 'R'||p_region.id
                       END);
    
  sys.htp.p(l_html);

  return l_result;
end render_map;