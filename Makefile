PLUGIN_NAME = custom-data-type-location

EASYDB_LIB = ../../library

L10N_FILES = l10n/$(PLUGIN_NAME).csv
L10N_GOOGLE_KEY = 1Z3UPJ6XqLBp-P8SUf-ewq4osNJ3iZWKJB83tc6Wrfn0
L10N_GOOGLE_GID = 617191347
L10N2JSON = python $(EASYDB_LIB)/tools/l10n2json.py

INSTALL_FILES = \
	$(WEB)/l10n/cultures.json \
	$(WEB)/l10n/de-DE.json \
	$(WEB)/l10n/en-US.json \
	$(WEB)/l10n/es-ES.json \
	$(WEB)/l10n/it-IT.json \
	$(WEB)/custom-data-type-location.scss \
	$(JS) \
	CustomDataTypeLocation.config.yml

COFFEE_FILES = src/webfrontend/CustomDataTypeLocation.coffee

all: build

SCSS_FILES = src/webfrontend/scss/main.scss

include $(EASYDB_LIB)/tools/base-plugins.make
build: code $(L10N) $(SCSS)

code: $(JS)

clean: clean-base

wipe: wipe-base
