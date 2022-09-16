#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib*/libsec-ril*.so)
            "${PATCHELF}" --replace-needed libril.so libril-samsung.so "${2}"
            ;;
        vendor/lib/hw/audio.primary.exynos9825.so)
            "${PATCHELF}" --remove-needed libaudio_soundtrigger.so "${2}"
            "${PATCHELF}" --add-needed libshim_audioparams.so "${2}"
            sed -i 's/str_parms_get_str/str_parms_get_mod/g' "${2}"
            ;;
        vendor/lib64/libexynoscamera3.so)
            xxd -p "${2}" | sed "s/8b022036/1f2003d5/g" | xxd -r -p > "${2}".patched
            mv "${2}".patched "${2}"
            ;;
        vendor/lib*/libexynosdisplay.so|vendor/lib*/hw/hwcomposer.exynos9820.so|vendor/lib*/sensors.*.so)
            "${PATCHELF}" --replace-needed libutils.so libutils-v32.so "${2}"
            ;;
        vendor/lib64/libiu456_datapath_processor.so)
            "${PATCHELF}" --add-needed libshim_sfpex.so "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=d2x
export DEVICE_COMMON=exynos9820-common
export VENDOR=samsung

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
