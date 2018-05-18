###
 * easydb-custom-data-type-location
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class CustomDataTypeLocation extends CustomDataType

	@__groups = [
		type: "long_dash"
		polyline: "10,8"
		text: "── ── ── ──"
	,
		type: "short_dash"
		polyline: "5,5"
		text: "─ ─ ─ ─ ─ ─ ─"
	,
		type: "dot_dash"
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
		return opts.mode == 'editor' or opts.mode == 'editor-template'

	renderEditorInput: (data) ->
		initData = @__initData(data)
		form = @__initForm(initData)
		form

	isVisible: (mode, opts) ->
	# For now until we implement the search.
		return super(mode, opts) and mode != "expert"

	renderDetailOutput: (data) ->
		initData = @__initData(data)

		position = initData.mapPosition.position

		label = @__buildDisplayNameOutput(initData)

		if !label
			displayFormat = CUI.MapInput.getDefaultDisplayFormat()
			label = new CUI.Label
				text: CUI.util.formatCoordinates(position, displayFormat)
				size: "normal"

		icon = new CUI.IconMarker(
			icon: initData.mapPosition.iconName,
			color: initData.mapPosition.iconColor,
			tooltip: text: $$("custom.data.type.location.detail.output.center-button")
			onClick: =>
				CUI.Events.trigger
					type: "map-detail-center"
					info:	position
		)

		horizontalLayout = new CUI.HorizontalLayout
			maximize_horizontal: true
			left:
				content: icon
			center:
				content: label

		CUI.Events.listen
			type: "location-marker-clicked"
			node: horizontalLayout
			call: (_, info) =>
				if info.data == initData
					CUI.dom.scrollIntoView(horizontalLayout)
					CUI.dom.addClass(horizontalLayout, "ez5-marker-highlight")
					CUI.setTimeout( =>
						CUI.dom.removeClass(horizontalLayout, "ez5-marker-highlight")
					, 2000)

		CUI.Events.listen
			type: "location-marker-fullscreen-clicked"
			node: horizontalLayout
			call: (_, info) =>
				if info.data == initData
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

			# Replaces the stored group for the structure necessary to render it.
			if initData.group and not initData.groupColor
				for group in CustomDataTypeLocation.__groups
					if initData.group.type == group.type
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

	getSaveData: (data, save_data) ->
		data = data[@name()] or data._template?[@name()]
		mapPosition = data?.mapPosition
		position = mapPosition?.position

		if not position or not CUI.Map.isValidPosition(position)
			save_data[@name()] = null
			return save_data

		saveData =
			mapPosition: mapPosition
			displayValue: if not CUI.util.isEmpty(data.displayValue) then data.displayValue

		if data.group
			saveData.group =
				type: data.group.type
				options:
					color: data.groupColor
					polyline: data.group.polyline

		save_data[@name()] = saveData

	allowsList: ->
		return false

CustomDataType.register(CustomDataTypeLocation)

CUI.ready ->

	CUI.Events.registerEvent
		type: "location-marker-clicked"
		sink: true

	CUI.Events.registerEvent
		type: "location-marker-fullscreen-clicked"
		sink: true