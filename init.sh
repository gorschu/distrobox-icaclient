#!/usr/bin/env bash

set -euo pipefail

echo "Detecting latest Citrix Workspace (ICA Client) version..."

# Detect latest version dynamically using JSON parsing (safer than eval)
json_output="$(python3 /tmp/detect_latest.py --json 2>&1)"
status=$?
if [[ $status -ne 0 ]]; then
    echo "Error: detect_latest.py failed with exit code $status." >&2
    echo "Output:" >&2
    echo "$json_output" >&2
    exit $status
fi

# Parse JSON output safely with jq
ICA_CLIENT_VERSION="$(echo "$json_output" | jq -r '.ICA_CLIENT_VERSION')"
ICA_CLIENT_SHASUM="$(echo "$json_output" | jq -r '.ICA_CLIENT_SHASUM')"
ICA_CLIENT_DOWNLOAD_URL="$(echo "$json_output" | jq -r '.ICA_CLIENT_DOWNLOAD_URL')"

# Validate that required environment variables are set (checking for empty or "null" from jq)
if [[ -z "${ICA_CLIENT_VERSION:-}" ]] || [[ "${ICA_CLIENT_VERSION}" == "null" ]]; then
    echo "Error: ICA_CLIENT_VERSION is not set. detect_latest.py may have failed." >&2
    exit 1
fi
if [[ -z "${ICA_CLIENT_SHASUM:-}" ]] || [[ "${ICA_CLIENT_SHASUM}" == "null" ]]; then
    echo "Error: ICA_CLIENT_SHASUM is not set. detect_latest.py may have failed." >&2
    exit 1
fi
if [[ -z "${ICA_CLIENT_DOWNLOAD_URL:-}" ]] || [[ "${ICA_CLIENT_DOWNLOAD_URL}" == "null" ]]; then
    echo "Error: ICA_CLIENT_DOWNLOAD_URL is not set. detect_latest.py may have failed." >&2
    exit 1
fi

echo "Latest version detected: ${ICA_CLIENT_VERSION}"
echo "SHA256: ${ICA_CLIENT_SHASUM}"

dest=$(mktemp --suffix .rpm)

echo "Downloading ICA Client..."
curl --connect-timeout 60 --max-time 300 -L -o "${dest}" "${ICA_CLIENT_DOWNLOAD_URL}"

echo "Verifying SHA256 checksum..."
echo "${ICA_CLIENT_SHASUM} ${dest}" | sha256sum --check --status

echo "Installing ICA Client..."
sudo dnf5 --assumeyes install "${dest}"

echo "Cleaning up..."
sudo dnf5 clean all || true
rm -f "${dest}" || true

echo "ICA Client ${ICA_CLIENT_VERSION} installed successfully!"
