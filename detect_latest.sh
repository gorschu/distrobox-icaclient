#!/usr/bin/env bash

set -euo pipefail

webpage_url='https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html'

# fetch page
html=$(curl -fsSL "$webpage_url")

# Extract the RPM download URL from the "RedHat" section
# Note: use \x27 instead of a literal single-quote inside the single-quoted
# bash string so the shell doesn't get confused.
rpm_url=$(printf '%s' "$html" | \
  perl -0777 -ne '
    if (m/
         Red[- ]?Hat\s+Full\s+Package  # find the Red Hat block
         [\s\S]{0,1200}?               # look ahead in the section
         rel=\s*([\"\x27])             # rel= followed by single or double quote
         (\/\/downloads\.citrix\.com\/[^"\x27\s]+?\.rpm[^"\x27\s]*)  # the RPM URL
         \1
        /ix)
    {
      print "https:$2";  # Add https in front of //downloads
    }
  ' | head -n1)

# Extract the SHA-256 from the same "RedHat" section
sha256=$(printf '%s' "$html" | \
  perl -0777 -ne '
    if (m/(Red[- ]?Hat\s+Full\s+Package[\s\S]{0,1000}?SHA-256\s*[-:]\s*([a-f0-9]{64}))/i) {
      print $2;
    }
  ' | head -n1)

# If either is empty, fail with error message
if [ -z "${rpm_url:-}" ] || [ -z "${sha256:-}" ]; then
  printf '%s\n' "ERROR: could not extract Red Hat RPM URL and/or SHA256 from $webpage_url" >&2
  printf '%s\n' "Found rpm_url: '${rpm_url:-}'" >&2
  printf '%s\n' "Found sha256:  '${sha256:-}'" >&2
  exit 2
fi

rpm_version=$(echo $rpm_url | sed -nE 's#.*/ICAClient-rhel-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+)\.x86_64\.rpm.*#\1#p')

echo "Version: $rpm_version"
echo "Hash: $sha256"

sed -i 's/ICA_CLIENT_VERSION := ".*"/ICA_CLIENT_VERSION := "'${rpm_version}'"/g' ./justfile 
sed -i 's/ICA_CLIENT_SHASUM := ".*"/ICA_CLIENT_SHASUM := "'${sha256}'"/g' ./justfile 
