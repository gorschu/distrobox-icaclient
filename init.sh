#!/usr/bin/env bash

set -euo pipefail

echo "Detecting latest Citrix Workspace (ICA Client) version..."

# Detect latest version dynamically
eval "$(/tmp/detect_latest.py --shell)"

echo "Latest version detected: ${ICA_CLIENT_VERSION}"
echo "SHA256: ${ICA_CLIENT_SHASUM}"
echo "Download URL: ${ICA_CLIENT_DOWNLOAD_URL}"

dest=$(mktemp --suffix .rpm)

echo "Downloading ICA Client from '${ICA_CLIENT_DOWNLOAD_URL}'..."
curl -L -o "${dest}" "${ICA_CLIENT_DOWNLOAD_URL}"

echo "Verifying SHA256 checksum..."
echo "${ICA_CLIENT_SHASUM} ${dest}" | sha256sum --check --status

echo "Installing ICA Client..."
sudo dnf5 --assumeyes install "${dest}" && dnf5 clean all && rm -f "${dest}"

echo "ICA Client ${ICA_CLIENT_VERSION} installed successfully!"
