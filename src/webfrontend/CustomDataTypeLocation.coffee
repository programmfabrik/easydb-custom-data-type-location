###
 * easydb-custom-data-type-location
 * Copyright (c) 2013 - 2016 Programmfabrik GmbH
 * MIT Licence
 * https://github.com/programmfabrik/coffeescript-ui, http://www.coffeescript-ui.org
###
class CustomDataTypeLocation extends CustomDataType
	getCustomDataTypeName: ->
		"custom:base.custom-data-type-location.link"

CustomDataType.register(CustomDataTypeLocation)
