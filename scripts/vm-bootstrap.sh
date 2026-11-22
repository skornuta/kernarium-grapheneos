#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail

WORK=${WORK:-/work}
KGOS_URL=${KGOS_URL:-https://github.com/skornuta/kernarium-grapheneos.git}

[ "$(uname -m)" = x86_64 ] || { echo "error: x86_64 host required" >&2; exit 1; }

sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    repo git git-lfs python3 python-is-python3 openssh-client gnupg \
    zip unzip rsync curl tmux ccache build-essential bc bison flex \
    fontconfig fonts-dejavu-core libfreetype6 openssl libssl-dev \
    lib32z1 libncurses6 xz-utils zstd jq

mem_gib=$(awk '/MemTotal/ {print int($2/1048576)}' /proc/meminfo)
if [ "$mem_gib" -lt 60 ] && ! swapon --show | grep -q /swapfile; then
    sudo fallocate -l 32G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile >/dev/null
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

sudo mkdir -p "$WORK"
sudo chown "$(id -u):$(id -g)" "$WORK"
git lfs install --skip-repo >/dev/null

[ -d "$WORK/kernarium-grapheneos/.git" ] || git clone -q "$KGOS_URL" "$WORK/kernarium-grapheneos"
git -C "$WORK/kernarium-grapheneos" pull -q --ff-only

. "$WORK/kernarium-grapheneos/scripts/env.sh"
[ -d "$KERNARIUM/.git" ] || git clone -q --depth 1 --branch "$KERNARIUM_TAG" "$KERNARIUM_URL" "$KERNARIUM"

ccache -M 50G >/dev/null
grep -q USE_CCACHE ~/.bashrc || cat >> ~/.bashrc <<'EOF'
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
EOF

df -h "$WORK" | tail -1
echo "bootstrap ok: cpus=$(nproc) mem=${mem_gib}GiB"
