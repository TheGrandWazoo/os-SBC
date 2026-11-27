#!/bin/sh
#
# Build Kamailio, rtpproxy and the runtime dependencies OPNsense does not
# ship, against OPNsense's own packages and ports tree (#5). Runs as root on
# a throwaway FreeBSD VM (the `deps` workflow), from the repository root.
#
# 1. Point pkg at OPNsense's repository for the series, with FreeBSD's
#    repositories off, and switch preinstalled packages to OPNsense builds.
# 2. Use OPNsense's ports tree and make.conf for the exact release.
# 3. Install every dependency OPNsense ships as an OPNsense binary; build
#    only the rest from source.
# 4. Package the ports plus their runtime dependencies that OPNsense lacks.
# 5. Prove it: on an empty pkg database with only OPNsense and our output as
#    repositories, `pkg install -n` must resolve every package.
#
# Output: work/deps/*.pkg and work/deps/manifest.json.

set -eu

SRC="$(pwd)"
# shellcheck source=../../deps/build.conf
. "${SRC}/deps/build.conf"
OUT="${SRC}/work/deps"
TMP="$(mktemp -d /tmp/deps.XXXXXX)"
REPOS=/usr/local/etc/pkg/repos
FP=/usr/local/etc/pkg/fingerprints/OPNsense
GH=https://raw.githubusercontent.com/opnsense

rm -rf "${SRC}/work"
mkdir -p "${OUT}" "${REPOS}" "${FP}/trusted" "${FP}/revoked"

echo ">>> pkg: OPNsense ${OPNSENSE_SERIES} repository only"
fetch -qo "${FP}/trusted/${OPNSENSE_FINGERPRINT}" \
    "${GH}/core/stable/${OPNSENSE_SERIES}/src/etc/pkg/fingerprints/OPNsense/trusted/${OPNSENSE_FINGERPRINT}"
cat > "${REPOS}/FreeBSD.conf" <<EOF
FreeBSD: { enabled: no }
FreeBSD-ports: { enabled: no }
FreeBSD-ports-kmods: { enabled: no }
FreeBSD-base: { enabled: no }
EOF
cat > "${REPOS}/OPNsense.conf" <<EOF
OPNsense: {
  url: "https://pkg.opnsense.org/\${ABI}/${OPNSENSE_SERIES}/latest",
  signature_type: "fingerprints",
  fingerprints: "${FP}",
  enabled: yes
}
EOF
pkg update -f
# Anything the VM image installed from FreeBSD is replaced by OPNsense's build
# where OPNsense has one, so nothing we compile links against FreeBSD's.
pkg upgrade -f -y || echo "note: some preinstalled packages have no OPNsense build; left as they are"
pkg install -y git
pkg rquery -a '%n' | sort -u > "${TMP}/opnsense-names"
pkg rquery -a '%o' | sort -u > "${TMP}/opnsense-origins"
echo "OPNsense repository: $(wc -l < "${TMP}/opnsense-names" | tr -d ' ') packages"

echo ">>> Ports tree and make.conf: OPNsense ${OPNSENSE_RELEASE}"
rm -rf /usr/ports
git clone -q --depth 1 -b "${OPNSENSE_RELEASE}" https://github.com/opnsense/ports.git /usr/ports
fetch -qo "${TMP}/make.conf" "${GH}/tools/${OPNSENSE_RELEASE}/config/${OPNSENSE_SERIES}/make.conf"
fetch -qo "${TMP}/build.conf" "${GH}/tools/${OPNSENSE_RELEASE}/config/${OPNSENSE_SERIES}/build.conf"
SED="-e s|%%SRCDIR%%|/usr/src|g"
for VAR in APACHE LUA PERL PHP PYTHON RUBY SSL; do
    VAL="$(sed -n "s/^${VAR}?=[[:space:]]*//p" "${TMP}/build.conf")"
    [ -n "${VAL}" ] || { echo "no ${VAR} in OPNsense build.conf"; exit 1; }
    SED="${SED} -e s|%%${VAR}%%|${VAL}|g"
done
# shellcheck disable=SC2086 # SED holds several -e arguments on purpose
sed ${SED} "${TMP}/make.conf" > /etc/make.conf
cat "${SRC}/deps/make.conf.local" >> /etc/make.conf
grep -E '^(DEFAULT_VERSIONS|net_kamailio|audio_libsndfile)' /etc/make.conf

echo ">>> Dependencies: OPNsense binaries where available"
for PORT in ${PORTS}; do
    make -C "/usr/ports/${PORT}" all-depends-list
done | sed 's|^/usr/ports/||' | sort -u > "${TMP}/all-deps"
grep -xF -f "${TMP}/opnsense-origins" "${TMP}/all-deps" > "${TMP}/from-opnsense" || true
grep -vxF -f "${TMP}/opnsense-origins" "${TMP}/all-deps" > "${TMP}/from-source" || true
echo "from OPNsense: $(tr '\n' ' ' < "${TMP}/from-opnsense")"
echo "from source:   $(tr '\n' ' ' < "${TMP}/from-source")"
if [ -s "${TMP}/from-opnsense" ]; then
    # shellcheck disable=SC2046 # one origin per word
    pkg install -y $(cat "${TMP}/from-opnsense")
fi

echo ">>> Building ${PORTS}"
for PORT in ${PORTS}; do
    make -C "/usr/ports/${PORT}" install clean
done

echo ">>> Packaging the ports and their runtime dependencies OPNsense lacks"
: > "${TMP}/host"
QUEUE=""
for PORT in ${PORTS}; do
    QUEUE="${QUEUE} $(make -C "/usr/ports/${PORT}" -V PKGBASE)"
done
SEEN=" "
while [ -n "${QUEUE# }" ]; do
    # shellcheck disable=SC2086 # split the queue into words
    set -- ${QUEUE}
    NAME="$1"; shift; QUEUE=" $*"
    case "${SEEN}" in *" ${NAME} "*) continue ;; esac
    SEEN="${SEEN}${NAME} "
    if grep -qxF "${NAME}" "${TMP}/opnsense-names"; then
        continue    # OPNsense ships it; the firewall gets it from there
    fi
    echo "${NAME}" >> "${TMP}/host"
    for DEP in $(pkg query '%dn' "${NAME}"); do
        QUEUE="${QUEUE} ${DEP}"
    done
done
for NAME in $(sort -u "${TMP}/host"); do
    pkg create -o "${OUT}" "${NAME}"
done
ls -l "${OUT}"

echo ">>> Verifying: only OPNsense plus our packages, on an empty database"
pkg repo -q "${OUT}"
mkdir -p "${TMP}/verify/repos" "${TMP}/verify/db"
cp "${REPOS}/FreeBSD.conf" "${REPOS}/OPNsense.conf" "${TMP}/verify/repos/"
cat > "${TMP}/verify/repos/KSA-deps.conf" <<EOF
KSA-deps: { url: "file://${OUT}", signature_type: "none", priority: 5, enabled: yes }
EOF
VPKG="pkg -o REPOS_DIR=${TMP}/verify/repos -o PKG_DBDIR=${TMP}/verify/db"
${VPKG} update -f -q
# shellcheck disable=SC2046
${VPKG} install -n -y $(for PORT in ${PORTS}; do make -C "/usr/ports/${PORT}" -V PKGBASE; done)
for NAME in $(sort -u "${TMP}/host"); do
    if grep -qxF "${NAME}" "${TMP}/opnsense-names"; then
        echo "FAILED: ${NAME} would shadow an OPNsense package"; exit 1
    fi
done
rm -f "${OUT}/meta" "${OUT}/meta.conf" "${OUT}/packagesite.pkg" "${OUT}/data.pkg" "${OUT}/filesite.pkg"

ABI="$(pkg query -F "$(find "${OUT}" -name '*.pkg' | head -n 1)" '%q')"
{
    printf '{"series": "%s", "abi": "%s", "opnsense_release": "%s", "packages": [' \
        "${OPNSENSE_SERIES}" "${ABI}" "${OPNSENSE_RELEASE}"
    SEP=""
    for P in $(cd "${OUT}" && find . -name '*.pkg' | sed 's|^\./||' | sort); do
        printf '%s"%s"' "${SEP}" "${P}"
        SEP=", "
    done
    printf ']}\n'
} > "${OUT}/manifest.json"
cat "${OUT}/manifest.json"
rm -rf "${TMP}"
