create or replace package jk64simplemap_pkg as

function render (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
return apex_plugin.t_region_render_result;

end jk64simplemap_pkg;
/
show err

create or replace package body jk64simplemap_pkg as
-- JK64 Simple Google Map v0.7

g_tochar_format constant varchar2(100) := 'fm99999999999990.099999999999999999999999999999';

function render (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
return apex_plugin.t_region_render_result
as
    subtype plugin_attr is varchar2(32767);

    -- Variables
    l_result       apex_plugin.t_region_render_result;
    l_script       varchar2(32767);
    l_region       varchar2(100);
    l_js_params    varchar2(1000);
    l_lat          number;
    l_lng          number;
    l_readonly     varchar2(1000) := 'false';
    l_zoom_enabled varchar2(1000) := 'true';
    l_pan_enabled  varchar2(1000) := 'true';

    -- Plugin attributes (application level)
    l_api_key          plugin_attr := p_plugin.attribute_01;

    -- Component attributes
    l_latlong          plugin_attr := p_region.attribute_01;
    l_zoom             plugin_attr := p_region.attribute_02;
    l_region_height    plugin_attr := p_region.attribute_03;
    l_item_name        plugin_attr := p_region.attribute_04;
    l_marker_zoom      plugin_attr := p_region.attribute_05;
    l_icon             plugin_attr := p_region.attribute_06;
    l_sign_in          plugin_attr := p_region.attribute_07;
    l_geocode_item     plugin_attr := p_region.attribute_08;
    l_country          plugin_attr := p_region.attribute_09;
    l_mapstyle         plugin_attr := p_region.attribute_10;
    l_address_item     plugin_attr := p_region.attribute_11;
    l_geolocate        plugin_attr := p_region.attribute_12;
    l_geoloc_zoom      plugin_attr := p_region.attribute_13;
    l_readonly_expr    plugin_attr := p_region.attribute_14;
    l_zoom_expr        plugin_attr := p_region.attribute_15;
    l_pan_expr         plugin_attr := p_region.attribute_16;
    l_gesture_handling plugin_attr := p_region.attribute_17;
    
begin
    apex_plugin_util.debug_region (
        p_plugin => p_plugin,
        p_region => p_region,
        p_is_printer_friendly => p_is_printer_friendly);

    if l_readonly_expr is not null then
        l_readonly := apex_plugin_util.get_plsql_expression_result (
            'case when (' || l_readonly_expr
            || ') then ''true'' else ''false'' end');
        if l_readonly not in ('true','false') then
            raise_application_error(-20000, 'Read-only attribute must evaluate to true or false.');
        end if;
    end if;

    if l_zoom_expr is not null then
        l_zoom_enabled := apex_plugin_util.get_plsql_expression_result (
            'case when (' || l_zoom_expr
            || ') then ''true'' else ''false'' end');
        if l_zoom_enabled not in ('true','false') then
            raise_application_error(-20000, 'Zoom attribute must evaluate to true or false.');
        end if;
    end if;

    if l_pan_expr is not null then
        l_pan_enabled := apex_plugin_util.get_plsql_expression_result (
            'case when (' || l_pan_expr
            || ') then ''true'' else ''false'' end');
        if l_pan_enabled not in ('true','false') then
            raise_application_error(-20000, 'Pan attribute must evaluate to true or false.');
        end if;
    end if;

    if l_sign_in = 'Y' then
        l_js_params := '&'||'signed_in=true';
    end if;
    
    apex_javascript.add_library
        (p_name                  => 'js?key=' || l_api_key || l_js_params
        ,p_directory             => 'https://maps.googleapis.com/maps/api/'
        ,p_skip_extension        => true);

    apex_javascript.add_library
        (p_name                  => 'simplemap'
        ,p_directory             => p_plugin.file_prefix
        ,p_check_to_add_minified => true);
    
    l_lat := to_number(substr(l_latlong,1,instr(l_latlong,',')-1));
    l_lng := to_number(substr(l_latlong,instr(l_latlong,',')+1));
    
    l_gesture_handling := nvl(l_gesture_handling,'auto');
    
    l_region := case
                when p_region.static_id is not null
                then p_region.static_id
                else 'R'||p_region.id
                end;
    
    l_script := '<script>
var opt_#REGION# = {
container:"map_#REGION#_container"
,regionId:"#REGION#"
,initZoom:' || l_zoom || '
,initLat:' || to_char(l_lat,g_tochar_format) || '
,initLng:' || to_char(l_lng,g_tochar_format) || '
,markerZoom:' || l_marker_zoom || '
,icon:"' || l_icon || '"
,syncItem:"' || l_item_name || '"
,geocodeItem:"' || l_geocode_item || '"
,country:"' || l_country || '"'
||   case when l_mapstyle is not null then '
,mapstyle:' || l_mapstyle
     end || '
,addressItem:"' || l_address_item || '"'
||   case when l_geolocate = 'Y' then '
,geolocate:true'
     ||   case when l_geoloc_zoom is not null then '
,geolocateZoom:' || l_geoloc_zoom
          end
     end || '
,readonly:' || l_readonly || '
,zoom:' || l_zoom_enabled || '
,pan:' || l_pan_enabled || '
,gestureHandling:"' || l_gesture_handling || '"
};
function r_#REGION#(f){/in/.test(document.readyState)?setTimeout("r_#REGION#("+f+")",9):f()}
r_#REGION#(function(){simplemap.init(opt_#REGION#);});
function click_#REGION#(lat,lng) {simplemap.setMarker(opt_#REGION#,lat,lng);}
</script>
<div id="map_#REGION#_container" style="min-height:' || l_region_height || 'px"></div>';

  sys.htp.p(replace(l_script,'#REGION#',l_region));

  return l_result;
end render;

end jk64simplemap_pkg;
/
show err