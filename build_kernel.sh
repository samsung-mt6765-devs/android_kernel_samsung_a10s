#!/bin/bash

#
# Rissu's kernel build script.
#

#
# We decided to use clang-13, or known as clang-r428724 for compiling.
# Also, you can use clang-11/12 if you don't have it.
#
# Target: use it for custom rom
#

# COLORS SHEET
RED='\e[1;31m'
YELLOW='\e[1;33m'
NC='\e[0m'

pr_err() {
	echo -e "${RED}[E] $@${NC}";
	exit 1;
}
pr_warn() {
	echo -e "${YELLOW}[W] $@${NC}";
}
pr_info() {
	echo "[I] $@";
}


if [ -d /rsuntk ]; then
	pr_info "Rissu environment detected."
	export CROSS_COMPILE=/rsuntk/env/google/bin/aarch64-linux-android-
	export PATH=/rsuntk/env/clang-13/bin:$PATH
 	export DEFCONFIG="lineage_defconfig"
else
	if [ -z $CROSS_COMPILE ]; then
		pr_err "Invalid empty variable for \$CROSS_COMPILE"
	fi
	if [ -z $PATH ]; then
		pr_err "Invalid empty variable for \$PATH"
	fi
	if [ -z $DEFCONFIG ]; then
		pr_warn "Empty variable for \$DEFCONFIG, using yukiprjkt_defconfig as default."
		DEFCONFIG="yukiprjkt_defconfig"
	fi
fi

# Now support 99.9% LLVM (Why? Because for some weird reason, 
# if we didn't include CROSS_COMPILE, it just messed up some file, so we keep it.)
export LLVM=1
export CC=clang
export LD=ld.lld

# For LKM!
export KERNEL_OUT=$(pwd)/out

export ARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y
export CONFIG_WLAN_DRV_BUILD_IN=y

DATE=$(date +'%Y%m%d%H%M%S')
IMAGE="$KERNEL_OUT/arch/$ARCH/boot/Image"
RES="$(pwd)/result"

if [ -z $JOBS ]; then
	JOBS=$(nproc --all)
fi

# Build!

__mk_defconfig() {
	make -C $(pwd) --jobs $JOBS O=$KERNEL_OUT LLVM=1 CONFIG_WLAN_DRV_BUILD_IN=y CC=clang LD=ld.lld KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y $DEFCONFIG
}
__mk_kernel() {
	make -C $(pwd) --jobs $JOBS O=$KERNEL_OUT LLVM=1 CONFIG_WLAN_DRV_BUILD_IN=y CC=clang LD=ld.lld KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y
}

if [ ! -z $1 ]; then
	__mk_defconfig;
else
	mk_defconfig_kernel() {
		__mk_defconfig;
		__mk_kernel;
	}
fi

if [ -d $KERNEL_OUT ]; then
	pr_warn "An out/ folder detected, Do you wants dirty builds?"
	read -p "" OPT;
	
	if [ $OPT = 'y' ] || [ $OPT = 'Y' ]; then
		__mk_kernel;
	else
		rm -rR out;
		make clean;
		make mrproper;
		mk_defconfig_kernel;
	fi
else
	mk_defconfig_kernel;
fi

if [ -e $IMAGE ]; then
	pr_info "Build done."
else
	pr_err "Build error."
fi
