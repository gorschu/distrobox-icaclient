#!/usr/bin/env bash

set -euo pipefail

url='https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html'

_dl_url_="$(curl -sL "$url" | grep -F ".rpm?__gda__")"
_dl_url="$(echo "$_dl_url_" | grep -F "${ICA_CLIENT_VERSION}.x86_64.rpm?__gda__")"
_source=https:"$(echo "$_dl_url" | sed -En 's|^.*rel="(//.*/ICAClient-rhel-[^"]*)".*$|\1|p')"

dest=$(mktemp --suffix .rpm)

echo "Downloading and installing icaclient from '${_source}'..."
curl -L -o "${dest}" "${_source}"
echo "${ICA_CLIENT_SHASUM} ${dest}" | sha256sum --check --status

sudo dnf5 --assumeyes install "${dest}" && dnf5 clean all && rm -f "${dest}"
