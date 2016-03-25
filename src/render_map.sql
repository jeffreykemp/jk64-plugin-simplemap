function render_map (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
return apex_plugin.t_region_render_result
as
    subtype plugin_attr is varchar2(32767);

    -- Variables
    l_result    apex_plugin.t_region_render_result;
    l_script    varchar2(32767);
    l_region    varchar2(100);
    l_js_params varchar2(1000);
    l_lat       number;
    l_lng       number;

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
    l_mapstyle      plugin_attr := p_region.attribute_10;
    l_address_item  plugin_attr := p_region.attribute_11;
    l_geolocate     plugin_attr := p_region.attribute_12;
    l_geoloc_zoom   plugin_attr := p_region.attribute_13;
    
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
            l_js_params := l_js_params||'&'||'signed_in=true';
        END IF;
    ELSE
        -- these features require a Google API Key
        l_sign_in      := 'N';
        l_geocode_item := NULL;
        l_country      := NULL;
        l_address_item := NULL;
    END IF;

    APEX_JAVASCRIPT.add_library
      (p_name           => 'js' || l_js_params
      ,p_directory      => 'https://maps.googleapis.com/maps/api/'
      ,p_skip_extension => true);

    APEX_JAVASCRIPT.add_library
      (p_name           => 'jk64plugin.min'
      ,p_directory      => p_plugin.file_prefix);
    
    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,',')-1));
    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,',')+1));
    
    l_region := CASE
                WHEN p_region.static_id IS NOT NULL
                THEN p_region.static_id
                ELSE 'R'||p_region.id
                END;
    
    l_script := REPLACE('
var opt_#REGION# = {
   container: "map_#REGION#_container"
  ,regionId: "#REGION#"
  ,initZoom: '||l_zoom||'
  ,initLat: '||TO_CHAR(l_lat,'fm999.9999999999999999')||'
  ,initLng: '||TO_CHAR(l_lng,'fm999.9999999999999999')||'
  ,markerZoom: '||l_marker_zoom||'
  ,icon: "'||l_icon||'"
  ,syncItem: "'||l_item_name||'"
  ,geocodeItem: "'||l_geocode_item||'"
  ,country: "'||l_country||'"'||
  CASE WHEN l_mapstyle IS NOT NULL THEN '
  ,mapstyle: '||l_mapstyle
  END || '
  ,addressItem: "'||l_address_item||'"'||
  CASE WHEN l_geolocate = 'Y' THEN '
  ,geolocate: true' ||
    CASE WHEN l_geoloc_zoom IS NOT NULL THEN '
  ,geolocateZoom: '||l_geoloc_zoom
    END
  END || '
};
function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}
r_#REGION#(function(){
  jk64plugin_initMap(opt_#REGION#);
});
function click_#REGION#(lat,lng) {
  jk64plugin_setMarker(opt_#REGION#,lat,lng);
}
','#REGION#',l_region);

  sys.htp.p('<script>'||l_script||'</script>');
  sys.htp.p('<div id="map_'||l_region||'_container" style="min-height:'||l_region_height||'px"></div>');

  return l_result;
end render_map;