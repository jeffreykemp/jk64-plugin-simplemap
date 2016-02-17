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
,p_supported_ui_types=>'DESKTOP'
,p_javascript_file_urls=>'https://maps.googleapis.com/maps/api/js'
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
'',
'    -- Component attributes',
'    l_latlong       plugin_attr := p_region.attribute_01;',
'    l_zoom          plugin_attr := p_region.attribute_02;',
'    l_region_height plugin_attr := p_region.attribute_03;',
'    l_item_name     plugin_attr := p_region.attribute_04;',
'    l_marker_zoom   plugin_attr := p_region.attribute_05;',
'    l_lat NUMBER;',
'    l_lng NUMBER;',
'begin',
'    -- debug information will be included',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_region (',
'            p_plugin => p_plugin,',
'            p_region => p_region,',
'            p_is_printer_friendly => p_is_printer_friendly);',
'    end if;',
'    ',
'    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,'','')-1));',
'    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,'','')+1));',
'    ',
'    l_html := q''[',
'<script>',
'var map, marker;',
'function setMarker(map,lat,lng) {',
'  if (lat !== null && lng !== null) {',
'    var pos = new google.maps.LatLng(lat,lng);',
'    map.panTo(pos);',
'    if ("#MARKERZOOM#" != "") {',
'      map.setZoom(#MARKERZOOM#);',
'    }',
'    if (marker) {',
'      marker.setMap(map);',
'      marker.setPosition(pos);',
'    } else {',
'      marker = new google.maps.Marker({map: map, position: pos});',
'    }',
'  } else if (marker) {',
'    marker.setMap(null);',
'  }',
'}',
'function initMap() {',
'  var itemname = "#ITEM#"',
'     ,lat = #LAT#',
'     ,lng = #LNG#',
'  var latlng = new google.maps.LatLng(lat,lng);',
'  var myOptions = {',
'    zoom: #ZOOM#,',
'    center: latlng,',
'    mapTypeId: google.maps.MapTypeId.ROADMAP',
'  };',
'  map = new google.maps.Map(document.getElementById("#REGION_ID#_map"),myOptions);',
'  if (itemname !== "") {',
'    var val = $v(itemname);',
'    if (val !== null && val.indexOf(",") > -1) {',
'      var arr = val.split(",");',
'      setMarker(map,arr[0],arr[1]);',
'    }',
'    $("#"+itemname).change(function(){ ',
'      var latlng = this.value;',
'      if (latlng !== null && latlng !== undefined && latlng.indexOf(",") > -1) {',
'        var arr = latlng.split(",");',
'        setMarker(map,arr[0],arr[1]);',
'      }    ',
'    });',
'  }',
'  google.maps.event.addListener(map, ''click'', function (event) {',
'    var lat = event.latLng.lat()',
'       ,lng = event.latLng.lng();',
'    setMarker(map,lat,lng);',
'    if ("#ITEM#" !== "") {',
'      $s("#ITEM#",lat+","+lng);',
'    }',
'    apex.jQuery("##REGION_ID#").trigger("mapclick", {lat:lat, lng:lng});',
'  });',
'}',
'window.onload = function() {',
'  initMap();',
'}',
'</script>',
'<div id="#REGION_ID#_map" style="min-height:#HEIGHT#px"></div>',
']'';',
'  ',
'  l_html := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_html',
'    ,''#LAT#'',          l_lat)',
'    ,''#LNG#'',          l_lng)',
'    ,''#ZOOM#'',         l_zoom)',
'    ,''#HEIGHT#'',       l_region_height)',
'    ,''#ITEM#'',         l_item_name)',
'    ,''#MARKERZOOM#'',   l_marker_zoom)',
'    ,''#REGION_ID#'',    CASE',
'                       WHEN p_region.static_id IS NOT NULL',
'                       THEN p_region.static_id',
'                       ELSE ''R''||p_region.id',
'                       END);',
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
,p_version_identifier=>'0.1'
,p_plugin_comment=>'Get latest version, send feedback and raise issues at: https://bitbucket.org/jk64/jk64-plugin-simplemap'
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
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(65999677618912872)
,p_plugin_id=>wwv_flow_api.id(65986014849483781)
,p_name=>'mapclick'
,p_display_name=>'mapClick'
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
