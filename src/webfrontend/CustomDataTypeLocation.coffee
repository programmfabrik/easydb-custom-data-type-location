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
		initData = @__initData(data)
		form = @__initForm(initData)
		form

	renderDetailOutput: (data) ->
		initData = @__initData(data)

		position = initData.mapPosition.position

		centerIcon = new CUI.Button
			class: "ez5-location-display-button"
			icon: "fa-dot-circle-o"
			onClick: =>
				CUI.Events.trigger
					type: "map-detail-center"
					info:	position

		displayFormat = CUI.MapInput.getDefaultDisplayFormat()
		labelButton = new CUI.Button
			text: CUI.util.formatCoordinates(position, displayFormat)
			appearance: "flat"
			onClick: =>
				CUI.MapInput.defaults.displayFormat = @__getNextDisplayFormat()
				CUI.Events.trigger
					type: "location-marker-format-changed"

		icon = new CUI.Icon(icon: initData.mapPosition.iconName)
		CUI.dom.setStyleOne(icon, "color", initData.mapPosition.iconColor)

		horizontalLayout = new CUI.HorizontalLayout
			maximize_vertical: false
			maximize_horizontal: true
			left:
				content: icon
			center:
				content: labelButton
			right:
				content: centerIcon

		CUI.Events.listen
			type: "location-marker-format-changed"
			node: horizontalLayout
			call: () =>
				text = CUI.util.formatCoordinates(position, CUI.MapInput.getDefaultDisplayFormat())
				labelButton.setText(text)

		CUI.Events.listen
			type: "location-marker-clicked"
			node: horizontalLayout
			call: (_, info) =>
				if info == initData
					console.debug("Highlight")

		return horizontalLayout

	__initData: (data) ->
		if not data[@name()]
			initData = {}
			data[@name()] = initData
		else
			initData = data[@name()]

		initData

	__initForm: (initData) ->
		fields = [
			type: CUI.MapInput
			name: "mapPosition"
			mapOptions:
				zoom: 2
		,
			type: CUI.Select
			data: @__selectedMarkerOptions
			name: "groupColor"
			options: =>
				options = [text: ez5.loca.text("custom.data.type.location.select.no.group"), value: null]
				for color in ["#31a354", "#2b8cbe", "#dd1c77", "#8856a7", "#de2d26"]
					icon = new CUI.Icon(class: "css-swatch")
					CUI.dom.setStyle(icon, background: color)
					options.push(icon: icon, value: color)
				options
		]

		form = new CUI.Form
			fields: fields
			data: initData
			horizontal: true
			onDataChanged: =>
				CUI.Events.trigger
					node: form
					type: "editor-changed"
		form.start()
		form

	getSaveData: (data, save_data) ->
		data = data[@name()] or data._template?[@name()]
		mapPosition = data?.mapPosition
		position = mapPosition?.position

		if not position or not CUI.Map.isValidPosition(position)
			save_data[@name()] = null
			return save_data

		save_data[@name()] =
			mapPosition: mapPosition
			groupColor: data.groupColor

	# This is a 'for now' function, and it is used to get the next display format to switch by clicking in the output.
	# This will be probably removed when the format switching is in other place.
	__getNextDisplayFormat: ->
		displayFormats = Object.keys(CUI.MapInput.displayFormats)
		index = displayFormats.indexOf(CUI.MapInput.defaults.displayFormat)
		index++
		return if index < displayFormats.length then displayFormats[index] else displayFormats[0]

CustomDataType.register(CustomDataTypeLocation)

CUI.ready ->
	CUI.Events.registerEvent
		type: "location-marker-format-changed"
		sink: true

CUI.ready ->
	CUI.Events.registerEvent
		type: "location-marker-clicked"
		sink: true