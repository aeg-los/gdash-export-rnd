# =============================================================================
# Makefile to convert GDash caves to R'n'D level sets
# =============================================================================

CONV_BASE_DIR := levels

all:help

help:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "- convert_levels - convert GDash caves to R'n'D level sets"
	@echo "- clean          - delete all converted R'n'D level sets"
	@echo ""

convert_levels:
	./convert_levels.sh | tee convert_levels.out

clean:
	rm -rf "$(CONV_BASE_DIR)"
