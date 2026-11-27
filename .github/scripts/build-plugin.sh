#!/bin/sh
#
# Lint and package os-sbc inside an opnsense/plugins tree, the way upstream
# builds its own plugins (ADR-SBC-0007). Runs on FreeBSD (CI: the `build`
# job's VM). Output: work/pkg/*.pkg in the repository root.
#
#   OPNSENSE_SERIES  opnsense/core and opnsense/plugins branch suffix (default 26.7)
#   PLUGIN_REVISION  appended as _N to the package version when set (CI sets the
#                    run number for non-tag builds, so each devel build upgrades)
#   STRICT_LINT      1 (default): any problem `make lint` prints fails the build.
#                    0: report them as a warning only (until #11 removes the
#                    2019 Asterisk model, which upstream's model rules reject).

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
# Package script additions (+POST_INSTALL.post and friends), see plugins.mk.
for EXTRA in "${SRC}"/+*.post; do
    [ -e "${EXTRA}" ] && cp "${EXTRA}" "${PLUGIN}/"
done
# Upstream's lint uses `git grep`, which only sees files in the index.
(cd "${WORK}/plugins" && git add net/sbc)

echo ">>> make lint (opnsense/plugins + core rules)"
# Upstream's model checks print problems but still exit 0, so judge by output.
# Lines that are progress or tool chatter, not problems: lint-exec's
# `xargs -t` traces, parallel-lint's banner and summary, make's notices
# about optional build variables.
LINT_OUT="${WORK}/lint.txt"
make -C "${PLUGIN}" lint > "${LINT_OUT}" 2>&1 || { cat "${LINT_OUT}"; exit 1; }
cat "${LINT_OUT}"
PROBLEMS=$(grep -v -E \
    -e '^test -x ' \
    -e '^[[:space:]]*$' \
    -e '^PHP [0-9.]+ \| [0-9]+ parallel jobs$' \
    -e '^[.]+ +[0-9]+/[0-9]+ \(100 %\)$' \
    -e '^Checked [0-9]+ files? in ' \
    -e '^No syntax error found$' \
    -e 'warning: Cannot build without PLUGIN_(PHP|PYTHON) set' \
    "${LINT_OUT}" | wc -l | tr -d ' ')
if [ "${PROBLEMS}" -gt 0 ]; then
    if [ "${STRICT_LINT:-1}" = "1" ]; then
        echo ">>> make lint reported ${PROBLEMS} problem(s)"
        exit 1
    fi
    echo "::warning::make lint reported ${PROBLEMS} problem(s); this becomes blocking with #11"
fi

echo ">>> make package"
if [ -n "${PLUGIN_REVISION:-}" ]; then
    make -C "${PLUGIN}" package PLUGIN_REVISION="${PLUGIN_REVISION}"
else
    make -C "${PLUGIN}" package
fi

find "${PLUGIN}" -name '*.pkg' -exec cp {} "${WORK}/pkg/" \;
ls -l "${WORK}/pkg"
for p in "${WORK}"/pkg/*.pkg; do
    pkg info -F "${p}"
done

# manifest.json tells the KSA package repository (TheGrandWazoo/opnsense-repo)
# which OPNsense series and ABI these packages were built for.
ABI="$(pkg query -F "$(ls "${WORK}"/pkg/*.pkg | head -n 1)" '%q')"
{
    printf '{"series": "%s", "abi": "%s", "packages": [' "${SERIES}" "${ABI}"
    SEP=""
    for p in "${WORK}"/pkg/*.pkg; do
        printf '%s"%s"' "${SEP}" "$(basename "${p}")"
        SEP=", "
    done
    printf ']}\n'
} > "${WORK}/pkg/manifest.json"
cat "${WORK}/pkg/manifest.json"
