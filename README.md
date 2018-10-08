# Simple Map (Google Map) ![APEX Plugin](https://cdn.rawgit.com/Dani3lSun/apex-github-badges/b7e95341/badges/apex-plugin-badge.svg)

**A Region plugin for Oracle Application Express**

This allows you to add a Google Map region to any page.

![plugin-simplemap-preview.png](https://raw.githubusercontent.com/jeffreykemp/jk64-plugin-simplemap/master/src/plugin-simplemap-preview.png)

The user can click the map to set a single Marker. You can have the region synchronize the map with an item you nominate - if so, the position where the user clicks will be written to the item as a lat,long pair of coordinates. If the item is loaded with some coordinates, or changed by the user, the map marker will be moved to the indicated position.

You can also enable additional features including Search by Address (find a point by an entered address), and Reverse Geocode Search (find an address for a selected point).

## DEMO ##

[https://apex.oracle.com/pls/apex/f?p=JK64_SIMPLE_MAP](https://apex.oracle.com/pls/apex/f?p=JK64_SIMPLE_MAP&c=JK64)

## PRE-REQUISITES ##

* [Oracle Application Express 5.0.2](https://apex.oracle.com) or later
* You need a [Google Maps API Key](https://developers.google.com/maps/documentation/javascript/get-api-key#get-an-api-key)

## INSTALLATION INSTRUCTIONS ##

1. Download the [latest release](https://github.com/jeffreykemp/jk64-plugin-simplemap/releases/latest)
2. Install the plugin to your application - **region_type_plugin_com_jk64_simple_google_map.sql**
3. Supply your **Google API Key** (Component Settings)
4. Add a region to the page, select type **JK64 Simple Google Map [Plug-In]**

For more information refer to the [WIKI](https://github.com/jeffreykemp/jk64-plugin-simplemap/wiki).

**Need more features?**

Try the [JK64 Report Map plugin](https://github.com/jeffreykemp/jk64-plugin-reportmap) which has many more features, including the ability to take a SQL Query and render each record on the map.

