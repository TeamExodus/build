ifeq ($(TARGET_KERNEL_CONFIG_SET),) # set defaults first time included, if not set already (presumably by make commandline args or environment)
    ifeq ($(TARGET_KERNEL_USE_AOSP_TOOLCHAIN),)
        TARGET_KERNEL_USE_AOSP_TOOLCHAIN := true
    endif
    ifeq ($(TARGET_KERNEL_TOOLCHAIN_VERSION),)
        TARGET_KERNEL_TOOLCHAIN_VERSION :=
    endif
    TARGET_KERNEL_CONFIG_SET := true
else # after target stuff set, set real values
    ifeq ($(HOST_OS),darwin)
        TARGET_KERNEL_USE_AOSP_TOOLCHAIN := true
    endif
    ifneq ($(strip $(BONE_STOCK)),)
        TARGET_KERNEL_USE_AOSP_TOOLCHAIN := true
    endif
    ifeq ($(USE_AOSP_TOOLCHAINS),true)
        TARGET_KERNEL_USE_AOSP_TOOLCHAIN := true
    endif

    # IFF not using AOSP toolchain
    ifneq ($(TARGET_KERNEL_USE_AOSP_TOOLCHAIN),true)
        # and TARGET_KERNEL_TOOLCHAIN_VERSION is prefixed with linaro-
        ifneq ($(findstring linaro-,$(TARGET_KERNEL_TOOLCHAIN_VERSION)),)
            # figure out cpu variant to use the specific toolchain for
            ifeq ($(TARGET_KERNEL_CPU_VARIANT),)
                ifeq ($(TARGET_CPU_VARIANT),krait)
                    TARGET_KERNEL_CPU_VARIANT := cortex-a15
                else
                    ifeq ($(wildcard $(ANDROID_BUILD_TOP)/prebuilts/gcc/linux-x86/arm/linaro/$(T_K_C_T)-$(TARGET_CPU_VARIANT)),)
                        # no specific toolchain folder exists, use generic
                        TARGET_KERNEL_CPU_VARIANT := generic
                        $(warn Could not find specific $(TARGET_KERNEL_TOOLCHAIN_VERSION) toolchain for $(TARGET_CPU_VARIANT))
                    else
                        TARGET_KERNEL_CPU_VARIANT := $(TARGET_CPU_VARIANT)
                    endif
                endif
            endif
            T_K_C_T_STRIPPER := $(shell echo $(TARGET_KERNEL_TOOLCHAIN_VERSION) | sed -e 's/[a-z]//g')
            T_K_C_T_DASHER := $(shell echo $(T_K_C_T_STRIPPER) | sed -e 's/-//g')
            T_K_C_T := linaro-$(T_K_C_T_DASHER)

            # prefix auto-determination. hollah for a dollah.
            POSSIBLE_TOOLCHAIN_PREFIXES := arm-eabi- arm-gnueabi- arm-gnueabihf-

            KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/linux-x86/arm/linaro/$(T_K_C_T)-$(TARGET_KERNEL_CPU_VARIANT)/bin
            KERNEL_TOOLCHAIN_PREFIX := $(notdir $(patsubst %-gcc,%-,$(firstword $(foreach var, $(POSSIBLE_TOOLCHAIN_PREFIXES), $(wildcard $(KERNEL_TOOLCHAIN)/$(var)gcc)))))
        endif
    endif
endif
