class LocationUtils

	@getSaveData: (data) ->
		mapPosition = data?.mapPosition
		position = mapPosition?.position

		if not position or not CUI.Map.isValidPosition(position)
			return null

		saveData =
			mapPosition: mapPosition

		if not CUI.util.isEmpty(data.displayValue)
			saveData.displayValue = data.displayValue

			fullText = Object.values(data.displayValue).filter((value) -> !!value).join(", ")
			saveData._fulltext =
				l10ntext: data.displayValue
				text: fullText
				string: fullText

		if data.group
			saveData.group = data.group

		return saveData