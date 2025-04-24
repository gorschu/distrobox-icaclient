#!/bin/bash

set -euo pipefail

url='https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html'
pkgver=25.03.0.66-0
sha256sum=bf1588ad5074e707a081042cb79ad363c185eda317759da4707abb719f429c61

_dl_url_="$(curl -sL "$url" | grep -F ".rpm?__gda__")"
_dl_url="$(echo "$_dl_url_" | grep -F "$pkgver.x86_64.rpm?__gda__")"
_source=https:"$(echo "$_dl_url" | sed -En 's|^.*rel="(//.*/ICAClient-rhel-[^"]*)".*$|\1|p')"

dest=$(mktemp --suffix .rpm)

curl -LsS -o "${dest}" "${_source}"
echo "${sha256sum} ${dest}" | sha256sum --check --status

sudo dnf5 --assumeyes install "${dest}" && dnf5 clean all && rm -f "${dest}"
