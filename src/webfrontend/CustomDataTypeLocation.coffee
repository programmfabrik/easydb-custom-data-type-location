###
 * easydb-custom-data-type-location
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class CustomDataTypeLocation extends CustomDataType

	@__groups = [
		number: 1
		polyline: "10,8"
		text: "── ── ── ──"
	,
		number: 2
		polyline: "5,5"
		text: "─ ─ ─ ─ ─ ─ ─"
	,
		number: 3
		polyline: "1,4"
		text: "∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙"
	]

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

	renderFieldAsGroup: (_, __, opts) ->
		return opts.mode == 'editor'

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

		icon = new CUI.IconMarker(icon: initData.mapPosition.iconName, color: initData.mapPosition.iconColor)

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

			# Replaces the stored group for the structure necessary to render it.
			if initData.group
				for group in CustomDataTypeLocation.__groups
					if initData.group.number == group.number
						initData.groupColor = initData.group.options.color
						initData.group = group
						break

		initData

	__initForm: (initData) ->
		fields = [
			type: CUI.MapInput
			name: "mapPosition"
			mapOptions:
				zoom: 2
		,
			type: CUI.Form
			horizontal: true
			fields: [
				type: CUI.Select
				name: "group"
				options: =>
					options = [text: ez5.loca.text("custom.data.type.location.select.no.group"), value: null]
					for group in CustomDataTypeLocation.__groups
						options.push(text: group.text, value: group)
					options
			,
				type: CUI.Select
				name: "groupColor"
				options: =>
					options = [icon: 'css-swatch', value: null]
					for color in ez5.session.getDefaults().client.tag_colors?.trim().split(",")
						options.push(icon: 'css-swatch ez5-tag-color-' + color, value: color)
					options
				]
		]

		form = new CUI.Form
			fields: fields
			data: initData
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

		saveData =
			mapPosition: mapPosition

		if data.group
			saveData.group =
				number: data.group.number
				options:
					color: data.groupColor
					polyline: data.group.polyline

		save_data[@name()] = saveData


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