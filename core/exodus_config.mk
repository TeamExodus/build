#
# Copyright (C) 2014 VanirAOSP && The Android Open Source Project
# Copyright (C) 2015 Exodus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#  This config sets up an interface for toggling various build configurations
#  that can be set and respected in device tree overlays.  All options should
#  default off if unset.  The vanir_config.mk is included in:
#    $(BUILD_SYSTEM)/config.mk

# current build configurations:
# BONE_STOCK := set true to override all vanir_config variables
# NO_DEBUG_FRAME_POINTERS := set true to add frame pointers
# NO_DEBUG_SYMBOL_FLAGS := true removes debugging code insertions from assert.h macros and GDB
# MAXIMUM_OVERDRIVE := true disables address sanitizer, in core/clang/config.mk
# USE_GRAPHITE := true adds graphite cflags to turn on graphite
# USE_FSTRICT_FLAGS := true builds with fstrict-aliasing (thumb and arm)
# USE_BINARY_FLAGS := true adds experimental binary flags that can be set here or in device trees
# USE_EXTRA_CLANG_FLAGS := true allows additional flags to be passed to the Clang compiler
# EXODUS_BIONIC_OPTIMIZATIONS := true switches to Nvidia routines in libm and dlmalloc in libc
# ADDITIONAL_TARGET_ARM_OPT := Additional flags may be appended here for GCC-specific modules
# ADDITIONAL_TARGET_THUMB_OPT := Additional flags may be appended here for GCC-specific modules
# VANIR_ARM_OPT_LEVEL := -Ox for TARGET_arm_CFLAGS, preserved in binary.mk
# VANIR_THUMB_OPT_LEVEL := -Ox for TARGET_thumb_CFLAGS, preserved in binary.mk
# FSTRICT_ALIASING_WARNING_LEVEL := 0-3 for the level of intensity the compiler checks for violations
# USE_LTO := true builds locally in modules with the -flto flags set in this config file
# USE_FDO_OPTIMIZATION := true to use feedback directed optimization on locally enabled modules

# SET GLOBAL CONFIGURATION HERE:
MAXIMUM_OVERDRIVE           ?= true
NO_DEBUG_SYMBOL_FLAGS       ?= true
NO_DEBUG_FRAME_POINTERS     ?= true
USE_GRAPHITE                ?=
USE_LTO                     ?= true
USE_FSTRICT_FLAGS           ?= true
USE_BINARY_FLAGS            ?=
USE_EXTRA_CLANG_FLAGS       ?=
USE_FDO_OPTIMIZATION        ?=
EXODUS_BIONIC_OPTIMIZATIONS ?= true
ADDITIONAL_TARGET_ARM_OPT   ?=
ADDITIONAL_TARGET_THUMB_OPT ?=

# Set some defaults
VANIR_ARM_OPT_LEVEL         ?= -O2
VANIR_THUMB_OPT_LEVEL       ?= -Os
FSTRICT_ALIASING_WARNING_LEVEL ?= 2

# Respect BONE_STOCK: strictly enforce AOSP defaults.
ifeq ($(BONE_STOCK),true)
  MAXIUMUM_OVERDRIVE      :=
  NO_DEBUG_SYMBOL_FLAGS   :=
  NO_DEBUG_FRAME_POINTERS :=
  USE_GRAPHITE            :=
  USE_LTO                 :=
  USE_FSTRICT_FLAGS       :=
  USE_BINARY_FLAGS        :=
  USE_EXTRA_CLANG_FLAGS   :=
  USE_FDO_OPTIMIZATION    :=
  EXODUS_BIONIC_OPTIMIZATIONS :=
  VANIR_ARM_OPT_LEVEL     := -O2
  VANIR_THUMB_OPT_LEVEL   := -Os
  FSTRICT_ALIASING_WARNING_LEVEL := 2
  ADDITIONAL_TARGET_ARM_OPT   :=
  ADDITIONAL_TARGET_THUMB_OPT :=
endif

# DEBUGGING OPTIONS
ifeq ($(NO_DEBUG_SYMBOL_FLAGS),true)
  DEBUG_SYMBOL_FLAGS := -g0 -DNDEBUG
endif
ifeq ($(NO_DEBUG_FRAME_POINTERS),true)
  DEBUG_FRAME_POINTER_FLAGS := -fomit-frame-pointer
endif

# GRAPHITE
ifeq ($(USE_GRAPHITE),true)
  GRAPHITE_FLAGS := \
          -fgraphite             \
          -floop-flatten         \
          -floop-parallelize-all \
          -ftree-loop-linear     \
          -floop-interchange     \
          -floop-strip-mine      \
          -floop-block
endif

# Assign modules to build with link time optimizations using VANIR_LTO_MODULES.
ifeq ($(USE_LTO),true)
  EXODUS_LTO_FLAGS := \
    -Wl,-flto \
    -Wl,-fuse-linker-plugin \
    -Wl,-flto-report
endif

# profile-directed optimization
ifeq ($(USE_FDO_OPTIMIZATION),true)
  EXODUS_FDO_MODULES :=
  EXODUS_FDO_BLACKLIST := \
    libwebviewchromium \
    third_party_WebKit_Source_wtf_wtf_gyp \
    v8_tools_gyp_v8_base_gyp \
    v8_tools_gyp_v8_base_arm_host_gyp \
    third_party_sqlite_sqlite_gyp \
    third_party_qcms_qcms_gyp \
    third_party_ots_ots_gyp \
    base_base_i18n_gyp \
    v8_tools_gyp_v8_libbase_gyp \
    v8_tools_gyp_v8_snapshot_gyp \
    skia_skia_library_gyp \
    skia_skia_opts_gyp \
    skia_skia_opts_neon_gyp \
    skia_skia_chrome_gyp
    
endif

# fstrict-aliasing. Thumb is defaulted off for AOSP. Use VANIR_SPECIAL_CASE_MODULES to
# temporarily disable fstrict-aliasing locally in modules we dont care about or until the
# error it contains is properly fixed.
#
# Style points will be assessed for tagging modules with their path for future fixing
ifeq ($(USE_FSTRICT_FLAGS),true)
  EXODUS_FNO_STRICT_ALIASING_MODULES := \
    audio.primary.msm8960 \
    audio.primary.msm8974 \
    audio_policy.msm8610 \
    bluetooth.default \
    busybox \
    camera.msm8084 \
    content_content_renderer_gyp \
    gatt_testtool \
    libdiskconfig \
    libft2 \
    libfusetwrp \
    libguitwrp \
    libjni_filtershow_filters \
    libjni_jpegstream \
    libjni_jpegutil \
    libldnhncr \
    libmusicbundle \
    libnfc-nci \
    libnvvisualizer \
    libOMX.Exynos.VP8.Decoder \
    libqcomvisualizer \
    libreverb \
    librtp_jni \
    libssh \
    libstagefright_soft_h264dec \
    libtwrpmtp \
    libuclibcrpc \
    libvisualizer \
    libwebviewchromium \
    libwebviewchromium_loader \
    libwebviewchromium_plat_support \
    libziparchive-host \
    libziparchive \
    logd \
    mdnsd \
    mm-vdec-omx-test \
    net_net_gyp \
    sensors.$(TARGET_BOOTLOADER_BOARD_NAME) \
    ssh \
    static_busybox \
    third_party_angle_src_translator_lib_gyp \
    third_party_WebKit_Source_core_webcore_generated_gyp \
    third_party_WebKit_Source_core_webcore_remaining_gyp \
    third_party_WebKit_Source_modules_modules_gyp \
    third_party_WebKit_Source_platform_blink_platform_gyp

# external/ffmpeg
  EXODUS_FNO_STRICT_ALIASING_MODULES += \
    libavcodec \
    libavformat \
    libavutil \
    libswscale

  FSTRICT_FLAGS := \
          -fstrict-aliasing \
          -Wstrict-aliasing=$(FSTRICT_ALIASING_WARNING_LEVEL) \
          -Werror=strict-aliasing
endif

# Additional GCC-specific arm cflags
ifeq ($(ADDITIONAL_TARGET_ARM_OPT),true)
    VANIR_TARGET_ARM_FLAGS := \
        -ftree-vectorize \
        -funsafe-loop-optimizations
endif

# Additional GCC-specific thumb cflags
ifeq ($(ADDITIONAL_TARGET_THUMB_OPT),true)
    VANIR_TARGET_THUMB_FLAGS := \
        -funsafe-math-optimizations
endif

# Additional clang-specific cflags
ifeq ($(USE_EXTRA_CLANG_FLAGS),true)
    VANIR_CLANG_CONFIG_EXTRA_ASFLAGS :=
    VANIR_CLANG_CONFIG_EXTRA_CFLAGS :=
    VANIR_CLANG_CONFIG_EXTRA_CPPFLAGS :=
    VANIR_CLANG_CONFIG_EXTRA_LDFLAGS :=
endif

#======================================================================================================
# variables as exported to other makefiles ============================================================
EXODUS_FSTRICT_OPTIONS := $(FSTRICT_FLAGS)

VANIR_GLOBAL_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
VANIR_RELEASE_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
VANIR_CLANG_TARGET_GLOBAL_CFLAGS += $(EXODUS_FSTRICT_OPTIONS) $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
VANIR_GLOBAL_CPPFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)

# set experimental/unsupported flags here for persistance and try to override local options that
# may be set after release flags.  This option should not be used to set flags globally that are
# intended for release but to test outcomes.  For example: setting -O3 here will have a higher
# likelyhood of overriding the stock and local flags.
ifdef ($(USE_BINARY_FLAGS),true)
VANIR_BINARY_CFLAG_OPTIONS := $(GRAPHITE_FLAGS)
VANIR_BINARY_CPP_OPTIONS := $(GRAPHITE_FLAGS)
VANIR_LINKER_OPTIONS :=
VANIR_ASSEMBLER_OPTIONS :=
endif
