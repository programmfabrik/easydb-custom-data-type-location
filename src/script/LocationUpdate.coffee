class LocationUpdate

	__start_update: ({server_config, plugin_config}) ->
		ez5.respondSuccess({
			state: {
				"start_update": new Date().toUTCString()
			}
		})

	__updateData: ({objects, plugin_config}) ->

		objectsToUpdate = []
		for object in objects
			dataUpdated = LocationUtils.getSaveData(object.data)
			if CUI.util.isEqual(object.data, dataUpdated)
				continue
			object.data = dataUpdated
			objectsToUpdate.push(object)

		return ez5.respondSuccess({payload: objectsToUpdate})

	main: (data) ->
		if not data
			ez5.respondError("custom.data.type.location.update.error.payload-missing")
			return

		for key in ["action", "server_config", "plugin_config"]
			if (!data[key])
				ez5.respondError("custom.data.type.location.update.error.payload-key-missing", {key: key})
				return

		if (data.action == "start_update")
			@__start_update(data)
			return

		else if (data.action == "update")
			if (!data.objects)
				ez5.respondError("custom.data.type.location.update.error.objects-missing")
				return

			if (!(data.objects instanceof Array))
				ez5.respondError("custom.data.type.location.update.error.objects-not-array")
				return

			if (!data.state)
				ez5.respondError("custom.data.type.location.update.error.state-missing")
				return

			if (!data.batch_info)
				ez5.respondError("custom.data.type.location.update.error.batch_info-missing")
				return

			@__updateData(data)
			return
		else
			ez5.respondError("custom.data.type.location.update.error.invalid-action", {action: data.action})


module.exports = new LocationUpdate()