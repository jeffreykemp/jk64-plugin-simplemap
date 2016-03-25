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
,p_default_application_id=>76577
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
 p_id=>wwv_flow_api.id(367692204487310457)
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
'    l_result    apex_plugin.t_region_render_result;',
'    l_script    varchar2(32767);',
'    l_region    varchar2(100);',
'    l_js_params varchar2(1000);',
'    l_lat       number;',
'    l_lng       number;',
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
'    l_mapstyle      plugin_attr := p_region.attribute_10;',
'    l_address_item  plugin_attr := p_region.attribute_11;',
'    l_geolocate     plugin_attr := p_region.attribute_12;',
'    l_geoloc_zoom   plugin_attr := p_region.attribute_13;',
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
'            l_js_params := l_js_params||''&''||''signed_in=true'';',
'        END IF;',
'    ELSE',
'        -- these features require a Google API Key',
'        l_sign_in      := ''N'';',
'        l_geocode_item := NULL;',
'        l_country      := NULL;',
'        l_address_item := NULL;',
'    END IF;',
'',
'    APEX_JAVASCRIPT.add_library',
'      (p_name           => ''js'' || l_js_params',
'      ,p_directory      => ''https://maps.googleapis.com/maps/api/''',
'      ,p_skip_extension => true);',
'',
'    APEX_JAVASCRIPT.add_library',
'      (p_name           => ''jk64plugin.min''',
'      ,p_directory      => p_plugin.file_prefix);',
'    ',
'    l_lat := TO_NUMBER(SUBSTR(l_latlong,1,INSTR(l_latlong,'','')-1));',
'    l_lng := TO_NUMBER(SUBSTR(l_latlong,INSTR(l_latlong,'','')+1));',
'    ',
'    l_region := CASE',
'                WHEN p_region.static_id IS NOT NULL',
'                THEN p_region.static_id',
'                ELSE ''R''||p_region.id',
'                END;',
'    ',
'    l_script := REPLACE(''',
'var opt_#REGION# = {',
'   container: "map_#REGION#_container"',
'  ,regionId: "#REGION#"',
'  ,initZoom: ''||l_zoom||''',
'  ,initLat: ''||TO_CHAR(l_lat,''fm999.9999999999999999'')||''',
'  ,initLng: ''||TO_CHAR(l_lng,''fm999.9999999999999999'')||''',
'  ,markerZoom: ''||l_marker_zoom||''',
'  ,icon: "''||l_icon||''"',
'  ,syncItem: "''||l_item_name||''"',
'  ,geocodeItem: "''||l_geocode_item||''"',
'  ,country: "''||l_country||''"''||',
'  CASE WHEN l_mapstyle IS NOT NULL THEN ''',
'  ,mapstyle: ''||l_mapstyle',
'  END || ''',
'  ,addressItem: "''||l_address_item||''"''||',
'  CASE WHEN l_geolocate = ''Y'' THEN ''',
'  ,geolocate: true'' ||',
'    CASE WHEN l_geoloc_zoom IS NOT NULL THEN ''',
'  ,geolocateZoom: ''||l_geoloc_zoom',
'    END',
'  END || ''',
'};',
'function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}',
'r_#REGION#(function(){',
'  jk64plugin_initMap(opt_#REGION#);',
'});',
'function click_#REGION#(lat,lng) {',
'  jk64plugin_setMarker(opt_#REGION#,lat,lng);',
'}',
''',''#REGION#'',l_region);',
'',
'  sys.htp.p(''<script>''||l_script||''</script>'');',
'  sys.htp.p(''<div id="map_''||l_region||''_container" style="min-height:''||l_region_height||''px"></div>'');',
'',
'  return l_result;',
'end render_map;'))
,p_render_function=>'render_map'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Add a region of this type to your page and you have a map which the user can click to set a single Marker. If you set Synchronize with Item it will copy the lat,lng that the user clicks into that item; also, if the item is changed the map will move t'
||'he marker to the new location. If you set an Address item and your Google API Key, it will do a reverse geocode and put the first address result into it.'
,p_version_identifier=>'0.4'
,p_about_url=>'https://github.com/jeffreykemp/jk64-plugin-simplemap'
,p_files_version=>12
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(376856865096013194)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(367722647878072675)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(367702065986577942)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(367702713687603502)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(369361023320948612)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(369365038098121790)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(371630967454206928)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(376857940474019441)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(376860336674106770)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
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
 p_id=>wwv_flow_api.id(376861092964110151)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Restrict to Country code'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_max_length=>2
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(376860336674106770)
,p_depending_on_condition_type=>'NOT_NULL'
,p_text_case=>'UPPER'
,p_examples=>'AU'
,p_help_text=>'Leave blank to allow geocoding to find any place on earth. Set to country code (see https://developers.google.com/public-data/docs/canonical/countries_csv for valid values) to restrict geocoder to that country.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(302022735075534395)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_prompt=>'Map Style'
,p_attribute_type=>'TEXTAREA'
,p_is_required=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Here is an example, a light greyscale style map:',
'<pre>',
'[{"featureType":"water","elementType":"geometry","stylers":[{"color":"#e9e9e9"},{"lightness":17}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#f5f5f5"},{"lightness":20}]},{"featureType":"road.highway","elementType":"geom'
||'etry.fill","stylers":[{"color":"#ffffff"},{"lightness":17}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#ffffff"},{"lightness":29},{"weight":0.2}]},{"featureType":"road.arterial","elementType":"geometry","style'
||'rs":[{"color":"#ffffff"},{"lightness":18}]},{"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#ffffff"},{"lightness":16}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#f5f5f5"},{"lightness":21}]},{"featu'
||'reType":"poi.park","elementType":"geometry","stylers":[{"color":"#dedede"},{"lightness":21}]},{"elementType":"labels.text.stroke","stylers":[{"visibility":"on"},{"color":"#ffffff"},{"lightness":16}]},{"elementType":"labels.text.fill","stylers":[{"sat'
||'uration":36},{"color":"#333333"},{"lightness":40}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#f2f2f2"},{"lightness":19}]},{"featureType":"administrative","el'
||'ementType":"geometry.fill","stylers":[{"color":"#fefefe"},{"lightness":20}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#fefefe"},{"lightness":17},{"weight":1.2}]}]',
'</pre>'))
,p_help_text=>'Easiest way is to copy one from a site like https://snazzymaps.com/'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(151018968365587177)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Address Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Google API Key required. When the user clicks a point on the map, a Google Maps reverse geocode will be executed and the first result (usually the address) will be copied to the item you specify here.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(82030436997318239)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Geolocate'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'If Yes, on load the map will attempt to locate the user''s position and pan&zoom to that location (it might prompt the user for permission first).'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(82032038134389504)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Zoom on Geolocate'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'13'
,p_display_length=>2
,p_max_length=>2
,p_unit=>'(0-23)'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(82030436997318239)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'If geolocation is successful, pan map and zoom to this level.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(82033606956406541)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_name=>'geolocate'
,p_display_name=>'geolocate'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(367705867256739548)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_name=>'mapclick'
,p_display_name=>'mapClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(376858877023022311)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_name=>'maploaded'
,p_display_name=>'mapLoaded'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E206A6B3634706C7567696E5F67656F636F646528652C6F297B6F2E67656F636F6465287B616464726573733A247628652E67656F636F64654974656D292C636F6D706F6E656E745265737472696374696F6E733A2222213D3D652E63';
wwv_flow_api.g_varchar2_table(2) := '6F756E7472793F7B636F756E7472793A652E636F756E7472797D3A7B7D7D2C66756E6374696F6E286F2C61297B696628613D3D676F6F676C652E6D6170732E47656F636F6465725374617475732E4F4B297B617065782E646562756728652E726567696F';
wwv_flow_api.g_varchar2_table(3) := '6E49642B222067656F636F6465206F6B22293B766172206E3D6F5B305D2E67656F6D657472792E6C6F636174696F6E3B6A6B3634706C7567696E5F7365744D61726B657228652C6E2E6C617428292C6E2E6C6E672829292C2222213D3D652E73796E6349';
wwv_flow_api.g_varchar2_table(4) := '74656D2626247328652E73796E634974656D2C6E2E6C617428292B222C222B6E2E6C6E672829297D656C736520617065782E646562756728652E726567696F6E49642B222067656F636F64652077617320756E7375636365737366756C20666F72207468';
wwv_flow_api.g_varchar2_table(5) := '6520666F6C6C6F77696E6720726561736F6E3A20222B61297D297D66756E6374696F6E206A6B3634706C7567696E5F7365744D61726B657228652C6F2C61297B6966286E756C6C213D3D6F26266E756C6C213D3D61297B766172206E3D652E6D61726B65';
wwv_flow_api.g_varchar2_table(6) := '723F652E6D61726B65722E676574506F736974696F6E28293A6E657720676F6F676C652E6D6170732E4C61744C6E6728302C30293B6966286F3D3D6E2E6C617428292626613D3D6E2E6C6E67282929617065782E646562756728652E726567696F6E4964';
wwv_flow_api.g_varchar2_table(7) := '2B22206D61726B6572206E6F74206368616E67656422293B656C73657B617065782E646562756728652E726567696F6E49642B22206D6F7665206D61726B657222293B76617220743D6E657720676F6F676C652E6D6170732E4C61744C6E67286F2C6129';
wwv_flow_api.g_varchar2_table(8) := '3B652E6D61702E70616E546F2874292C652E6D61726B65725A6F6F6D2626652E6D61702E7365745A6F6F6D28652E6D61726B65725A6F6F6D292C652E6D61726B65723F28652E6D61726B65722E7365744D617028652E6D6170292C652E6D61726B65722E';
wwv_flow_api.g_varchar2_table(9) := '736574506F736974696F6E287429293A652E6D61726B65723D6E657720676F6F676C652E6D6170732E4D61726B6572287B6D61703A652E6D61702C706F736974696F6E3A742C69636F6E3A652E69636F6E7D297D7D656C736520652E6D61726B65722626';
wwv_flow_api.g_varchar2_table(10) := '28617065782E646562756728652E726567696F6E49642B222072656D6F7665206D61726B657222292C652E6D61726B65722E7365744D6170286E756C6C29297D66756E6374696F6E206A6B3634706C7567696E5F6765744164647265737328652C6F2C61';
wwv_flow_api.g_varchar2_table(11) := '297B766172206E3D7B6C61743A6F2C6C6E673A617D3B652E67656F636F6465722E67656F636F6465287B6C6F636174696F6E3A6E7D2C66756E6374696F6E286F2C61297B696628613D3D3D676F6F676C652E6D6170732E47656F636F6465725374617475';
wwv_flow_api.g_varchar2_table(12) := '732E4F4B297B666F7228693D303B693C6F2E6C656E6774683B692B2B29617065782E646562756728652E726567696F6E49642B2220726573756C745B222B692B225D3D222B6F5B695D2E666F726D61747465645F616464726573732B222028222B6F5B69';
wwv_flow_api.g_varchar2_table(13) := '5D2E74797065732E6A6F696E28292B222922293B6F5B315D3F247328652E616464726573734974656D2C6F5B305D2E666F726D61747465645F61646472657373293A77696E646F772E616C6572742822496E73756666696369656E7420726573756C7473';
wwv_flow_api.g_varchar2_table(14) := '20666F756E6422297D656C736520613D3D3D676F6F676C652E6D6170732E47656F636F6465725374617475732E5A45524F5F524553554C54533F77696E646F772E616C65727428224E6F20726573756C747320666F756E6422293A77696E646F772E616C';
wwv_flow_api.g_varchar2_table(15) := '657274282247656F636F646572206661696C65642064756520746F3A20222B61297D297D66756E6374696F6E206A6B3634706C7567696E5F696E69744D61702865297B766172206F3D7B7A6F6F6D3A652E696E69745A6F6F6D2C63656E7465723A6E6577';
wwv_flow_api.g_varchar2_table(16) := '20676F6F676C652E6D6170732E4C61744C6E6728652E696E69744C61742C652E696E69744C6E67292C6D61705479706549643A676F6F676C652E6D6170732E4D61705479706549642E524F41444D41507D3B696628652E6D61703D6E657720676F6F676C';
wwv_flow_api.g_varchar2_table(17) := '652E6D6170732E4D617028646F63756D656E742E676574456C656D656E744279496428652E636F6E7461696E6572292C6F292C652E6D61707374796C652626652E6D61702E7365744F7074696F6E73287B7374796C65733A652E6D61707374796C657D29';
wwv_flow_api.g_varchar2_table(18) := '2C2222213D3D652E73796E634974656D297B76617220613D247628652E73796E634974656D293B6966286E756C6C213D3D612626612E696E6465784F6628222C22293E2D31297B766172206E3D612E73706C697428222C22293B6A6B3634706C7567696E';
wwv_flow_api.g_varchar2_table(19) := '5F7365744D61726B657228652C6E5B305D2C6E5B315D297D24282223222B652E73796E634974656D292E6368616E67652866756E6374696F6E28297B766172206F3D746869732E76616C75653B6966286E756C6C213D3D6F2626766F69642030213D3D6F';
wwv_flow_api.g_varchar2_table(20) := '26266F2E696E6465784F6628222C22293E2D31297B76617220613D6F2E73706C697428222C22293B6A6B3634706C7567696E5F7365744D61726B657228652C615B305D2C615B315D297D7D297D6966282222213D3D652E616464726573734974656D2626';
wwv_flow_api.g_varchar2_table(21) := '28652E67656F636F6465723D6E657720676F6F676C652E6D6170732E47656F636F646572292C676F6F676C652E6D6170732E6576656E742E6164644C697374656E657228652E6D61702C22636C69636B222C66756E6374696F6E286F297B76617220613D';
wwv_flow_api.g_varchar2_table(22) := '6F2E6C61744C6E672E6C617428292C6E3D6F2E6C61744C6E672E6C6E6728293B6A6B3634706C7567696E5F7365744D61726B657228652C612C6E292C2222213D3D652E73796E634974656D2626247328652E73796E634974656D2C612B222C222B6E292C';
wwv_flow_api.g_varchar2_table(23) := '2222213D3D652E616464726573734974656D26266A6B3634706C7567696E5F6765744164647265737328652C612C6E292C617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767657228226D6170636C69636B222C7B6D6170';
wwv_flow_api.g_varchar2_table(24) := '3A652E6D61702C6C61743A612C6C6E673A6E7D297D292C2222213D652E67656F636F64654974656D297B76617220743D6E657720676F6F676C652E6D6170732E47656F636F6465723B24282223222B652E67656F636F64654974656D292E6368616E6765';
wwv_flow_api.g_varchar2_table(25) := '2866756E6374696F6E28297B6A6B3634706C7567696E5F67656F636F646528652C74297D297D652E67656F6C6F636174652626286E6176696761746F722E67656F6C6F636174696F6E3F28617065782E646562756728652E726567696F6E49642B222067';
wwv_flow_api.g_varchar2_table(26) := '656F6C6F6361746522292C6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E286F297B76617220613D7B6C61743A6F2E636F6F7264732E6C617469747564652C6C6E673A6F2E63';
wwv_flow_api.g_varchar2_table(27) := '6F6F7264732E6C6F6E6769747564657D3B652E6D61702E70616E546F2861292C652E67656F6C6F636174655A6F6F6D2626652E6D61702E7365745A6F6F6D28652E67656F6C6F636174655A6F6F6D292C617065782E6A5175657279282223222B652E7265';
wwv_flow_api.g_varchar2_table(28) := '67696F6E4964292E74726967676572282267656F6C6F63617465222C7B6D61703A652E6D61702C6C61743A612E6C61742C6C6E673A612E6C6E677D297D29293A617065782E646562756728652E726567696F6E49642B222062726F7773657220646F6573';
wwv_flow_api.g_varchar2_table(29) := '206E6F7420737570706F72742067656F6C6F636174696F6E2229292C617065782E6A5175657279282223222B652E726567696F6E4964292E7472696767657228226D61706C6F61646564222C7B6D61703A652E6D61707D297D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(151022449902693758)
,p_plugin_id=>wwv_flow_api.id(367692204487310457)
,p_file_name=>'jk64plugin.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
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
