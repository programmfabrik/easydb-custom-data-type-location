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
		displayFormat = CUI.MapInput.getDefaultDisplayFormat()
		label = new CUI.Label
			content:
				CUI.util.formatCoordinates(initData.position, displayFormat)
		return label

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
			name: "position"
			iconName: initData.iconName
			iconColor: initData.iconColor
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
		position = data?.position

		if not CUI.util.isEmpty(position) and not CUI.isPlainObject(position)
			position = CUI.util.parseCoordinates(position)

		if not position or not CUI.Map.isValidPosition(position)
			save_data[@name()] = null
			return save_data

		save_data[@name()] =
			position: position
			iconColor: data.iconColor
			iconName: data.iconName

CustomDataType.register(CustomDataTypeLocation)


