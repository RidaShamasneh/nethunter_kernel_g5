#!/bin/bash
# Kali NetHunter kernel for LG G5 build script by jcadduono
# This build script builds all variants in ./VARIANTS
#
###################### CONFIG ######################

# root directory of NetHunter G5 git repo (default is this script's location)
RDIR=$(pwd)

# output directory of Image.gz and dtb.img
OUT_DIR=$HOME/build/kali-nethunter/nethunter-installer/kernels/marshmallow

############## SCARY NO-TOUCHY STUFF ###############

ARCH=arm64
KDIR=$RDIR/build/arch/$ARCH/boot

MOVE_IMAGES()
{
	echo "Moving kernel Image.gz and dtb.img to $VARIANT_DIR/..."
	mkdir -p "$VARIANT_DIR"
	rm -f "$VARIANT_DIR/Image.gz" "$VARIANT_DIR/dtb.img"
	mv "$KDIR/Image.gz" "$KDIR/dtb.img" "$VARIANT_DIR/"
}

mkdir -p $OUT_DIR

[ "$1" ] && {
	VARIANTS=$*
} || {
	VARIANTS=$(cat "$RDIR/VARIANTS")
}

export TARGET=nethunter

for VARIANT in $VARIANTS
do
	VARIANT_DIR=$OUT_DIR/$VARIANT
	"$RDIR/build.sh" "$VARIANT" && MOVE_IMAGES || {
		echo "Failed to build $VARIANT! Aborting..."
		exit 1
	}
done

echo "Finished building NetHunter kernels!"
