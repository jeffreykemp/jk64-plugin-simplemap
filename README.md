# Simple Google Map region plugin for Oracle Application Express. #

This allows you to add a Google Map region to any page.

![plugin-simplemap-preview.png](https://raw.githubusercontent.com/jeffreykemp/jk64-plugin-simplemap/master/plugin-simplemap-preview.png)

The user can click the map to set a single Marker. You can have the region synchronize the map with an item you nominate - if so, the position where the user clicks will be written to the item as a lat,long pair of coordinates. If the item is loaded with some coordinators, or changed by the user, the map marker will be moved to the indicated position.

## DEMO ##

[https://apex.oracle.com/pls/apex/f?p=JK64_SIMPLE_MAP](https://apex.oracle.com/pls/apex/f?p=JK64_SIMPLE_MAP)

## INSTALLATION INSTRUCTIONS ##

1. Download the [latest release](https://github.com/jeffreykemp/jk64-plugin-simplemap/releases/latest)
2. Install the plugin to your application - **region_type_plugin_com_jk64_simple_google_map.sql**
3. *(optional)* Supply your Google API Key (NOTE: the plugin is usable without one)
4. Add a region to the page, select type JK64 Simple Google Map [plugin]

**Need more features?**

Try the [JK64 Report Map plugin](https://github.com/jeffreykemp/jk64-plugin-reportmap) which has many more features, including the ability to take a SQL Query and render each record on the map.
