#!/bin/bash

# =============================================================================
# convert_levels.sh
# -----------------------------------------------------------------------------
# convert BD style plain level directories to R'n'D style level set directories
# =============================================================================

ORIG_BASE_DIR="caves"
ORIG_DIR="$ORIG_BASE_DIR"

CONV_BASE_DIR="levels"
CONV_MAIN_DIR="Boulder_Dash"
CONV_DIR="$CONV_BASE_DIR/$CONV_MAIN_DIR"

CAVE_INFO_FILENAME="bd_cave_info.conf"

GFX_SET="gfx_gdash_boulder_dash"
SND_SET="snd_gdash_boulder_dash"

declare -A levelsets


# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

cleanup_filename ()
{
    ENTRY=$1

    ENTRY=`echo "$ENTRY" | sed -e "s/[^A-Za-z0-9/-]/_/g"`
    ENTRY=`echo "$ENTRY" | sed -e "s/__*/_/g"`
    ENTRY=`echo "$ENTRY" | sed -e "s/_$//g"`

    echo "$ENTRY"
}

cleanup_levelset_subdir ()
{
    ENTRY=$1

    ENTRY=`echo "$ENTRY" | tr 'A-Z' 'a-z'`
    ENTRY=`echo "$ENTRY" | sed -e "s/[^a-z0-9]/_/g"`
    ENTRY=`echo "$ENTRY" | sed -e "s/_s_/s_/g"`
    ENTRY="bd_$ENTRY"

    echo $(cleanup_filename "$ENTRY")
}

cleanup_text_from_filename ()
{
    ENTRY=$1

    ENTRY=`echo "$ENTRY" | tr '_' ' '`

    echo "$ENTRY"
}

get_value_from_bd_file ()
{
    FILENAME=$1
    FIELD=$2

    VALUE=`cat "$FILENAME" | dos2unix | grep "$FIELD=" | head -1 | sed -e "s/$FIELD=//"`

    echo "$VALUE"
}

create_level_group_conf ()
{
    local LEVEL_DIR=$1
    local BASENAME_CAVE=$2

    local CONF_FILE="$LEVEL_DIR/levelinfo.conf"
    local NAME=`echo "$BASENAME_CAVE"`
    local AUTHOR=`echo "$LEVEL_DIR" | sed -e "s%$CONV_DIR/\([^/]*\).*%\1%"`

    if [ "$LEVEL_DIR" = "$CONV_DIR" ]; then
	AUTHOR="Various Authors"
    fi

    NAME=$(cleanup_text_from_filename "$NAME")
    AUTHOR=$(cleanup_text_from_filename "$AUTHOR")

    echo "name:                           $NAME"		>> "$CONF_FILE"
    echo "author:                         $AUTHOR"		>> "$CONF_FILE"
    echo ""							>> "$CONF_FILE"
    echo "latest_engine:                  true"			>> "$CONF_FILE"
    echo "level_group:                    true"			>> "$CONF_FILE"
}

create_level_set_conf ()
{
    local LEVEL_DIR=$1
    local FILENAME=$2
    local FILENAME_EXT=$3

    local LEVELSET=`basename "$LEVEL_DIR"`
    local CONF_FILE="$LEVEL_DIR/levelinfo.conf"

    local LEVELKEY=`echo "$FILENAME" | sed -e "s/$ORIG_BASE_DIR\///"`

    local NAME=`basename "$FILENAME" ".$FILENAME_EXT"`
    local AUTHOR=`echo "$LEVEL_DIR" | sed -e "s%$CONV_DIR/\([^/]*\).*%\1%"`

    NAME=$(cleanup_text_from_filename "$NAME")
    AUTHOR=$(cleanup_text_from_filename "$AUTHOR")
    YEAR=""

    if [ "$FILENAME_EXT" = "bd" ]; then
	NAME_BD=$(get_value_from_bd_file "$FILENAME" "Name")

	if [ "$NAME_BD" != "" -a "$NAME_BD" != "$NAME" ]; then
	    echo "INFO: Using name '$NAME_BD' instead of '$NAME'."

	    NAME=$NAME_BD
	fi

	AUTHOR_BD=$(get_value_from_bd_file "$FILENAME" "Author")

	if [ "$AUTHOR_BD" != "" -a "$AUTHOR_BD" != "$AUTHOR" ]; then
	    echo "INFO: Using author '$AUTHOR_BD' instead of '$AUTHOR'."

	    AUTHOR=$AUTHOR_BD
	fi

	DATE_BD=$(get_value_from_bd_file "$FILENAME" "Date")
	YEAR_BD=`echo "$DATE_BD" | sed -e "s/.*\([0-9][0-9][0-9][0-9]\).*/\1/"`

	if [ "$YEAR_BD" != "" -a "$YEAR_BD" != "$YEAR" ]; then
	    echo "INFO: Using year '$YEAR_BD' instead of '$YEAR'."

	    YEAR=$YEAR_BD
	fi
    fi

    echo "name:                           $NAME"		>> "$CONF_FILE"
    echo "author:                         $AUTHOR"		>> "$CONF_FILE"

    if [ "$YEAR" != "" ]; then
	echo "year:                         $YEAR"		>> "$CONF_FILE"
    fi

    echo ""							>> "$CONF_FILE"
    echo "levels:                         100"			>> "$CONF_FILE"
    echo "first_level:                    1"			>> "$CONF_FILE"
    echo ""							>> "$CONF_FILE"
    echo "graphics_set:                   $GFX_SET"		>> "$CONF_FILE"
    echo "sounds_set:                     $SND_SET"		>> "$CONF_FILE"

    echo "$LEVELSET::$NAME:$AUTHOR::$YEAR:$LEVELKEY" >> "$CAVE_INFO_FILENAME"
}

convert_caveset ()
{
    local FILENAME=$1
    local FILENAME_EXT=$2
    local INDENT=$3

    local PREFIX="$INDENT-"
    INDENT="  $INDENT"

    local BASENAME=`basename "$FILENAME"`
    local BASENAME_CAVE=`basename "$FILENAME" ".$FILENAME_EXT"`
    local LEVELSET_CAVE=$(cleanup_levelset_subdir "$BASENAME_CAVE")

    if [ "${levelsets[$LEVELSET_CAVE]}" != "" ]; then
	echo "WARNING: Level set '$LEVELSET_CAVE' already used!"

	# exit 5
    fi

    levelsets[$LEVELSET_CAVE]=1

    local ORIG_SUBDIR=`dirname "$FILENAME" | sed -e "s/^$ORIG_BASE_DIR\///"`
    local CONV_SUBDIR="$CONV_DIR/$ORIG_SUBDIR/$LEVELSET_CAVE"

    local BASENAME_FIXED=$(cleanup_filename "$BASENAME_CAVE")".$FILENAME_EXT"
    local CONV_SUBDIR_FIXED=$(cleanup_filename "$CONV_SUBDIR")

    echo "$PREFIX creating level set directory '$CONV_SUBDIR_FIXED' ..."

    mkdir -p "$CONV_SUBDIR_FIXED"

    cp -a "$FILENAME" "$CONV_SUBDIR_FIXED/$BASENAME_FIXED"

    create_level_set_conf "$CONV_SUBDIR_FIXED" "$FILENAME" "$FILENAME_EXT"
}

process_caveset ()
{
    local FILENAME=$1
    local INDENT=$2

    local PREFIX="$INDENT-"
    INDENT="  $INDENT"

    local BASENAME=`basename "$FILENAME"`

    echo "$PREFIX processing caveset file '$BASENAME' ..."

    local EXT=`echo "$ENTRY" | sed -e "s/.*\.//"`

    if [ "$EXT" != "bd" ]; then
	local FILENAME_BD=`echo "$FILENAME" | sed -e "s/$EXT$/bd/"`

	if [ -f "$FILENAME_BD" ]; then
	    local BASENAME_BD=`basename "$FILENAME_BD"`

	    echo "  $PREFIX using file '$BASENAME_BD' instead -- skipping"

	    return
	fi
    fi

    convert_caveset "$FILENAME" "$EXT" "$INDENT"
}

process_directory ()
{
    local DIR=$1
    local INDENT=$2

    local PREFIX="$INDENT-"
    INDENT="  $INDENT"

    echo "$PREFIX processing caves directory '$DIR' ..."

    for i in `ls "$DIR"`; do
	local ENTRY="$DIR/$i"

	if [ -d "$ENTRY" ]; then
	    process_directory "$ENTRY" "$INDENT"
	elif `echo "$ENTRY" | grep -q "\.bd$"`; then
	    process_caveset "$ENTRY" "$INDENT"
	elif `echo "$ENTRY" | grep -q "\.gds$"`; then
	    process_caveset "$ENTRY" "$INDENT"
	elif `echo "$ENTRY" | grep -q "\.brc$"`; then
	    process_caveset "$ENTRY" "$INDENT"
	elif `echo "$ENTRY" | grep -q "\.zip$"`; then
	    process_caveset "$ENTRY" "$INDENT"
	fi
    done

    if [ "$DIR" != "$ORIG_BASE_DIR" ]; then
	local SUBDIR=`echo "$DIR" | sed -e "s/^$ORIG_BASE_DIR\///"`
	local CONV_SUBDIR="$CONV_DIR/$SUBDIR"
	local BASENAME_DIR=`basename "$DIR"`

	create_level_group_conf "$CONV_SUBDIR" "$BASENAME_DIR"
    fi
}


# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

if [ ! -d "$ORIG_BASE_DIR" ]; then
    echo "ERROR: Source directory '$ORIG_BASE_DIR' does not exist!"

    exit 10
fi

if [ -d "$CONV_BASE_DIR" ]; then
    echo "ERROR: Target directory '$CONV_BASE_DIR' already exists!"

    exit 10
fi

mkdir -p "$CONV_DIR"

echo "Converting BD caves to R'n'D level sets ..."

create_level_group_conf "$CONV_DIR" "$CONV_MAIN_DIR"

process_directory "$ORIG_DIR" ""

echo "Done"

exit 0
