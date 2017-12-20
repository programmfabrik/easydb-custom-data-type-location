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
		label = new CUI.Label
			content:
				CUI.util.formatCoordinates(position, displayFormat)

		icon = new CUI.Icon(icon: initData.mapPosition.iconName)
		CUI.dom.setStyleOne(icon, "color", initData.mapPosition.iconColor)

		horizontalLayout = new CUI.HorizontalLayout
			maximize_vertical: false
			maximize_horizontal: true
			left:
				content: icon
			center:
				content: label
			right:
				content:centerIcon

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

		save_data[@name()] =
			mapPosition: mapPosition

CustomDataType.register(CustomDataTypeLocation)


