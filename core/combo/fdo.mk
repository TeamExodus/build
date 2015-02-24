#
# Copyright (C) 2015 Exodus && The Android Open Source Project
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
#

# Setup FDO related flags.
$(combo_2nd_arch_prefix)TARGET_FDO_CFLAGS:=

# Reset profiling database at the first of each month to ensure we stay accurate
ifneq ($(wildcard $(DEVICE_PROFILE)),)
  CURRENT_DATE := $(shell date '+%d')
  RESET_DATE := 01
  ifeq ($(CURRENT_DATE),$(RESET_DATE))
    $(info "=========================================================================")
    $(info "=======================RESETTING PROFILING DATA!=========================")
    $(info "=========================================================================")
    $(shell @echo rm -rf /.exodus_profiles)
  endif
endif

# EXODUS's FDO implementation
ifeq ($(USE_FDO_OPTIMIZATION),true)
  DEVICE_PROFILE := /.exodus_profiles/$(PRODUCT_OUT)/$(TARGET_$(combo_2nd_arch_prefix)ARCH)/$(TARGET_$(combo_2nd_arch_prefix)ARCH_VARIANT)/profile_tests

  # Available optimizations
  SAMPLE_PROFILING_FLAGS := \
      -fbranch-probabilities \
      -fvpt \
      -funroll-loops \
      -fpeel-loops \
      -ftracer \
      -ftree-vectorize \
      -finline-functions \
      -fipa-cp \
      -fipa-cp-clone \
      -fpredictive-commoning \
      -funswitch-loops \
      -fgcse-after-reload \
      -ftree-loop-distribute-patterns \
      -fprofile-correction \
      -DANDROID_FDO \
      -Wcoverage-mismatch \
      -Wno-error

  ifeq ($(wildcard $(DEVICE_PROFILE)),)
    # Generate FDO instrumentation for the target device
    $(combo_2nd_arch_prefix)TARGET_FDO_CFLAGS := -fprofile-generate=$(DEVICE_PROFILE) -DANDROID_FDO
    $(combo_2nd_arch_prefix)TARGET_FDO_LDFLAGS := -lgcov -lgcc
  else
    # Compile with profile-guided optimizations
    $(combo_2nd_arch_prefix)TARGET_FDO_CFLAGS := \
        -fprofile-use=$(DEVICE_PROFILE) \
        $(SAMPLE_PROFILING_FLAGS)
  endif
else
  # Clean up profiles we've generated now that FDO is off
  ifneq ($(wildcard $(DEVICE_PROFILE)),)
    $(shell @echo rm -rf /.exodus_profiles)
  endif

  # Begin AOSP's FDO implementation.  This can only be used when USE_FDO_OPTIMIZATION is not set/false.
  ifeq ($(strip $(BUILD_FDO_INSTRUMENT)), true)
    # Set BUILD_FDO_INSTRUMENT=true to turn on FDO instrumentation.
    # The profile will be generated on /sdcard/fdo_profile on the device.
    $(combo_2nd_arch_prefix)TARGET_FDO_CFLAGS := -fprofile-generate=/sdcard/fdo_profile -DANDROID_FDO
    $(combo_2nd_arch_prefix)TARGET_FDO_LDFLAGS := -lgcov -lgcc
  else
    ifeq ($(strip $(BUILD_FDO_OPTIMIZE)), true)
      # Set TARGET_FDO_PROFILE_PATH to set a custom profile directory for your build.
      ifeq ($(strip $($(combo_2nd_arch_prefix)TARGET_FDO_PROFILE_PATH)),)
        $(combo_2nd_arch_prefix)TARGET_FDO_PROFILE_PATH := vendor/google_data/fdo_profile
      endif

      ifneq ($(strip $(wildcard $($(combo_2nd_arch_prefix)TARGET_FDO_PROFILE_PATH)/$(PRODUCT_OUT))),)
        $(combo_2nd_arch_prefix)TARGET_FDO_CFLAGS := -fprofile-use=$($(combo_2nd_arch_prefix)TARGET_FDO_PROFILE_PATH) -DANDROID_FDO -fprofile-correction -Wcoverage-mismatch -Wno-error
      else
        $(warning Profile directory $($(combo_2nd_arch_prefix)TARGET_FDO_PROFILE_PATH)/$(PRODUCT_OUT) does not exist. Turn off FDO.)
      endif
    endif
  endif
endif
