# =============================================================================
# Makefile to convert GDash caves and artwork to R'n'D level and artwork sets
# =============================================================================

CONV_LEVELS_DIR := levels
CONV_ARTWORK_DIR := artwork/files.BUILD
CONV_ARTWORK_TARGET_DIR := $(CONV_LEVELS_DIR)/Boulder_Dash/artwork

all:help

help:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "- convert-levels    - convert GDash caves to R'n'D level sets"
	@echo "- convert-artwork   - convert GDash artwork to R'n'D artwork sets"
	@echo "- copy-artwork      - copy converted artwork sets to level sets"
	@echo "- convert-all       - convert GDash caves and artwork"
	@echo ""
	@echo "- clean-levels      - delete all converted R'n'D level sets"
	@echo "- clean-artwork     - delete all converted R'n'D artwork sets"
	@echo "- clean-all         - delete all converted level and artwork sets"
	@echo ""

convert-levels:
	./convert_levels.sh | tee convert_levels.out

convert-artwork:
	./convert_artwork.sh | tee convert_artwork.out

copy-artwork:
	rm -rf "$(CONV_ARTWORK_TARGET_DIR)"
	cp -a "$(CONV_ARTWORK_DIR)" "$(CONV_ARTWORK_TARGET_DIR)"

convert-all: convert-levels convert-artwork copy-artwork

clean-levels:
	rm -rf "$(CONV_LEVELS_DIR)"

clean-artwork:
	rm -rf "$(CONV_ARTWORK_DIR)"

clean-all: clean-levels clean-artwork
