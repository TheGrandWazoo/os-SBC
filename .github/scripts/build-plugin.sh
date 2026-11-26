#!/bin/sh
#
# Lint and package os-sbc inside an opnsense/plugins tree, the way upstream
# builds its own plugins (ADR-SBC-0007). Runs on FreeBSD (CI: the `build`
# job's VM). Output: work/pkg/*.pkg in the repository root.
#
#   OPNSENSE_SERIES  opnsense/core and opnsense/plugins branch suffix (default 26.7)

set -eu

SERIES="${OPNSENSE_SERIES:-26.7}"
SRC="$(pwd)"
WORK="${SRC}/work"
PLUGIN="${WORK}/plugins/net/sbc"

rm -rf "${WORK}"
mkdir -p "${WORK}/pkg"

echo ">>> Fetching opnsense/core and opnsense/plugins stable/${SERIES}"
git clone -q --depth 1 -b "stable/${SERIES}" https://github.com/opnsense/core.git "${WORK}/core"
git clone -q --depth 1 -b "stable/${SERIES}" https://github.com/opnsense/plugins.git "${WORK}/plugins"

echo ">>> Placing os-sbc at net/sbc"
mkdir -p "${PLUGIN}"
cp -R "${SRC}/Makefile" "${SRC}/pkg-descr" "${SRC}/src" "${PLUGIN}/"
# Upstream's lint uses `git grep`, which only sees files in the index.
(cd "${WORK}/plugins" && git add net/sbc)

echo ">>> make lint (opnsense/plugins + core rules)"
make -C "${PLUGIN}" lint

echo ">>> make package"
make -C "${PLUGIN}" package

find "${PLUGIN}" -name '*.pkg' -exec cp {} "${WORK}/pkg/" \;
ls -l "${WORK}/pkg"
for p in "${WORK}"/pkg/*.pkg; do
    pkg info -F "${p}"
done
