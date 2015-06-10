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
BONE_STOCK                  ?=

# strip extraneous code during linking
EXODUS_LD_FLAGS := \
# -Wl,--as-needed -Wl,--relax -Wl,-S -Wl,--gc-sections -Wl,-s

ifeq ($(BONE_STOCK),true)
  NO_DEBUG_SYMBOL_FLAGS   :=
  NO_DEBUG_FRAME_POINTERS :=
endif

# DEBUGGING OPTIONS
ifeq ($(NO_DEBUG_SYMBOL_FLAGS),true)
  DEBUG_SYMBOL_FLAGS := -g0 -DNDEBUG
endif
ifeq ($(NO_DEBUG_FRAME_POINTERS),true)
  DEBUG_FRAME_POINTER_FLAGS := -fomit-frame-pointer
endif

EXODUS_GLOBAL_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_RELEASE_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_CLANG_TARGET_GLOBAL_CFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
EXODUS_GLOBAL_CPPFLAGS += $(DEBUG_SYMBOL_FLAGS) $(DEBUG_FRAME_POINTER_FLAGS)
