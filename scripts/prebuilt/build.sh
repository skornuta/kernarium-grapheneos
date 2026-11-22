#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
d=$(dirname "$0")
"$d/setup.sh"
"$d/fetch.sh"
"$d/unpack.sh"
"$d/patch.sh"
"$d/repack.sh"
[ "${WITH_IPA:-0}" != 1 ] || "$d/ipa.sh"
