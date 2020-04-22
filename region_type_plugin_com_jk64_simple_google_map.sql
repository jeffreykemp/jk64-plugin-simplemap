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
,p_release=>'5.0.3.00.03'
,p_default_workspace_id=>2216419243751626
,p_default_application_id=>101
,p_default_owner=>'XXSPS'
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
 p_id=>wwv_flow_api.id(501163678790508848)
,p_plugin_type=>'REGION TYPE'
,p_name=>'COM.JK64.SIMPLE_GOOGLE_MAP'
,p_display_name=>'JK64 Simple Google Map'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'/**********************************************************',
'create or replace package jk64simplemap_pkg as',
'-- jk64 JK64 Simple Google Map v0.8 Apr 2020',
'',
'function render (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'return apex_plugin.t_region_render_result;',
'',
'end jk64simplemap_pkg;',
'/',
'',
'create or replace package body jk64simplemap_pkg as',
'**********************************************************/',
'-- jk64 JK64 Simple Google Map v0.8 Apr 2020',
'',
'-- format to use to convert a lat/lng number to string for passing via javascript',
'-- 0.0000001 is enough precision for the practical limit of commercial surveying, error up to +/- 11.132 mm at the equator',
'g_tochar_format constant varchar2(100) := ''fm990.0999999'';',
'',
'subtype plugin_attr is varchar2(32767);',
'',
'procedure parse_latlng (p_val in varchar2, p_label in varchar2, p_lat out number, p_lng out number) is',
'    delim_pos number;',
'begin',
'    -- allow space as the delimiter; this should be used in locales which use comma (,) as decimal separator',
'    if instr(trim(p_val),'' '') > 0 then',
'        delim_pos := instr(p_val,'' '');',
'    else',
'        delim_pos := instr(p_val,'','');',
'    end if;',
'    p_lat := apex_plugin_util.get_attribute_as_number(substr(p_val,1,delim_pos-1), p_label || '' latitude'');',
'    p_lng := apex_plugin_util.get_attribute_as_number(substr(p_val,delim_pos+1), p_label || '' longitude'');',
'end parse_latlng;',
'',
'function render (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'return apex_plugin.t_region_render_result',
'as',
'',
'    -- Variables',
'    l_result       apex_plugin.t_region_render_result;',
'    l_script       varchar2(32767);',
'    l_region       varchar2(100);',
'    l_lat          number;',
'    l_lng          number;',
'    l_readonly     varchar2(1000) := ''false'';',
'    l_zoom_enabled varchar2(1000) := ''true'';',
'    l_pan_enabled  varchar2(1000) := ''true'';',
'',
'    -- Plugin attributes (application level)',
'    l_api_key          plugin_attr := p_plugin.attribute_01;',
'',
'    -- Component attributes',
'    l_latlong          plugin_attr := p_region.attribute_01;',
'    l_zoom             plugin_attr := p_region.attribute_02;',
'    l_region_height    plugin_attr := p_region.attribute_03;',
'    l_item_name        plugin_attr := p_region.attribute_04;',
'    l_marker_zoom      plugin_attr := p_region.attribute_05;',
'    l_icon             plugin_attr := p_region.attribute_06;',
'    --[unused]         plugin_attr := p_region.attribute_07;',
'    l_geocode_item     plugin_attr := p_region.attribute_08;',
'    l_country          plugin_attr := p_region.attribute_09;',
'    l_mapstyle         plugin_attr := p_region.attribute_10;',
'    l_address_item     plugin_attr := p_region.attribute_11;',
'    l_geolocate        plugin_attr := p_region.attribute_12;',
'    l_geoloc_zoom      plugin_attr := p_region.attribute_13;',
'    l_readonly_expr    plugin_attr := p_region.attribute_14;',
'    l_zoom_expr        plugin_attr := p_region.attribute_15;',
'    l_pan_expr         plugin_attr := p_region.attribute_16;',
'    l_gesture_handling plugin_attr := p_region.attribute_17;',
'    ',
'begin',
'    apex_plugin_util.debug_region (',
'        p_plugin => p_plugin,',
'        p_region => p_region,',
'        p_is_printer_friendly => p_is_printer_friendly);',
'',
'    if l_readonly_expr is not null then',
'        l_readonly := apex_plugin_util.get_plsql_expression_result (',
'            ''case when ('' || l_readonly_expr',
'            || '') then ''''true'''' else ''''false'''' end'');',
'        if l_readonly not in (''true'',''false'') then',
'            raise_application_error(-20000, ''Read-only attribute must evaluate to true or false.'');',
'        end if;',
'    end if;',
'',
'    if l_zoom_expr is not null then',
'        l_zoom_enabled := apex_plugin_util.get_plsql_expression_result (',
'            ''case when ('' || l_zoom_expr',
'            || '') then ''''true'''' else ''''false'''' end'');',
'        if l_zoom_enabled not in (''true'',''false'') then',
'            raise_application_error(-20000, ''Zoom attribute must evaluate to true or false.'');',
'        end if;',
'    end if;',
'',
'    if l_pan_expr is not null then',
'        l_pan_enabled := apex_plugin_util.get_plsql_expression_result (',
'            ''case when ('' || l_pan_expr',
'            || '') then ''''true'''' else ''''false'''' end'');',
'        if l_pan_enabled not in (''true'',''false'') then',
'            raise_application_error(-20000, ''Pan attribute must evaluate to true or false.'');',
'        end if;',
'    end if;',
'    ',
'    apex_javascript.add_library',
'        (p_name           => ''js?key='' || l_api_key',
'        ,p_directory      => ''https://maps.googleapis.com/maps/api/''',
'        ,p_skip_extension => true);',
'',
'    apex_javascript.add_library',
'        (p_name                  => ''simplemap''',
'        ,p_directory             => p_plugin.file_prefix',
'        ,p_check_to_add_minified => true);',
'    ',
'    if l_latlong is not null then',
'        parse_latlng(l_latlong, p_label=>''Initial Map Position'', p_lat=>l_lat, p_lng=>l_lng);',
'    end if;',
'    ',
'    l_region := case',
'                when p_region.static_id is not null',
'                then p_region.static_id',
'                else ''R''||p_region.id',
'                end;',
'    ',
'    l_script := ''<script>',
'var opt_#REGION# = {',
'container:"map_#REGION#_container"',
',regionId:"#REGION#"',
',initZoom:'' || l_zoom || ''',
',initLat:'' || to_char(l_lat,g_tochar_format) || ''',
',initLng:'' || to_char(l_lng,g_tochar_format) || ''',
',markerZoom:'' || l_marker_zoom || ''',
',icon:"'' || l_icon || ''"',
',syncItem:"'' || l_item_name || ''"',
',geocodeItem:"'' || l_geocode_item || ''"',
',country:"'' || l_country || ''"''',
'||   case when l_mapstyle is not null then ''',
',mapstyle:'' || l_mapstyle',
'     end || ''',
',addressItem:"'' || l_address_item || ''"''',
'||   case when l_geolocate = ''Y'' then ''',
',geolocate:true''',
'     ||   case when l_geoloc_zoom is not null then ''',
',geolocateZoom:'' || l_geoloc_zoom',
'          end',
'     end || ''',
',readonly:'' || l_readonly || ''',
',zoom:'' || l_zoom_enabled || ''',
',pan:'' || l_pan_enabled || ''',
',gestureHandling:"'' || nvl(l_gesture_handling,''auto'') || ''"',
'};',
'function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}',
'r_#REGION#(function(){simplemap.init(opt_#REGION#);});',
'function click_#REGION#(lat,lng) {simplemap.setMarker(opt_#REGION#,lat,lng);}',
'</script>',
'<div id="map_#REGION#_container" style="min-height:'' || l_region_height || ''px"></div>'';',
'',
'  sys.htp.p(replace(l_script,''#REGION#'',l_region));',
'',
'  return l_result;',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.message(dbms_utility.format_error_stack);',
'        apex_debug.message(dbms_utility.format_call_stack);',
'        raise;',
'end render;',
'',
'/**********************************************************',
'end jk64simplemap_pkg;',
'/',
'**********************************************************/'))
,p_render_function=>'render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Add a region of this type to your page and you have a map which the user can click to set a single Marker. If you set Synchronize with Item it will copy the lat,lng that the user clicks into that item; also, if the item is changed the map will move t'
||'he marker to the new location. If you set an Address item, it will do a reverse geocode and put the first address result into it. You can also get the address clicked on via the "address" event whereby you can get each component of an address (e.g. s'
||'treet number, road, locality, etc.) as separate strings.'
,p_version_identifier=>'0.8'
,p_about_url=>'https://github.com/jeffreykemp/jk64-plugin-simplemap'
,p_files_version=>34
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(510328339399211585)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Google API Key'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'Google Maps API key is required. Refer: https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(501194122181271066)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Initial Map Position'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'0,0'
,p_max_length=>100
,p_unit=>'lat,long'
,p_is_translatable=>false
,p_help_text=>'Set the latitude and longitude as a pair of numbers to be used to position the map on page load, if no pin coordinates have been provided by the page item.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(501173540289776333)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Initial Zoom Level'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'1'
,p_max_length=>2
,p_unit=>'(0-23)'
,p_is_translatable=>false
,p_help_text=>'Set the initial map zoom level on page load, to be used if the page item has no coordinates to show.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(501174187990801893)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Min. Map Height'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'400'
,p_max_length=>5
,p_unit=>'pixels'
,p_is_translatable=>false
,p_help_text=>'Set the desired height for the map region. Note: the map width will adjust to the maximum available space.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(502832497624147003)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Synchronize with Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Position of the marker will be retrieved from and stored in this item as a Lat,Long value.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(502836512401320181)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Marker Zoom Level'
,p_attribute_type=>'INTEGER'
,p_is_required=>true
,p_default_value=>'16'
,p_unit=>'(0-23)'
,p_is_translatable=>false
,p_help_text=>'If a marker is set or moved, zoom the map to this level. Leave blank to make the map not zoom when the marker is moved.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(505102441757405319)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Marker Icon'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>4000
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
 p_id=>wwv_flow_api.id(510331810977305161)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
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
 p_id=>wwv_flow_api.id(510332567267308542)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Restrict to Country code'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>10
,p_max_length=>2
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(510331810977305161)
,p_depending_on_condition_type=>'NOT_NULL'
,p_text_case=>'UPPER'
,p_examples=>'AU'
,p_help_text=>'Leave blank to allow geocoding to find any place on earth. Set to country code (see https://developers.google.com/public-data/docs/canonical/countries_csv for valid values) to restrict geocoder to that country.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(435494209378732786)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
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
'</pre>',
'<p>',
'To hide the (clickable) POIs from the map, use this:',
'<code>[{featureType:"poi",elementType:"labels",stylers:[{visibility:"off"}]}]</code>'))
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'You can generate map styles using this tool: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html',
'<p>',
'Another way is to copy one from a site like https://snazzymaps.com/'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(284490442668785568)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
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
 p_id=>wwv_flow_api.id(215501911300516630)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
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
 p_id=>wwv_flow_api.id(215503512437587895)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
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
,p_depending_on_attribute_id=>wwv_flow_api.id(215501911300516630)
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'If geolocation is successful, pan map and zoom to this level.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(133472494655204517)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_prompt=>'Read-only'
,p_attribute_type=>'PLSQL EXPRESSION BOOLEAN'
,p_is_required=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<code>true</code>',
'<p>',
'<code>:P1_ITEM IS NOT NULL</code>'))
,p_help_text=>'By default, this plugin allows the user to click the map to move the marker. To make the map "readonly" (i.e. disallow the user from moving the marker), set this to a PL/SQL expression that evaluates to TRUE.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(185859985432288029)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Zoom enabled'
,p_attribute_type=>'PLSQL EXPRESSION BOOLEAN'
,p_is_required=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<code>true</code>',
'<p>',
'<code>:P1_ITEM IS NOT NULL</code>'))
,p_help_text=>'If this evaluates to true, the Zoom controls will be enabled. If no expression is supplied, the default is true (enabled).'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(185861125122291051)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_prompt=>'Pan enabled'
,p_attribute_type=>'PLSQL EXPRESSION BOOLEAN'
,p_is_required=>false
,p_show_in_wizard=>false
,p_is_translatable=>false
,p_examples=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'<code>true</code>',
'<p>',
'<code>:P1_ITEM IS NOT NULL</code>'))
,p_help_text=>'If this evaluates to true, the Pan controls will be enabled. If no expression is supplied, the default is true (enabled).'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(185866950785400418)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_prompt=>'Gesture Handling'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_show_in_wizard=>false
,p_default_value=>'auto'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'This attribute allows you to select how the map responds to touch gestures on a mobile device. Mobile web users often get frustrated when trying to scroll the page, but an embedded map captures their swipe and pans the map instead. This can even lead'
||' to users getting stuck on the map and having to reload the page in order to get back to the rest of the page. This option allows you to make scrolling more intuitive and less frustrating map interaction experience on mobile browsers.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(185868024927403402)
,p_plugin_attribute_id=>wwv_flow_api.id(185866950785400418)
,p_display_sequence=>10
,p_display_value=>'cooperative'
,p_return_value=>'cooperative'
,p_help_text=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'Scroll events and one-finger touch gestures scroll the page, and do not zoom or pan the map. Two-finger touch gestures pan and zoom the map. Scroll events with a ctrl key or ? key pressed zoom the map.',
'In this mode the map cooperates with the page.'))
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(185868386922405143)
,p_plugin_attribute_id=>wwv_flow_api.id(185866950785400418)
,p_display_sequence=>20
,p_display_value=>'greedy'
,p_return_value=>'greedy'
,p_help_text=>'All touch gestures and scroll events pan or zoom the map.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(185868827129406433)
,p_plugin_attribute_id=>wwv_flow_api.id(185866950785400418)
,p_display_sequence=>30
,p_display_value=>'none'
,p_return_value=>'none'
,p_help_text=>'The map cannot be panned or zoomed by user gestures.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(185869208154407973)
,p_plugin_attribute_id=>wwv_flow_api.id(185866950785400418)
,p_display_sequence=>40
,p_display_value=>'auto'
,p_return_value=>'auto'
,p_help_text=>'(default) Gesture handling is either cooperative or greedy, depending on whether the page is scrollable.'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(185872559130602183)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_name=>'address'
,p_display_name=>'address'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(215505081259604932)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_name=>'geolocate'
,p_display_name=>'geolocate'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(501177341559937939)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_name=>'mapclick'
,p_display_name=>'mapClick'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(510330351326220702)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_name=>'maploaded'
,p_display_name=>'mapLoaded'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7661722073696D706C656D6170203D207B0A2F2F204A4B36342053696D706C6520476F6F676C65204D61702076302E360A0A67656F636F6465203A2066756E6374696F6E20286F70742C67656F636F64657229207B0A2020617065782E64656275672822';
wwv_flow_api.g_varchar2_table(2) := '73696D706C656D61702E67656F636F646522293B0A202067656F636F6465722E67656F636F6465280A202020207B616464726573733A202476286F70742E67656F636F64654974656D290A202020202C636F6D706F6E656E745265737472696374696F6E';
wwv_flow_api.g_varchar2_table(3) := '733A206F70742E636F756E747279213D3D22223F7B636F756E7472793A6F70742E636F756E7472797D3A7B7D0A20207D2C2066756E6374696F6E28726573756C74732C2073746174757329207B0A2020202069662028737461747573203D3D20676F6F67';
wwv_flow_api.g_varchar2_table(4) := '6C652E6D6170732E47656F636F6465725374617475732E4F4B29207B0A202020202020617065782E6465627567286F70742E726567696F6E49642B222067656F636F6465206F6B22293B0A20202020202076617220706F73203D20726573756C74735B30';
wwv_flow_api.g_varchar2_table(5) := '5D2E67656F6D657472792E6C6F636174696F6E3B0A20202020202073696D706C656D61702E7365744D61726B6572286F70742C706F732E6C617428292C706F732E6C6E672829290A202020202020696620286F70742E73796E634974656D213D3D222229';
wwv_flow_api.g_varchar2_table(6) := '207B0A20202020202020202473286F70742E73796E634974656D2C706F732E6C617428292B222C222B706F732E6C6E672829293B0A2020202020207D0A202020207D20656C7365207B0A202020202020617065782E6465627567286F70742E726567696F';
wwv_flow_api.g_varchar2_table(7) := '6E49642B222067656F636F64652077617320756E7375636365737366756C20666F722074686520666F6C6C6F77696E6720726561736F6E3A20222B737461747573293B0A202020207D0A20207D293B0A7D2C0A0A7365744D61726B6572203A2066756E63';
wwv_flow_api.g_varchar2_table(8) := '74696F6E20286F70742C6C61742C6C6E6729207B0A2020617065782E6465627567282273696D706C656D61702E7365744D61726B657222293B0A2020696620286C6174213D3D6E756C6C202626206C6E67213D3D6E756C6C29207B0A2020202076617220';
wwv_flow_api.g_varchar2_table(9) := '6F6C64706F73203D206F70742E6D61726B65723F6F70742E6D61726B65722E676574506F736974696F6E28293A6E657720676F6F676C652E6D6170732E4C61744C6E6728302C30293B0A20202020696620286C61743D3D6F6C64706F732E6C6174282920';
wwv_flow_api.g_varchar2_table(10) := '2626206C6E673D3D6F6C64706F732E6C6E67282929207B0A202020202020617065782E6465627567286F70742E726567696F6E49642B22206D61726B6572206E6F74206368616E67656422293B0A202020207D20656C7365207B0A202020202020617065';
wwv_flow_api.g_varchar2_table(11) := '782E6465627567286F70742E726567696F6E49642B22206D6F7665206D61726B657222293B0A20202020202076617220706F73203D206E657720676F6F676C652E6D6170732E4C61744C6E67286C61742C6C6E67293B0A2020202020206F70742E6D6170';
wwv_flow_api.g_varchar2_table(12) := '2E70616E546F28706F73293B0A202020202020696620286F70742E6D61726B65725A6F6F6D29207B0A20202020202020206F70742E6D61702E7365745A6F6F6D286F70742E6D61726B65725A6F6F6D293B0A2020202020207D0A20202020202069662028';
wwv_flow_api.g_varchar2_table(13) := '6F70742E6D61726B657229207B0A20202020202020206F70742E6D61726B65722E7365744D6170286F70742E6D6170293B0A20202020202020206F70742E6D61726B65722E736574506F736974696F6E28706F73293B0A2020202020207D20656C736520';
wwv_flow_api.g_varchar2_table(14) := '7B0A20202020202020206F70742E6D61726B6572203D206E657720676F6F676C652E6D6170732E4D61726B6572287B6D61703A206F70742E6D61702C20706F736974696F6E3A20706F732C2069636F6E3A206F70742E69636F6E7D293B0A202020202020';
wwv_flow_api.g_varchar2_table(15) := '7D0A202020207D0A20207D20656C736520696620286F70742E6D61726B657229207B0A20202020617065782E6465627567286F70742E726567696F6E49642B222072656D6F7665206D61726B657222293B0A202020206F70742E6D61726B65722E736574';
wwv_flow_api.g_varchar2_table(16) := '4D6170286E756C6C293B0A20207D0A7D2C0A0A67657441646472657373203A2066756E6374696F6E20286F70742C6C61742C6C6E6729207B0A2020617065782E6465627567282273696D706C656D61702E6765744164647265737322293B0A0976617220';
wwv_flow_api.g_varchar2_table(17) := '6C61746C6E67203D207B6C61743A206C61742C206C6E673A206C6E677D3B0A096F70742E67656F636F6465722E67656F636F6465287B276C6F636174696F6E273A206C61746C6E677D2C2066756E6374696F6E28726573756C74732C2073746174757329';
wwv_flow_api.g_varchar2_table(18) := '207B0A090969662028737461747573203D3D3D20676F6F676C652E6D6170732E47656F636F6465725374617475732E4F4B29207B0A090909666F722028693D303B20693C726573756C74732E6C656E6774683B20692B2B29207B0A09090909617065782E';
wwv_flow_api.g_varchar2_table(19) := '6465627567286F70742E726567696F6E49642B2220726573756C745B222B692B225D3D222B726573756C74735B695D2E666F726D61747465645F616464726573732B222028222B726573756C74735B695D2E74797065732E6A6F696E28292B222922293B';
wwv_flow_api.g_varchar2_table(20) := '0A0909097D0A09090969662028726573756C74735B305D29207B0A090909092473286F70742E616464726573734974656D2C726573756C74735B305D2E666F726D61747465645F61646472657373293B0A202020202020202076617220636F6D706F6E65';
wwv_flow_api.g_varchar2_table(21) := '6E7473203D20726573756C74735B305D2E616464726573735F636F6D706F6E656E74733B0A2020202020202020666F722028693D303B20693C636F6D706F6E656E74732E6C656E6774683B20692B2B29207B0A20202020202020202020617065782E6465';
wwv_flow_api.g_varchar2_table(22) := '627567286F70742E726567696F6E49642B2220726573756C745B305D20222B636F6D706F6E656E74735B695D2E74797065732B223D222B636F6D706F6E656E74735B695D2E73686F72745F6E616D652B222028222B636F6D706F6E656E74735B695D2E6C';
wwv_flow_api.g_varchar2_table(23) := '6F6E675F6E616D652B222922293B0A20202020202020207D0A2020202020202020617065782E6A5175657279282223222B6F70742E726567696F6E4964292E74726967676572282261646472657373222C207B6D61703A6F70742E6D61702C2072657375';
wwv_flow_api.g_varchar2_table(24) := '6C743A726573756C74735B305D7D293B0A0909097D20656C7365207B0A0909090977696E646F772E616C6572742827496E73756666696369656E7420726573756C747320666F756E6427293B0A0909097D0A09097D20656C736520696620287374617475';
wwv_flow_api.g_varchar2_table(25) := '73203D3D3D20676F6F676C652E6D6170732E47656F636F6465725374617475732E5A45524F5F524553554C545329207B0A09090977696E646F772E616C65727428224E6F20726573756C747320666F756E6422293B0A09097D20656C7365207B0A090909';
wwv_flow_api.g_varchar2_table(26) := '77696E646F772E616C657274282747656F636F646572206661696C65642064756520746F3A2027202B20737461747573293B0A09097D0A097D293B0A7D2C0A0A696E6974203A2066756E6374696F6E20286F707429207B0A2020617065782E6465627567';
wwv_flow_api.g_varchar2_table(27) := '282273696D706C656D61702E696E697422293B0A09766172206D794F7074696F6E73203D207B0A09097A6F6F6D3A206F70742E696E69745A6F6F6D2C0A090963656E7465723A206E657720676F6F676C652E6D6170732E4C61744C6E67286F70742E696E';
wwv_flow_api.g_varchar2_table(28) := '69744C61742C6F70742E696E69744C6E67292C0A09096D61705479706549643A20676F6F676C652E6D6170732E4D61705479706549642E524F41444D41500A097D3B0A096F70742E6D6170203D206E657720676F6F676C652E6D6170732E4D617028646F';
wwv_flow_api.g_varchar2_table(29) := '63756D656E742E676574456C656D656E7442794964286F70742E636F6E7461696E6572292C6D794F7074696F6E73293B0A09696620286F70742E6D61707374796C6529207B0A09096F70742E6D61702E7365744F7074696F6E73287B7374796C65733A20';
wwv_flow_api.g_varchar2_table(30) := '6F70742E6D61707374796C657D293B0A097D0A2020696620286F70742E726561646F6E6C7929207B0A202020202F2F64697361626C65207A6F6F6D2F70616E20696620726561646F6E6C790A202020206F70742E6D61702E7365744F7074696F6E73287B';
wwv_flow_api.g_varchar2_table(31) := '0A2020202020202064697361626C6544656661756C7455493A20747275650A2020202020202C647261676761626C653A206F70742E70616E0A2020202020202C7A6F6F6D436F6E74726F6C3A206F70742E7A6F6F6D0A2020202020202C7363726F6C6C77';
wwv_flow_api.g_varchar2_table(32) := '6865656C3A206F70742E7A6F6F6D0A2020202020202C64697361626C65446F75626C65436C69636B5A6F6F6D3A2021286F70742E7A6F6F6D290A2020202020202C6765737475726548616E646C696E673A206F70742E6765737475726548616E646C696E';
wwv_flow_api.g_varchar2_table(33) := '670A202020207D293B0A20207D20656C7365207B0A202020206F70742E6D61702E7365744F7074696F6E73287B0A20202020202020647261676761626C653A206F70742E70616E0A2020202020202C7A6F6F6D436F6E74726F6C3A206F70742E7A6F6F6D';
wwv_flow_api.g_varchar2_table(34) := '0A2020202020202C7363726F6C6C776865656C3A206F70742E7A6F6F6D0A2020202020202C64697361626C65446F75626C65436C69636B5A6F6F6D3A2021286F70742E7A6F6F6D290A2020202020202C6765737475726548616E646C696E673A206F7074';
wwv_flow_api.g_varchar2_table(35) := '2E6765737475726548616E646C696E670A202020207D293B0A20207D0A09696620286F70742E73796E634974656D213D3D222229207B0A09097661722076616C203D202476286F70742E73796E634974656D293B0A09096966202876616C213D3D6E756C';
wwv_flow_api.g_varchar2_table(36) := '6C2026262076616C2E696E6465784F6628222C2229203E202D3129207B0A09090976617220617272203D2076616C2E73706C697428222C22293B0A09090973696D706C656D61702E7365744D61726B6572286F70742C6172725B305D2C6172725B315D29';
wwv_flow_api.g_varchar2_table(37) := '3B0A09097D0A090924282223222B6F70742E73796E634974656D292E6368616E67652866756E6374696F6E28297B200A090909766172206C61746C6E67203D20746869732E76616C75653B0A090909696620286C61746C6E67213D3D6E756C6C20262620';
wwv_flow_api.g_varchar2_table(38) := '6C61746C6E67213D3D756E646566696E6564202626206C61746C6E672E696E6465784F6628222C2229203E202D3129207B0A0909090976617220617272203D206C61746C6E672E73706C697428222C22293B0A0909090973696D706C656D61702E736574';
wwv_flow_api.g_varchar2_table(39) := '4D61726B6572286F70742C6172725B305D2C6172725B315D293B0A0909097D202020200A09097D293B0A097D0A09696620286F70742E616464726573734974656D213D3D222229207B0A09096F70742E67656F636F646572203D206E657720676F6F676C';
wwv_flow_api.g_varchar2_table(40) := '652E6D6170732E47656F636F6465723B0A097D0A202069662028216F70742E726561646F6E6C7929207B0A20202020676F6F676C652E6D6170732E6576656E742E6164644C697374656E6572286F70742E6D61702C2022636C69636B222C2066756E6374';
wwv_flow_api.g_varchar2_table(41) := '696F6E20286576656E7429207B0A202020202020766172206C6174203D206576656E742E6C61744C6E672E6C617428290A2020202020202020202C6C6E67203D206576656E742E6C61744C6E672E6C6E6728293B0A20202020202073696D706C656D6170';
wwv_flow_api.g_varchar2_table(42) := '2E7365744D61726B6572286F70742C6C61742C6C6E67293B0A202020202020696620286F70742E73796E634974656D213D3D222229207B0A20202020202020202473286F70742E73796E634974656D2C6C61742B222C222B6C6E67293B0A202020202020';
wwv_flow_api.g_varchar2_table(43) := '7D0A202020202020696620286F70742E616464726573734974656D213D3D222229207B0A202020202020202073696D706C656D61702E67657441646472657373286F70742C6C61742C6C6E67293B0A2020202020207D0A202020202020617065782E6A51';
wwv_flow_api.g_varchar2_table(44) := '75657279282223222B6F70742E726567696F6E4964292E7472696767657228226D6170636C69636B222C207B6D61703A6F70742E6D61702C206C61743A6C61742C206C6E673A6C6E677D293B0A202020207D293B0A20207D0A09696620286F70742E6765';
wwv_flow_api.g_varchar2_table(45) := '6F636F64654974656D213D222229207B0A09097661722067656F636F646572203D206E657720676F6F676C652E6D6170732E47656F636F64657228293B0A090924282223222B6F70742E67656F636F64654974656D292E6368616E67652866756E637469';
wwv_flow_api.g_varchar2_table(46) := '6F6E28297B0A09090973696D706C656D61702E67656F636F6465286F70742C67656F636F646572293B0A09097D293B0A097D0A09696620286F70742E67656F6C6F6361746529207B0A0909696620286E6176696761746F722E67656F6C6F636174696F6E';
wwv_flow_api.g_varchar2_table(47) := '29207B0A090909617065782E6465627567286F70742E726567696F6E49642B222067656F6C6F6361746522293B0A0909096E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F6E2870';
wwv_flow_api.g_varchar2_table(48) := '6F736974696F6E29207B0A0909090976617220706F73203D207B0A09090909096C61743A20706F736974696F6E2E636F6F7264732E6C617469747564652C0A09090909096C6E673A20706F736974696F6E2E636F6F7264732E6C6F6E6769747564650A09';
wwv_flow_api.g_varchar2_table(49) := '0909097D3B0A090909096F70742E6D61702E70616E546F28706F73293B0A09090909696620286F70742E67656F6C6F636174655A6F6F6D29207B0A0909090920206F70742E6D61702E7365745A6F6F6D286F70742E67656F6C6F636174655A6F6F6D293B';
wwv_flow_api.g_varchar2_table(50) := '0A090909097D0A2020202020202020696620286F70742E73796E634974656D213D3D222229207B0A202020202020202020202473286F70742E73796E634974656D2C706F732E6C61742B222C222B706F732E6C6E67293B0A20202020202020207D0A2020';
wwv_flow_api.g_varchar2_table(51) := '202020202020696620286F70742E616464726573734974656D213D3D222229207B0A2020202020202020202073696D706C656D61702E67657441646472657373286F70742C706F732E6C61742C706F732E6C6E67293B0A20202020202020207D0A090909';
wwv_flow_api.g_varchar2_table(52) := '09617065782E6A5175657279282223222B6F70742E726567696F6E4964292E74726967676572282267656F6C6F63617465222C207B6D61703A6F70742E6D61702C206C61743A706F732E6C61742C206C6E673A706F732E6C6E677D293B0A0909097D293B';
wwv_flow_api.g_varchar2_table(53) := '0A09097D20656C7365207B0A090909617065782E6465627567286F70742E726567696F6E49642B222062726F7773657220646F6573206E6F7420737570706F72742067656F6C6F636174696F6E22293B0A09097D0A097D0A09617065782E6A5175657279';
wwv_flow_api.g_varchar2_table(54) := '282223222B6F70742E726567696F6E4964292E7472696767657228226D61706C6F61646564222C207B6D61703A6F70742E6D61707D293B0A7D0A0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(133474210609251226)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_file_name=>'simplemap.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7661722073696D706C656D61703D7B67656F636F64653A66756E6374696F6E28652C6F297B617065782E6465627567282273696D706C656D61702E67656F636F646522292C6F2E67656F636F6465287B616464726573733A247628652E67656F636F6465';
wwv_flow_api.g_varchar2_table(2) := '4974656D292C636F6D706F6E656E745265737472696374696F6E733A2222213D3D652E636F756E7472793F7B636F756E7472793A652E636F756E7472797D3A7B7D7D2C66756E6374696F6E286F2C61297B696628613D3D676F6F676C652E6D6170732E47';
wwv_flow_api.g_varchar2_table(3) := '656F636F6465725374617475732E4F4B297B617065782E646562756728652E726567696F6E49642B222067656F636F6465206F6B22293B76617220743D6F5B305D2E67656F6D657472792E6C6F636174696F6E3B73696D706C656D61702E7365744D6172';
wwv_flow_api.g_varchar2_table(4) := '6B657228652C742E6C617428292C742E6C6E672829292C2222213D3D652E73796E634974656D2626247328652E73796E634974656D2C742E6C617428292B222C222B742E6C6E672829297D656C736520617065782E646562756728652E726567696F6E49';
wwv_flow_api.g_varchar2_table(5) := '642B222067656F636F64652077617320756E7375636365737366756C20666F722074686520666F6C6C6F77696E6720726561736F6E3A20222B61297D297D2C7365744D61726B65723A66756E6374696F6E28652C6F2C61297B696628617065782E646562';
wwv_flow_api.g_varchar2_table(6) := '7567282273696D706C656D61702E7365744D61726B657222292C6E756C6C213D3D6F26266E756C6C213D3D61297B76617220743D652E6D61726B65723F652E6D61726B65722E676574506F736974696F6E28293A6E657720676F6F676C652E6D6170732E';
wwv_flow_api.g_varchar2_table(7) := '4C61744C6E6728302C30293B6966286F3D3D742E6C617428292626613D3D742E6C6E67282929617065782E646562756728652E726567696F6E49642B22206D61726B6572206E6F74206368616E67656422293B656C73657B617065782E64656275672865';
wwv_flow_api.g_varchar2_table(8) := '2E726567696F6E49642B22206D6F7665206D61726B657222293B766172206E3D6E657720676F6F676C652E6D6170732E4C61744C6E67286F2C61293B652E6D61702E70616E546F286E292C652E6D61726B65725A6F6F6D2626652E6D61702E7365745A6F';
wwv_flow_api.g_varchar2_table(9) := '6F6D28652E6D61726B65725A6F6F6D292C652E6D61726B65723F28652E6D61726B65722E7365744D617028652E6D6170292C652E6D61726B65722E736574506F736974696F6E286E29293A652E6D61726B65723D6E657720676F6F676C652E6D6170732E';
wwv_flow_api.g_varchar2_table(10) := '4D61726B6572287B6D61703A652E6D61702C706F736974696F6E3A6E2C69636F6E3A652E69636F6E7D297D7D656C736520652E6D61726B6572262628617065782E646562756728652E726567696F6E49642B222072656D6F7665206D61726B657222292C';
wwv_flow_api.g_varchar2_table(11) := '652E6D61726B65722E7365744D6170286E756C6C29297D2C676574416464726573733A66756E6374696F6E28652C6F2C61297B617065782E6465627567282273696D706C656D61702E6765744164647265737322293B76617220743D7B6C61743A6F2C6C';
wwv_flow_api.g_varchar2_table(12) := '6E673A617D3B652E67656F636F6465722E67656F636F6465287B6C6F636174696F6E3A747D2C66756E6374696F6E286F2C61297B696628613D3D3D676F6F676C652E6D6170732E47656F636F6465725374617475732E4F4B297B666F7228693D303B693C';
wwv_flow_api.g_varchar2_table(13) := '6F2E6C656E6774683B692B2B29617065782E646562756728652E726567696F6E49642B2220726573756C745B222B692B225D3D222B6F5B695D2E666F726D61747465645F616464726573732B222028222B6F5B695D2E74797065732E6A6F696E28292B22';
wwv_flow_api.g_varchar2_table(14) := '2922293B6966286F5B305D297B247328652E616464726573734974656D2C6F5B305D2E666F726D61747465645F61646472657373293B76617220743D6F5B305D2E616464726573735F636F6D706F6E656E74733B666F7228693D303B693C742E6C656E67';
wwv_flow_api.g_varchar2_table(15) := '74683B692B2B29617065782E646562756728652E726567696F6E49642B2220726573756C745B305D20222B745B695D2E74797065732B223D222B745B695D2E73686F72745F6E616D652B222028222B745B695D2E6C6F6E675F6E616D652B222922293B61';
wwv_flow_api.g_varchar2_table(16) := '7065782E6A5175657279282223222B652E726567696F6E4964292E74726967676572282261646472657373222C7B6D61703A652E6D61702C726573756C743A6F5B305D7D297D656C73652077696E646F772E616C6572742822496E73756666696369656E';
wwv_flow_api.g_varchar2_table(17) := '7420726573756C747320666F756E6422297D656C736520613D3D3D676F6F676C652E6D6170732E47656F636F6465725374617475732E5A45524F5F524553554C54533F77696E646F772E616C65727428224E6F20726573756C747320666F756E6422293A';
wwv_flow_api.g_varchar2_table(18) := '77696E646F772E616C657274282247656F636F646572206661696C65642064756520746F3A20222B61297D297D2C696E69743A66756E6374696F6E2865297B617065782E6465627567282273696D706C656D61702E696E697422293B766172206F3D7B7A';
wwv_flow_api.g_varchar2_table(19) := '6F6F6D3A652E696E69745A6F6F6D2C63656E7465723A6E657720676F6F676C652E6D6170732E4C61744C6E6728652E696E69744C61742C652E696E69744C6E67292C6D61705479706549643A676F6F676C652E6D6170732E4D61705479706549642E524F';
wwv_flow_api.g_varchar2_table(20) := '41444D41507D3B696628652E6D61703D6E657720676F6F676C652E6D6170732E4D617028646F63756D656E742E676574456C656D656E744279496428652E636F6E7461696E6572292C6F292C652E6D61707374796C652626652E6D61702E7365744F7074';
wwv_flow_api.g_varchar2_table(21) := '696F6E73287B7374796C65733A652E6D61707374796C657D292C652E726561646F6E6C793F652E6D61702E7365744F7074696F6E73287B64697361626C6544656661756C7455493A21302C647261676761626C653A652E70616E2C7A6F6F6D436F6E7472';
wwv_flow_api.g_varchar2_table(22) := '6F6C3A652E7A6F6F6D2C7363726F6C6C776865656C3A652E7A6F6F6D2C64697361626C65446F75626C65436C69636B5A6F6F6D3A21652E7A6F6F6D2C6765737475726548616E646C696E673A652E6765737475726548616E646C696E677D293A652E6D61';
wwv_flow_api.g_varchar2_table(23) := '702E7365744F7074696F6E73287B647261676761626C653A652E70616E2C7A6F6F6D436F6E74726F6C3A652E7A6F6F6D2C7363726F6C6C776865656C3A652E7A6F6F6D2C64697361626C65446F75626C65436C69636B5A6F6F6D3A21652E7A6F6F6D2C67';
wwv_flow_api.g_varchar2_table(24) := '65737475726548616E646C696E673A652E6765737475726548616E646C696E677D292C2222213D3D652E73796E634974656D297B76617220613D247628652E73796E634974656D293B6966286E756C6C213D3D612626612E696E6465784F6628222C2229';
wwv_flow_api.g_varchar2_table(25) := '3E2D31297B76617220743D612E73706C697428222C22293B73696D706C656D61702E7365744D61726B657228652C745B305D2C745B315D297D24282223222B652E73796E634974656D292E6368616E67652866756E6374696F6E28297B766172206F3D74';
wwv_flow_api.g_varchar2_table(26) := '6869732E76616C75653B6966286E756C6C213D3D6F2626766F69642030213D3D6F26266F2E696E6465784F6628222C22293E2D31297B76617220613D6F2E73706C697428222C22293B73696D706C656D61702E7365744D61726B657228652C615B305D2C';
wwv_flow_api.g_varchar2_table(27) := '615B315D297D7D297D6966282222213D3D652E616464726573734974656D262628652E67656F636F6465723D6E657720676F6F676C652E6D6170732E47656F636F646572292C652E726561646F6E6C797C7C676F6F676C652E6D6170732E6576656E742E';
wwv_flow_api.g_varchar2_table(28) := '6164644C697374656E657228652E6D61702C22636C69636B222C66756E6374696F6E286F297B76617220613D6F2E6C61744C6E672E6C617428292C743D6F2E6C61744C6E672E6C6E6728293B73696D706C656D61702E7365744D61726B657228652C612C';
wwv_flow_api.g_varchar2_table(29) := '74292C2222213D3D652E73796E634974656D2626247328652E73796E634974656D2C612B222C222B74292C2222213D3D652E616464726573734974656D262673696D706C656D61702E6765744164647265737328652C612C74292C617065782E6A517565';
wwv_flow_api.g_varchar2_table(30) := '7279282223222B652E726567696F6E4964292E7472696767657228226D6170636C69636B222C7B6D61703A652E6D61702C6C61743A612C6C6E673A747D297D292C2222213D652E67656F636F64654974656D297B766172206E3D6E657720676F6F676C65';
wwv_flow_api.g_varchar2_table(31) := '2E6D6170732E47656F636F6465723B24282223222B652E67656F636F64654974656D292E6368616E67652866756E6374696F6E28297B73696D706C656D61702E67656F636F646528652C6E297D297D652E67656F6C6F636174652626286E617669676174';
wwv_flow_api.g_varchar2_table(32) := '6F722E67656F6C6F636174696F6E3F28617065782E646562756728652E726567696F6E49642B222067656F6C6F6361746522292C6E6176696761746F722E67656F6C6F636174696F6E2E67657443757272656E74506F736974696F6E2866756E6374696F';
wwv_flow_api.g_varchar2_table(33) := '6E286F297B76617220613D7B6C61743A6F2E636F6F7264732E6C617469747564652C6C6E673A6F2E636F6F7264732E6C6F6E6769747564657D3B652E6D61702E70616E546F2861292C652E67656F6C6F636174655A6F6F6D2626652E6D61702E7365745A';
wwv_flow_api.g_varchar2_table(34) := '6F6F6D28652E67656F6C6F636174655A6F6F6D292C2222213D3D652E73796E634974656D2626247328652E73796E634974656D2C612E6C61742B222C222B612E6C6E67292C2222213D3D652E616464726573734974656D262673696D706C656D61702E67';
wwv_flow_api.g_varchar2_table(35) := '65744164647265737328652C612E6C61742C612E6C6E67292C617065782E6A5175657279282223222B652E726567696F6E4964292E74726967676572282267656F6C6F63617465222C7B6D61703A652E6D61702C6C61743A612E6C61742C6C6E673A612E';
wwv_flow_api.g_varchar2_table(36) := '6C6E677D297D29293A617065782E646562756728652E726567696F6E49642B222062726F7773657220646F6573206E6F7420737570706F72742067656F6C6F636174696F6E2229292C617065782E6A5175657279282223222B652E726567696F6E496429';
wwv_flow_api.g_varchar2_table(37) := '2E7472696767657228226D61706C6F61646564222C7B6D61703A652E6D61707D297D7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(133479114099489512)
,p_plugin_id=>wwv_flow_api.id(501163678790508848)
,p_file_name=>'simplemap.min.js'
,p_mime_type=>'text/javascript'
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
