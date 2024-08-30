#
# Makefile for KernelSU
#

ccflags-y := -I$(srctree)/security/selinux -I$(srctree)/security/selinux/include
ccflags-y += -I$(objtree)/security/selinux -include $(srctree)/include/uapi/asm-generic/errno.h

ifeq ($(shell grep -q " current_sid(void)" $(srctree)/security/selinux/include/objsec.h; echo $$?),0)
ccflags-y += -DKSU_COMPAT_HAS_CURRENT_SID
endif

ifeq ($(shell grep -q "struct selinux_state " $(srctree)/security/selinux/include/security.h; echo $$?),0)
ccflags-y += -DKSU_COMPAT_HAS_SELINUX_STATE
endif

kernelsu-objs :=	\
	ksu.o	\
	allowlist.o	\
	apk_sign.o	\
	sucompat.o	\
	throne_tracker.o	\
	core_hook.o	\
	ksud.o	\
	embed_ksud.o	\
	kernel_compat.o	\
	selinux/rules.o	\
	selinux/selinux.o	\
	selinux/sepolicy.o

ccflags-y += -DKSU_VERSION=11479
KSU_EXPECTED_SIZE := 0x38b
KSU_EXPECTED_HASH := 98d31e655e6668f593e1deb2e17d2d2144d25f44d071fe1a98b1b6af2a785f37

$(warning KernelSU included!)
$(info -- KernelSU Manager signature size: $(KSU_EXPECTED_SIZE))
$(info -- KernelSU Manager signature hash: $(KSU_EXPECTED_HASH))

ccflags-y += -DEXPECTED_SIZE=$(KSU_EXPECTED_SIZE)
ccflags-y += -DEXPECTED_HASH=\"$(KSU_EXPECTED_HASH)\"

ifeq ($(shell grep -q "int path_umount" $(srctree)/fs/namespace.c; echo $$?),0)
ccflags-y += -DKSU_NONGKI_UMOUNT
else
$(info -- Did you know you can backport path_umount to fs/namespace.c from 5.9?)
$(info -- Read: https://kernelsu.org/guide/how-to-integrate-for-non-gki.html#how-to-backport-path-umount)
endif

ccflags-y += -Wno-implicit-function-declaration -Wno-strict-prototypes -Wno-int-conversion -Wno-gcc-compat
ccflags-y += -Wno-declaration-after-statement -Wno-unused-function

# compile it as one
obj-$(CONFIG_KSU) += kernelsu.o
