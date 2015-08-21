arch_variant_cflags :=

ifeq ($(TARGET_CPU_CORTEX_A53),true)
linker_workaround_flags := -Wl,--fix-cortex-a53-843419 \
                        -Wl,--fix-cortex-a53-835769

arch_variant_ldflags := $(call cc-option,$(linker_workaround_flags))

endif