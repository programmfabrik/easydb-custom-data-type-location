# easydb-custom-data-type-location

Custom datatype plugin for **easydb5**.

This custom data type allows you to store gps coordinates in the database and show them on a map in the detail view of records.

## Moving to fylr

fylr has a port of this plugin, [fylr-plugin-custom-data-type-location](https://github.com/programmfabrik/fylr-plugin-custom-data-type-location), so instances moved to fylr keep their "Location" fields. The port is not maintained: in fylr, coordinates belong in a field of type "GeoJSON" (geo-json plugin), which can also be searched and shown on the search map. The steps to move the values from a "Location" field to a "GeoJSON" field are in the "Moving to GeoJSON" section of the [port's README](https://github.com/programmfabrik/fylr-plugin-custom-data-type-location#moving-to-geojson).
