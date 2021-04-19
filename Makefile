PLUGIN_NAME = custom-data-type-location

L10N_FILES = l10n/$(PLUGIN_NAME).csv
L10N_GOOGLE_KEY = 1Z3UPJ6XqLBp-P8SUf-ewq4osNJ3iZWKJB83tc6Wrfn0
L10N_GOOGLE_GID = 617191347

INSTALL_FILES = \
	$(WEB)/l10n/cultures.json \
	$(WEB)/l10n/de-DE.json \
	$(WEB)/l10n/en-US.json \
	$(WEB)/l10n/es-ES.json \
	$(WEB)/l10n/it-IT.json \
	$(CSS) \
	$(JS) \
	CustomDataTypeLocation.config.yml

COFFEE_FILES = \
	src/webfrontend/LocationUtils.coffee \
	src/webfrontend/CustomDataTypeLocation.coffee

all: build

SCSS_FILES = src/webfrontend/scss/custom-data-type-location.scss

include easydb-library/tools/base-plugins.make
build: code $(L10N) css

UPDATE_SCRIPT_COFFEE_FILES = \
	src/webfrontend/LocationUtils.coffee \
	src/script/LocationUpdate.coffee
UPDATE_SCRIPT_BUILD_FILE = build/scripts/location-update.js

${UPDATE_SCRIPT_BUILD_FILE}: $(subst .coffee,.coffee.js,${UPDATE_SCRIPT_COFFEE_FILES})
	mkdir -p $(dir $@)
	cat $^ > $@

code: $(JS) $(UPDATE_SCRIPT_BUILD_FILE)

clean: clean-base

wipe: wipe-base
