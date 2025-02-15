###
 * easydb-custom-data-type-location
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class CustomDataTypeLocation extends CustomDataType

	# These are the options of the groups. The structure of the object 'value' is the same as the structure needed by the map.
	@__groupOptions = [
		value:
			type: "long_dash"
			options:
				polyline: "10,8"
				color: "black"
		text: "── ── ── ──"
	,
		value:
			type: "short_dash"
			options:
				polyline: "5,5"
				color: "black"
		text: "─ ─ ─ ─ ─ ─ ─"
	,
		value:
			type: "dot_dash"
			options:
				polyline: "1,4"
				color: "black"
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
		return opts.mode == 'editor' or opts.mode == 'editor-template'

	renderEditorInput: (data) ->
		initData = @__initData(data)
		form = @__initForm(initData)
		form

	isVisible: (mode, opts) ->
		# For now until we implement the search.
		return super(mode, opts) and mode != "expert"

	isEmpty: (data) ->
		isEmpty = super(data)
		if isEmpty
			return isEmpty
		position = data[@name()].mapPosition?.position
		if not position
			return true
		return not CUI.Map.isValidPosition(position)

	needsDirectRender: ->
		return true


	__getOutputLabel: (data) ->
		initData = @__initData(data)

		position = initData.mapPosition?.position
		if not position
			return

		label = @__buildDisplayNameOutput(initData)

		if not label
			displayFormat = CUI.MapInput.getDefaultDisplayFormat()
			label = new CUI.Label
				text: CUI.util.formatCoordinates(position, displayFormat)
				size: "normal"
		return label

	renderTableOutput: (data, top_level_data, opts) ->
		return @__getOutputLabel(data)

	renderDetailOutput: (data, _, opts) ->
		initData = @__initData(data)
		label = @__getOutputLabel(data)

		icon = new CUI.IconMarker(
			icon: initData.mapPosition.iconName,
			color: initData.mapPosition.iconColor,
			tooltip: text: $$("custom.data.type.location.detail.output.center-button")
			onClick: =>
				if typeof MapDetailPlugin != 'undefined'
					CUI.Events.trigger
						type: "map-detail-center"
						info:	position
				else
					console.warn("MapDetailPlugin is not available.")
		)

		horizontalLayout = new CUI.HorizontalLayout
			maximize_horizontal: true
			left:
				content: icon
			center:
				content: label

		# When renderDetailOutput is not invoked with opts.detail, probably it is not invoked from the detail sidebar. (print for example)
		if not opts.detail
			return horizontalLayout

		plugins = opts.detail.getPlugins()
		for plugin in plugins
			if typeof MapDetailPlugin != 'undefined' and plugin instanceof MapDetailPlugin
				mapPlugin = plugin
				break

		if mapPlugin
			mapData =
				position: initData.mapPosition.position
				iconColor: initData.mapPosition.iconColor
				iconName: initData.mapPosition.iconName
				group: initData.group
			mapPlugin.addMarker(mapData)

			CUI.Events.listen
				type: "map-detail-click-location"
				node: horizontalLayout
				call: (_, info) =>
					if info.data == mapData
						CUI.dom.scrollIntoView(horizontalLayout)
						CUI.dom.addClass(horizontalLayout, "ez5-marker-highlight")
						CUI.setTimeout( =>
							CUI.dom.removeClass(horizontalLayout, "ez5-marker-highlight")
						, 2000)

			CUI.Events.listen
				type: "map-detail-fullscreen-click-location"
				node: horizontalLayout
				call: (_, info) =>
					if info.data == mapData
						multiOutput = @__buildDisplayNameOutput(initData)
						popover = new CUI.Popover
							element: info.icon
							pane:
								padded: true
								content: multiOutput or CUI.util.formatCoordinates(initData.mapPosition.position, CUI.MapInput.getDefaultDisplayFormat())
							onHide: =>
								popover.destroy()
						popover.show()

		return horizontalLayout

	__buildDisplayNameOutput: (initData) ->
		hasDisplayValue = false
		for _, value of initData.displayValue
			if not CUI.util.isEmpty(value)
				hasDisplayValue = true
				break

		if hasDisplayValue
			multiOutput = (new CUI.MultiOutput
				name: "displayValue"
				data: initData
				control: ez5.loca.getLanguageControl()
				showOnlyPreferredKey: false).start()

		return multiOutput

	__initData: (data) ->
		if not data[@name()]
			initData = {}
			data[@name()] = initData
		else
			initData = data[@name()]

		# Replaces the stored group with the options, to match the value in the select.
		if initData.group
			for group in CustomDataTypeLocation.__groupOptions
				if initData.group.type == group.value.type
					initData.group = group.value
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
					for group in CustomDataTypeLocation.__groupOptions
						options.push(text: group.text, value: group.value)
					options
			]
		,
			type: CUI.Form
			fields: [
				type: CUI.MultiInput
				name: "displayValue"
				control: ez5.loca.getLanguageControl()
			]
		]

		form = new CUI.Form
			maximize_horizontal: true
			fields: fields
			data: initData
			onDataChanged: =>
				CUI.Events.trigger
					node: form
					type: "editor-changed"
		form.start()
		form

	getSaveData: (data, save_data = {}) ->
		data = data[@name()] or data._template?[@name()]
		save_data[@name()] = LocationUtils.getSaveData(data)

	isPluginSupported: (plugin) ->
		if typeof MapDetailPlugin != 'undefined' and plugin instanceof MapDetailPlugin
			return true
		return false

	allowsList: ->
		return false

	supportsStandard: ->
		return true

CustomDataType.register(CustomDataTypeLocation)
