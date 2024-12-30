# =============================================================================
# Makefile to convert GDash caves and artwork to R'n'D level and artwork sets
# =============================================================================

CONV_LEVELS_DIR := levels
CONV_ARTWORK_DIR := artwork/files.BUILD
CONV_ARTWORK_TARGET_DIR := $(CONV_LEVELS_DIR)/Boulder_Dash/artwork

PACKAGE_DIR = Boulder_Dash
ifeq ($(BUILD_COMPLETE),0)
PACKAGE_NAME = $(PACKAGE_DIR)
LOG_SUFFIX = log-stripped
else
PACKAGE_NAME = gdash-levels
LOG_SUFFIX = log
endif
PACKAGE_VERSION = 1.0.1
PACKAGE_BASENAME = ${PACKAGE_NAME}-${PACKAGE_VERSION}
PACKAGE_FILENAME_ZIP = ${PACKAGE_BASENAME}.zip

# fail after first failed command in a pipeline of commands
SHELL = /bin/bash -o pipefail

all: help

help:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "- convert-levels    - convert GDash caves to R'n'D level sets"
	@echo "- convert-artwork   - convert GDash artwork to R'n'D artwork sets"
	@echo "- copy-artwork      - copy converted artwork sets to level sets"
	@echo "- convert-all       - convert GDash caves and artwork"
	@echo "- package-zip       - create zip file from converted level sets"
	@echo ""
	@echo "- build             - clean all, convert all and package zip"
	@echo ""
	@echo "- clean-levels      - delete all converted R'n'D level sets"
	@echo "- clean-artwork     - delete all converted R'n'D artwork sets"
	@echo "- clean-package     - delete packages with converted sets"
	@echo "- clean-all         - delete all converted level and artwork sets"
	@echo ""

convert-levels:
	./convert_levels.sh | tee convert_levels.$(LOG_SUFFIX)

convert-artwork:
	./convert_artwork.sh | tee convert_artwork.$(LOG_SUFFIX)

copy-artwork:
	rm -rf "$(CONV_ARTWORK_TARGET_DIR)"
	cp -a "$(CONV_ARTWORK_DIR)" "$(CONV_ARTWORK_TARGET_DIR)"

convert-all: convert-levels convert-artwork copy-artwork

package-zip:
	@if [ -f "${PACKAGE_FILENAME_ZIP}" ]; then				\
		echo "ERROR: file '${PACKAGE_FILENAME_ZIP}' already exists!";	\
	else									\
	(									\
		echo "Creating package file '${PACKAGE_FILENAME_ZIP}' ...";	\
		cd "${CONV_LEVELS_DIR}";					\
		zip -r -9 ../"${PACKAGE_FILENAME_ZIP}" "${PACKAGE_DIR}"		\
	) > package_zip.$(LOG_SUFFIX);						\
	fi

build-complete:
	@BUILD_COMPLETE=1 make clean-all convert-all package-zip

build-stripped:
	@BUILD_COMPLETE=0 make clean-all convert-levels package-zip

build: build-complete

clean-levels:
	rm -rf "$(CONV_LEVELS_DIR)"

clean-artwork:
	rm -rf "$(CONV_ARTWORK_DIR)"

clean-package:
	rm -f "$(PACKAGE_FILENAME_ZIP)"

clean-all: clean-levels clean-artwork
