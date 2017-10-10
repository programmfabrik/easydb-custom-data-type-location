###
 * easydb-custom-data-type-location
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class CustomDataTypeLocation extends CustomDataType

	getCustomDataTypeName: ->
		"custom:base.custom-data-type-location.location"

	getCustomDataTypeNameLocalized: ->
		$$("custom.data.type.location.name")

	getCustomDataOptionsInDatamodelInfo: (custom_settings) ->
		preffix = "custom.data.type.location.setting.schema.rendered_options."
		tags = []
		if custom_settings["type"]
			tags.push($$(preffix + custom_settings["type"]["value"]))
		return tags

	renderFieldAsGroup: () ->
		false

	renderEditorInput: (data) ->
		onMarkerSelected = (location) =>
			CUI.Events.trigger
				node: map
				type: "editor-changed"

			data[@name()].latitude = location.lat
			data[@name()].longitude = location.lng

		map = @__initMap(data, true, onMarkerSelected)
		map

	renderDetailOutput: (data) ->
		map = @__initMap(data, false)
		map

	__initMap: (data, clickable, onMarkerSelected) ->
		if not data[@name()]
			dataField = {}
			data[@name()] = dataField
		else
			dataField = data[@name()]

		if dataField.latitude && dataField.longitude
			currentPosition =
				lat: dataField.latitude
				lng: dataField.longitude

		# TODO: Center default location?
		map = new CUI.LeafletMap(
			center: if currentPosition then currentPosition else {lat: 52.520645, lng: 13.409779}
			zoom: 12
			clickable: clickable
			onMarkerSelected: onMarkerSelected
		)

		if currentPosition
			map.setSelectedMarkerPosition(currentPosition)

		map

	__isLocationSet: (location) =>
		location && location.latitude && location.longitude

	getSaveData: (data, save_data) ->
		location = data[@name()]
		if !@__isLocationSet(location)
			save_data[@name()] = null
			return save_data

		save_data[@name()] =
			latitude: location.latitude
			longitude: location.longitude

	showEditPopover: (data, element, layout) ->
		console.debug(data)
		console.debug(element)
		console.debug(layout)

CustomDataType.register(CustomDataTypeLocation)
