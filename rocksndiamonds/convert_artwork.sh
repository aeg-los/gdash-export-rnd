#!/bin/bash

# =============================================================================
# convert_artwork.sh
# -----------------------------------------------------------------------------
# convert BD style artwork from static and template files to final artwork sets
# =============================================================================

ORIG_BASE_DIR="artwork"
ORIG_SND_DIR="sound"
ORIG_MUS_DIR="music"

ORIG_STAT_DIR="$ORIG_BASE_DIR/files.static"
ORIG_TMPL_DIR="$ORIG_BASE_DIR/files.template"

BUILD_DIR="$ORIG_BASE_DIR/files.BUILD"

ARTWORK_TYPES="gfx snd mus"
ARTWORK_PREFIX_SET="gdash"
ARTWORK_PREFIX_ALL="ALL"

CONF_FILE_GIC_GAME="graphics/gic_game.conf"
CONF_FILES="$CONF_FILE_GIC_GAME"

GFX_SET_BOULDER_RUSH="gfx_gdash_boulder_rush"
SND_SET_BOULDER_DASH="snd_gdash_boulder_dash"
MUS_SET_BOULDER_DASH="mus_gdash_boulder_dash"

MUS_FILE_PREFIX="bd"
MUS_FILE_SUFFIXES="1 2"

declare -A GFX_FILES_BOULDER_DASH=\
(							\
    ["_GFX_FILE_DEFAULT_"]="c64_gfx_default.png"	\
    ["_GFX_FILE_EDITOR_"]="c64_gfx_editor.png"		\
)

declare -A GFX_FILES_BOULDER_RUSH=\
(							\
    ["_GFX_FILE_DEFAULT_"]="boulder_rush.png"		\
    ["_GFX_FILE_EDITOR_"]="boulder_rush_editor.png"	\
)

declare -A SND_FILES_MAPPING=\
(							\
    ["stone.ogg"]="stone_wall.wav"			\
    ["slime.ogg"]="slime_lava_replicator.wav"		\
    ["expanding_wall.ogg"]="SKIP"			\
    ["falling_wall.ogg"]="SKIP"				\
    ["lava.ogg"]="SKIP"					\
    ["replicator.ogg"]="SKIP"				\
)


# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------

# (none yet)

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------

if [ ! -d "$ORIG_STAT_DIR" ]; then
    echo "ERROR: Source directory '$ORIG_STAT_DIR' does not exist!"

    exit 10
fi

if [ ! -d "$ORIG_TMPL_DIR" ]; then
    echo "ERROR: Source directory '$ORIG_TMPL_DIR' does not exist!"

    exit 10
fi

if [ -d "$BUILD_DIR" ]; then
    echo "ERROR: Target directory '$BUILD_DIR' already exists!"

    exit 10
fi

mkdir -p "$BUILD_DIR"

echo "Converting GDash artwork to R'n'D artwork sets ..."

for TYPE in $ARTWORK_TYPES; do
    echo "- converting $TYPE sets ..."

    for LEVELSET_DIR in "$ORIG_STAT_DIR/${TYPE}_${ARTWORK_PREFIX_SET}"_*; do
	SET=`basename "$LEVELSET_DIR"`

	echo "  * copying static files for artwork set '$SET' ..."

	rsync -a "$LEVELSET_DIR" "$BUILD_DIR"

	if [ -d "$ORIG_STAT_DIR/${TYPE}_${ARTWORK_PREFIX_ALL}" ]; then
	    rsync -a $ORIG_STAT_DIR/${TYPE}_${ARTWORK_PREFIX_ALL}/ $BUILD_DIR/$SET/
	fi

	for j in $CONF_FILES; do
	    CONF_FILE=$j
	    CONF_FILE_TMPL="$ORIG_TMPL_DIR/${TYPE}_${ARTWORK_PREFIX_ALL}/$CONF_FILE.tmpl"

	    if [ -f "$CONF_FILE_TMPL" ]; then
		echo "  * creating config file for artwork set '$SET' ['$CONF_FILE'] ..."

		if [ "$CONF_FILE" = "$CONF_FILE_GIC_GAME" ]; then
		    if [ "$SET" = "$GFX_SET_BOULDER_RUSH" ]; then
			GFX_FILE_DEFAULT=${GFX_FILES_BOULDER_RUSH["_GFX_FILE_DEFAULT_"]}
			GFX_FILE_EDITOR=${GFX_FILES_BOULDER_RUSH["_GFX_FILE_EDITOR_"]}
		    else
			GFX_FILE_DEFAULT=${GFX_FILES_BOULDER_DASH["_GFX_FILE_DEFAULT_"]}
			GFX_FILE_EDITOR=${GFX_FILES_BOULDER_DASH["_GFX_FILE_EDITOR_"]}
		    fi

		    cat "$CONF_FILE_TMPL"					\
			| sed -s "s/_GFX_FILE_DEFAULT_/$GFX_FILE_DEFAULT/g"	\
			| sed -s "s/_GFX_FILE_EDITOR_/$GFX_FILE_EDITOR/g"	\
			> "$BUILD_DIR/$SET/$CONF_FILE"
		fi
	    fi
	done
    done
done

echo "- converting sound files ..."

for SND_FILENAME_OGG in $ORIG_SND_DIR/*.ogg; do
    SND_BASENAME_OGG=`basename "$SND_FILENAME_OGG"`
    SND_BASENAME_WAV=${SND_FILES_MAPPING["$SND_BASENAME_OGG"]}

    if [ "$SND_BASENAME_WAV" = "SKIP" ]; then
	echo "  * skipping duplicate sound file '$SND_BASENAME_OGG' ..."

	continue
    fi

    if [ "$SND_BASENAME_WAV" = "" ]; then
	SND_BASENAME_WAV=`basename "$SND_FILENAME_OGG" ".ogg"`.wav
    fi

    SND_FILENAME_WAV="$BUILD_DIR/$SND_SET_BOULDER_DASH/sounds/$SND_BASENAME_WAV"

    echo "  * converting sound file '$SND_BASENAME_OGG' to '$SND_BASENAME_WAV' ..."

    ffmpeg -i "$SND_FILENAME_OGG" "$SND_FILENAME_WAV" 2> /dev/null

    if [ "$?" != "0" ]; then
	echo "ERROR: converting sound file '$SND_BASENAME_OGG' failed!"

	exit 10
    fi
done

echo "- converting music files ..."

for MUS_FILE_SUFFIX in $MUS_FILE_SUFFIXES; do
    MUS_SET="${MUS_SET_BOULDER_DASH}_$MUS_FILE_SUFFIX"
    MUS_BASENAME_OGG="$MUS_FILE_PREFIX$MUS_FILE_SUFFIX.ogg"
    MUS_FILENAME_OGG="$ORIG_MUS_DIR/$MUS_BASENAME_OGG"
    MUS_BASENAME_MP3=`basename "$MUS_FILENAME_OGG" ".ogg"`.mp3
    MUS_FILENAME_MP3="$BUILD_DIR/$MUS_SET/music/$MUS_BASENAME_MP3"

    echo "  * converting sound file '$MUS_BASENAME_OGG' to '$MUS_BASENAME_MP3' ..."

    ffmpeg -i "$MUS_FILENAME_OGG" "$MUS_FILENAME_MP3" 2> /dev/null

    if [ "$?" != "0" ]; then
	echo "ERROR: converting sound file '$MUS_BASENAME_OGG' failed!"

	exit 10
    fi
done

echo "- creating top-level config file ..."

cp -a "$ORIG_STAT_DIR/levelinfo.conf" "$BUILD_DIR"

echo "Done"

exit 0
