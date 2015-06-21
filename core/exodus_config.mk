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
#  default off if unset.  The exodus_config.mk is included in:
#    $(BUILD_SYSTEM)/config.mk

# SET GLOBAL CONFIGURATION HERE:
NO_DEBUG_SYMBOL_FLAGS       ?= true
NO_DEBUG_FRAME_POINTERS     ?= true
USE_FSTRICT_FLAGS           ?= true
BONE_STOCK                  ?=

# strip extraneous code during linking
EXODUS_LD_FLAGS := \
# -Wl,--as-needed -Wl,--relax -Wl,-S -Wl,--gc-sections -Wl,-s

ifeq ($(BONE_STOCK),true)
  NO_DEBUG_SYMBOL_FLAGS   :=
  NO_DEBUG_FRAME_POINTERS :=
  USE_FSTRICT_FLAGS       := false
endif

# DEBUGGING OPTIONS
ifeq ($(NO_DEBUG_SYMBOL_FLAGS),true)
  DEBUG_SYMBOL_FLAGS := -g0 -DNDEBUG
endif
ifeq ($(NO_DEBUG_FRAME_POINTERS),true)
  DEBUG_FRAME_POINTER_FLAGS := -fomit-frame-pointer
endif

# fstrict-aliasing. Thumb is defaulted off for AOSP. Use VANIR_SPECIAL_CASE_MODULES to
# temporarily disable fstrict-aliasing locally in modules we dont care about or until the
# error it contains is properly fixed.
#
# Style points will be assessed for tagging modules with their path for future fixing
ifeq ($(USE_FSTRICT_FLAGS),true)
  EXODUS_FNO_STRICT_ALIASING_MODULES := \
          libc_bionic \
          libc_dns \
          libstlport_static \
          libdiskconfig \
          libcrypto_static \
          libstlport \
          libandroid_runtime \
          libziparchive \
          libandroidfw \
          libft2 \
          libsonivox \
          libmedia \
          libjni_jpegstream \
          libnfc-nci \
          libcurl \
          clatd \
          dnsmasq \
          libstagefright_webm \
          libaudioflinger \
          libmediaplayerservice \
          libstagefright \
          ping \
          ping6 \
          libvariablespeed \
          libjavacore \
          libwilhelm \
          libdownmix \
          lsof \
          tcpdump

  EXODUS_FNO_STRICT_ALIASING_MODULES += \
      audio.primary.msm8960 \
    audio.primary.msm8974 \
    audio_policy.msm8610 \
    bluetooth.default \
    busybox \
    camera.msm8084 \
    content_content_renderer_gyp \
    gatt_testtool \
    libfusetwrp \
    libguitwrp \
    libjni_filtershow_filters \
    libjni_jpegutil \
    libldnhncr \
    libmusicbundle \
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

  EXODUS_FSTRICT_OPTIONS := \
          -fstrict-aliasing \
          -Wstrict-aliasing \
          -Werror=strict-aliasing
endif

EXODUS_GLOBAL_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_RELEASE_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_CLANG_TARGET_GLOBAL_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_GLOBAL_CPPFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
