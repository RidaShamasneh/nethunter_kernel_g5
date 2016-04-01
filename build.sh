#!/bin/bash
# Kali NetHunter kernel for LG G5 build script by jcadduono

################### BEFORE STARTING ################
#
# download a working toolchain and extract it somewhere and configure this
# file to point to the toolchain's root directory.
#
# once you've set up the config section how you like it, you can simply run
# ./build.sh [VARIANT]
#
##################### VARIANTS #####################
#
# h820  = AT&T (US)
#         LGH820  (LG G5)
#
# h830  = T-Mobile (US)
#         LGH830  (LG G5)
#
# h831  = Canada
#         LGH831  (LG G5)
#
# ls992 = Sprint (US)
#         LGLS992 (LG G5)
#
# us992 = US Cellular (US)
#         LGUS992 (LG G5)
#
# vs987 = Verizon (US)
#         LGVS987 (LG G5)
#
# h850  = International (Global)
#         LGH850  (LG G5)
#
# f700k = KT Corporation (Korea)
#         LGF700K (LG G5)
#
# f700l = LG Uplus (Korea)
#         LGF700L (LG G5)
#
# f700s = SK Telecom (Korea)
#         LGF700S (LG G5)
#
###################### CONFIG ######################

# root directory of NetHunter G5 git repo (default is this script's location)
RDIR=$(pwd)

[ "$VER" ] ||
# version number
VER=$(cat "$RDIR/VERSION")

# directory containing cross-compile arm64 toolchain
TOOLCHAIN=$HOME/build/toolchain/gcc-linaro-arm64-5.3

# amount of cpu threads to use in kernel make process
THREADS=5

############## SCARY NO-TOUCHY STUFF ###############

export ARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/bin/aarch64-linux-gnu-

[ "$TARGET" ] || TARGET=nethunter
[ "$1" ] && {
	VARIANT=$1
} || {
	VARIANT=h850
}
[ "$DEBUG" ] && {
	EXTRA_DEFCONFIG=debug_defconfig
} || {
	EXTRA_DEFCONFIG=
}
DEFCONFIG=${TARGET}_defconfig
VARIANT_DEFCONFIG=variant_${VARIANT}_defconfig

[ -f "$RDIR/arch/$ARCH/configs/$DEFCONFIG" ] || {
	echo "Config $DEFCONFIG not found in $ARCH configs!"
	exit 1
}

[ -f "$RDIR/arch/$ARCH/configs/$VARIANT_DEFCONFIG" ] || {
	echo "Variant $VARIANT not found in $ARCH configs!"
	exit 1
}

export LOCALVERSION="$TARGET-$VARIANT-$VER"
KDIR=$RDIR/build/arch/$ARCH/boot

ABORT()
{
	echo "Error: $*"
	exit 1
}

CLEAN_BUILD()
{
	echo "Cleaning build..."
	cd "$RDIR"
	rm -rf build
}

SETUP_BUILD()
{
	echo "Creating kernel config for $LOCALVERSION..."
	cd "$RDIR"
	mkdir -p build
	make -C "$RDIR" O=build "$DEFCONFIG" \
		VARIANT_DEFCONFIG="$VARIANT_DEFCONFIG" \
		EXTRA_DEFCONFIG="$EXTRA_DEFCONFIG" || ABORT "Failed to set up build"
}

BUILD_KERNEL()
{
	echo "Starting build for $LOCALVERSION..."
	while ! make -C "$RDIR" O=build -j"$THREADS"; do
		read -p "Build failed. Retry? " do_retry
		case $do_retry in
			Y|y) continue ;;
			*) return 1 ;;
		esac
	done
}

BUILD_DTB()
{
	echo "Generating dtb.img..."
	cd "$RDIR"
	scripts/dtbTool/dtbTool -o "$KDIR/dtb.img" "$KDIR/" -s 4096 || ABORT "Failed to generate dtb.img!"
}

CLEAN_BUILD && SETUP_BUILD && BUILD_KERNEL && BUILD_DTB && echo "Finished building $LOCALVERSION!"
