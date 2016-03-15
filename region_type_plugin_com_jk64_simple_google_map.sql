set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.2.00.07'
,p_default_workspace_id=>20749515040658038
,p_default_application_id=>560
,p_default_owner=>'SAMPLE'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/com_jk64_simple_google_map
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(65986014849483781)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.JK64.SIMPLE_GOOGLE_MAP'
,p_display_name=>'JK64 Simple Google Map'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'function render_map (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'return apex_plugin.t_region_render_result',
'as',
'    subtype plugin_attr is varchar2(32767);',
'',
'    -- Variables',
'    l_result apex_plugin.t_region_render_result;',
'    l_html varchar2(32767);',
'    l_lat NUMBER;',
'    l_lng NUMBER;',
'    l_js_params varchar2(1000);',
'',
'    -- Plugin attributes (application level)',
'    l_api_key       plugin_attr := p_plugin.attribute_01;',
'',
'    -- Component attributes',
'    l_latlong       plugin_attr := p_region.attribute_01;',
'    l_zoom          plugin_attr := p_region.attribute_02;',
'    l_region_height plugin_attr := p_region.attribute_03;',
'    l_item_name     plugin_attr := p_region.attribute_04;',
'    l_marker_zoom   plugin_attr := p_region.attribute_05;',
'    l_icon          plugin_attr := p_region.attribute_06;',
'    l_sign_in       plugin_attr := p_region.attribute_07;',
'    l_geocode_item  plugin_attr := p_region.attribute_08;',
'    l_country       plugin_attr := p_region.attribute_09;',
'    ',
'begin',
'    -- debug information will be included',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_region (',
'            p_plugin => p_plugin,',
'            p_region => p_region,',
'            p_is_printer_friendly => p_is_printer_friendly);',
'    end if;',
'',
'    IF l_api_key IS NOT NULL THEN',
'        l_js_params := ''?key='' || l_api_key;',
'        IF l_sign_in = ''Y'' THEN',
'            l_js_params := l_js_params || ''&''||''signed_in=true'';',
'        END IF;',
'    END IF;',
'',
'    APEX_JAVASCRIPT.add_library',
'      (p_name           => ''js'' || l_js_params',
'      ,p_directory      => ''https://maps.googleapis.com/maps/api/''',
'      ,p_version        => null',
'      ,p_skip_extension => true);',
'    ',
'    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,'','')-1));',
'    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,'','')+1));',
'    ',
'    l_html := q''[',
'<script>',
'var map_#REGION#, marker_#REGION#;',
'function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}',
'function geocode_#REGION#(geocoder) {',
'  var address = $v("#GEOCODEITEM#");',
'  geocoder.geocode({"address": address#COUNTRY_RESTRICT#}',
'  , function(results, status) {',
'    if (status === google.maps.GeocoderStatus.OK) {',
'      var pos = results[0].geometry.location;',
'      apex.debug("#REGION# geocode ok");',
'      map_#REGION#.setCenter(pos);',
'      map_#REGION#.panTo(pos);',
'      if ("#MARKERZOOM#" != "") {',
'        map_#REGION#.setZoom(#MARKERZOOM#);',
'      }',
'      setMarker_#REGION#(pos.lat(), pos.lng())',
'      if ("#ITEM#" !== "") {',
'        $s("#ITEM#",pos.lat()+","+pos.lng());',
'      }',
'    } else {',
'      apex.debug("#REGION# geocode was unsuccessful for the following reason: "+status);',
'    }',
'  });',
'}',
'function setMarker_#REGION#(lat,lng) {',
'  if (lat !== null && lng !== null) {',
'    var oldpos = marker_#REGION#?marker_#REGION#.getPosition():new google.maps.LatLng(0,0);',
'    if (lat == oldpos.lat() && lng == oldpos.lng()) {',
'      apex.debug("#REGION# marker not changed");',
'    } else {',
'      var pos = new google.maps.LatLng(lat,lng);',
'      map_#REGION#.panTo(pos);',
'      if ("#MARKERZOOM#" != "") {',
'        map_#REGION#.setZoom(#MARKERZOOM#);',
'      }',
'      if (marker_#REGION#) {',
'        marker_#REGION#.setMap(map_#REGION#);',
'        marker_#REGION#.setPosition(pos);',
'      } else {',
'        marker_#REGION# = new google.maps.Marker({map: map_#REGION#, position: pos, icon: "#ICON#"});',
'      }',
'    }',
'  } else if (marker_#REGION#) {',
'    marker_#REGION#.setMap(null);',
'  }',
'}',
'function initMap_#REGION#() {',
'  var myOptions = {',
'    zoom: #ZOOM#,',
'    center: new google.maps.LatLng(#LAT#,#LNG#),',
'    mapTypeId: google.maps.MapTypeId.ROADMAP',
'  };',
'  map_#REGION# = new google.maps.Map(document.getElementById("map_#REGION#_container"),myOptions);',
'  if ("#ITEM#" !== "") {',
'    var val = $v("#ITEM#");',
'    if (val !== null && val.indexOf(",") > -1) {',
'      var arr = val.split(",");',
'      setMarker_#REGION#(arr[0],arr[1]);',
'    }',
'    $("##ITEM#").change(function(){ ',
'      var latlng = this.value;',
'      if (latlng !== null && latlng !== undefined && latlng.indexOf(",") > -1) {',
'        var arr = latlng.split(",");',
'        setMarker_#REGION#(arr[0],arr[1]);',
'      }    ',
'    });',
'  }',
'  google.maps.event.addListener(map_#REGION#, "click", function (event) {',
'    var lat = event.latLng.lat()',
'       ,lng = event.latLng.lng();',
'    setMarker_#REGION#(lat,lng);',
'    if ("#ITEM#" !== "") {',
'      $s("#ITEM#",lat+","+lng);',
'    }',
'    apex.jQuery("##REGION#").trigger("mapclick", {map:map_#REGION#, lat:lat, lng:lng});',
'  });',
'  if ("#GEOCODEITEM#" != "") {',
'    var geocoder = new google.maps.Geocoder();',
'    $("##GEOCODEITEM#").change(function(){',
'      geocode_#REGION#(geocoder);',
'    });',
'  }',
'  apex.jQuery("##REGION#").trigger("maploaded", {map:map_#REGION#});',
'}',
'r_#REGION#(function(){',
'  initMap_#REGION#();',
'});',
'</script>',
'<div id="map_#REGION#_container" style="min-height:#HEIGHT#px"></div>',
']'';',
'  ',
'  l_html := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(',
'            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(',
'    l_html',
'    ,''#LAT#'',              TO_CHAR(l_lat,''fm999.9999999999999999''))',
'    ,''#LNG#'',              TO_CHAR(l_lng,''fm999.9999999999999999''))',
'    ,''#ZOOM#'',             l_zoom)',
'    ,''#HEIGHT#'',           l_region_height)',
'    ,''#ITEM#'',             l_item_name)',
'    ,''#MARKERZOOM#'',       l_marker_zoom)',
'    ,''#ICON#'',             l_icon)',
'    ,''#REGION#'',           CASE',
'                           WHEN p_region.static_id IS NOT NULL',
'                           THEN p_region.static_id',
'                           ELSE ''R''||p_region.id',
'                           END)',
'    ,''#GEOCODEITEM#'',      l_geocode_item)',
'    ,''#COUNTRY_RESTRICT#'', CASE WHEN l_country IS NOT NULL',
'                           THEN '',componentRestrictions:{country:"''||l_country||''"}''',
'                           END);',
'    ',
'  sys.htp.p(l_html);',
'',
'  return l_result;',
'end render_map;'))
,p_render_function=>'render_map'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Add a region of this type to your page and you have a map which the user can click to set a single Marker.',
'<BR>',
'To get the Latitude and Longitude of the Marker, add a Dynamic Action on the region responding to the "mapClick" event. In your javascript action for the DA, you can get the Latitude and Longitude via this.data.lat and this.data.lng, e.g.: <code>$s("'
||'P1_MY_ITEM", "You clicked at: " + this.data.lat + "," + this.data.lng);</code>. You can also manipulate the map, e.g. map.setZoom(4) to zoom in on the chosen location.',
'<BR>',
'To set the Marker position at runtime call <code>setMarker(lat,lng)</code> with the desired latitude and longitude. Note that calling setMarker will NOT fire the "mapClick" event.'))
,p_version_identifier=>'0.2'
,p_about_url=>'https://github.com/jeffreykemp/jk64-plugin-simplemap'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75150675458186518)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Google API Key'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Optional. If you don''t set this, you may get a "Google Maps API warning: NoApiKeys" warning in the console log. Refer: https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(66016458240245999)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Initial Map Position'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'0,0'
,p_max_length=>100
,p_unit=>'lat,long'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>'Set the latitude and longitude as a pair of numbers to be used to position the map on page load, if no pin coordinates have been provided by the page item.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65995876348751266)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Initial Zoom Level'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'1'
,p_max_length=>2
,p_unit=>'(0-23)'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>'Set the initial map zoom level on page load, to be used if the page item has no coordinates to show.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(65996524049776826)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Min. Map Height'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'400'
,p_max_length=>5
,p_unit=>'pixels'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>'Set the desired height for the map region. Note: the map width will adjust to the maximum available space.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(67654833683121936)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Synchronize with Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>'Position of the marker will be retrieved from and stored in this item as a Lat,Long value.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(67658848460295114)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Marker Zoom Level'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'16'
,p_unit=>'(0-23)'
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_help_text=>'If a marker is set or moved, zoom the map to this level. Leave blank to make the map not zoom when the marker is moved.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(69924777816380252)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Marker Icon'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>4000
,p_supported_ui_types=>'DESKTOP'
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'http://maps.google.com/mapfiles/ms/icons/blue-dot.png',
'http://maps.google.com/mapfiles/ms/icons/red-dot.png',
'http://maps.google.com/mapfiles/ms/icons/purple-dot.png',
'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png',
'http://maps.google.com/mapfiles/ms/icons/green-dot.png',
'http://maps.google.com/mapfiles/ms/icons/ylw-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/blue-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/grn-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/ltblu-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/pink-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/purple-pushpin.png',
'http://maps.google.com/mapfiles/ms/icons/red-pushpin.png'))
,p_help_text=>'URL to the icon to show for the marker. Leave blank for the default red Google pin.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75151750836192765)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Enable Google Sign-In'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Set to Yes to enable Google sign-in on the map. Only works if you set the Google API Key.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75154147036280094)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Geocode Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Set to a text item on the page. If the text item contains the name of a location or an address, a Google Maps Geocode search will be done and, if found, the map will be moved to that location and a pin shown. NOTE: requires a Google API key to be set'
||' at the application level.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(75154903326283475)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Restrict to Country code'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_max_length=>2
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(75154147036280094)
,p_depending_on_condition_type=>'NOT_NULL'
,p_text_case=>'UPPER'
,p_examples=>'AU'
,p_help_text=>'Leave blank to allow geocoding to find any place on earth. Set to country code (see https://developers.google.com/public-data/docs/canonical/countries_csv for valid values) to restrict geocoder to that country.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(65999677618912872)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_name=>'mapclick'
,p_display_name=>'mapClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(75152687385195635)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_name=>'maploaded'
,p_display_name=>'mapLoaded'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
