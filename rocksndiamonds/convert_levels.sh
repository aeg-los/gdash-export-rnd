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

CONFIG_FILENAME="convert_levels.conf"
CAVE_INFO_FILENAME="bd_cave_info.conf"

GFX_SET_OLD_1="gfx_gdash_boulder_dash_1"
GFX_SET_OLD_2="gfx_gdash_boulder_dash_2"
GFX_SET_OLD_3="gfx_gdash_boulder_dash_3"
GFX_SET_NEW="gfx_gdash_boulder_rush"
SND_SET="snd_gdash_boulder_dash"
MUS_SET_1="mus_gdash_boulder_dash_1"
MUS_SET_2="mus_gdash_boulder_dash_2"

declare -A levelsets

source "$CONFIG_FILENAME"


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

get_value_from_conf ()
{
    LEVELSET=$1
    NR=$2

    grep "^$LEVELSET:" "$CAVE_INFO_FILENAME" | awk -F\: "{ print $"$NR" }"
}

create_level_group_conf ()
{
    local LEVEL_DIR=$1
    local BASENAME_DIR=$2

    local CONF_FILE="$LEVEL_DIR/levelinfo.conf"
    local NAME=`echo "$BASENAME_DIR"`
    local AUTHOR_DIR=`echo "$LEVEL_DIR" | sed -e "s%$CONV_DIR/\([^/]*\).*%\1%"`
    local LEVELKEY=`echo "$LEVEL_DIR" | sed -e "s%$CONV_DIR/%%"`
    local AUTHOR=`grep ":$LEVELKEY/" "$CAVE_INFO_FILENAME" | awk -F\: '{ print $4 }' | head -1`

    NAME=$(cleanup_text_from_filename "$NAME")
    AUTHOR_DIR=$(cleanup_text_from_filename "$AUTHOR_DIR")

    AUTHOR=$AUTHOR_DIR

    if [ "$LEVEL_DIR" = "$CONV_DIR" ]; then
	AUTHOR="Various Authors"
    fi

    if [ "$AUTHOR" = "" ]; then
	echo "ERROR: Cannot determine author for directory '$LEVEL_DIR'!"

	exit 10
    fi

    echo "name:                           $NAME"		>> "$CONF_FILE"
    echo "author:                         $AUTHOR"		>> "$CONF_FILE"
    echo ""							>> "$CONF_FILE"
    echo "latest_engine:                  true"			>> "$CONF_FILE"
    echo "level_group:                    true"			>> "$CONF_FILE"
}

create_level_set_conf ()
{
    local LEVEL_DIR=$1
    local LEVELSET=$2
    local FILENAME=$3

    local CONF_FILE="$LEVEL_DIR/levelinfo.conf"

    local NAME=$(   get_value_from_conf "$LEVELSET" "3")
    local AUTHOR=$( get_value_from_conf "$LEVELSET" "4")
    local YEAR=$(   get_value_from_conf "$LEVELSET" "6")

    echo "name:                           $NAME"		>> "$CONF_FILE"
    echo "author:                         $AUTHOR"		>> "$CONF_FILE"

    if [ "$YEAR" != "" ]; then
	echo "year:                           $YEAR"		>> "$CONF_FILE"
    fi

    LEVELSET_SHORT=`echo "$LEVELSET" | sed -e "s/_atari//"`

    GFX_SET_OLD="$GFX_SET_OLD_1"
    MUS_SET="$MUS_SET_1"

    if [ "$LEVELSET_SHORT" = "bd_boulder_dash_2" ]; then
	GFX_SET_OLD="$GFX_SET_OLD_2"
	MUS_SET="$MUS_SET_2"
    elif [ "$LEVELSET_SHORT" = "bd_boulder_dash_3" ]; then
	GFX_SET_OLD="$GFX_SET_OLD_3"
    fi

    NUM_LEVELS=`$CMD_ROCKSNDIAMONDS -e "dump levelset $FILENAME"	\
	| grep "Number of levels"					\
	| awk '{ print $4 }'`

    if [ "$NUM_LEVELS" = "" ]; then
	echo "WARNING: Cannot determine number of levels for level set '$LEVELSET'!"

	NUM_LEVELS=100
    fi

    FIRST_LEFVEL=1

    echo ""							>> "$CONF_FILE"
    echo "levels:                         $NUM_LEVELS"		>> "$CONF_FILE"
    echo "first_level:                    $FIRST_LEFVEL"	>> "$CONF_FILE"
    echo ""							>> "$CONF_FILE"
    echo "graphics_set.old:               $GFX_SET_OLD"		>> "$CONF_FILE"
    echo "graphics_set.new:               $GFX_SET_NEW"		>> "$CONF_FILE"
    echo "sounds_set:                     $SND_SET"		>> "$CONF_FILE"
    echo "music_set:                      $MUS_SET"		>> "$CONF_FILE"
}

convert_caveset ()
{
    local FILENAME=$1
    local FILENAME_EXT=$2
    local INDENT=$3

    local PREFIX="$INDENT-"
    INDENT="  $INDENT"

    local LEVELKEY=`echo "$FILENAME" | sed -e "s/$ORIG_BASE_DIR\///"`

    LEVELSET_COUNT=`grep ":$LEVELKEY$" "$CAVE_INFO_FILENAME" | wc -l`

    if [ "$LEVELSET_COUNT" = "0" ]; then
	echo "ERROR: No level set identifier found for caveset file '$LEVELKEY'!"

	exit 10
    fi

    if [ "$LEVELSET_COUNT" != "1" ]; then
	echo "ERROR: No unique level set identifier found for caveset file '$LEVELKEY'!"

	exit 10
    fi

    LEVELSET=`grep ":$LEVELKEY$" "$CAVE_INFO_FILENAME" | awk -F\: '{ print $1 }'`

    if [ "$LEVELSET" = "" ]; then
	echo "ERROR: No valid level set identifier found for caveset file '$LEVELKEY'!"

	exit 10
    fi

    if [ "${levelsets[$LEVELSET]}" != "" ]; then
	echo "ERROR: Level set identifier '$LEVELSET' already used!"

	exit 10
    fi

    levelsets[$LEVELSET]=1

    local ORIG_SUBDIR=`dirname "$FILENAME" | sed -e "s/^$ORIG_BASE_DIR\///"`
    local CONV_SUBDIR="$CONV_DIR/$ORIG_SUBDIR/$LEVELSET"

    local BASENAME=`basename "$FILENAME" ".$FILENAME_EXT"`
    local BASENAME_FIXED=$(cleanup_filename "$BASENAME")".$FILENAME_EXT"
    local CONV_SUBDIR_FIXED=$(cleanup_filename "$CONV_SUBDIR")

    echo "$PREFIX creating level set directory '$CONV_SUBDIR_FIXED' ..."

    mkdir -p "$CONV_SUBDIR_FIXED"

    cp -a "$FILENAME" "$CONV_SUBDIR_FIXED/$BASENAME_FIXED"

    create_level_set_conf "$CONV_SUBDIR_FIXED" "$LEVELSET" "$FILENAME"
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
