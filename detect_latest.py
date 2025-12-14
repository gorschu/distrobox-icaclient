#!/usr/bin/env python3
"""
Detect the latest Citrix Workspace (ICA Client) version and SHA256 for Red Hat.

This script scrapes the Citrix downloads page to find the latest Red Hat RPM package,
extracting the version, SHA256 checksum, and full download URL with all required parameters.
"""

import sys
import re
import json
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup


def fetch_citrix_page(url):
    """Fetch the Citrix downloads page."""
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    req = Request(url, headers=headers)
    with urlopen(req, timeout=60) as response:
        return response.read().decode("utf-8")


def find_redhat_section(soup):
    """
    Find the HTML section containing Red Hat package information.

    Strategy: Look for text containing "Red Hat" and "Full Package",
    then traverse up the parent chain to find a container that has both
    the download link and SHA256 checksum.
    """
    # Find all text elements containing "Red Hat"
    for element in soup.find_all(string=re.compile(r"Red\s*[-]?\s*Hat", re.IGNORECASE)):
        # Check if "Full Package" is nearby (within parent or siblings)
        parent = element.find_parent()
        if parent:
            parent_text = parent.get_text()
            if re.search(r"Full\s+Package", parent_text, re.IGNORECASE):
                # Traverse up the parent chain, checking at each level if the container
                # contains both a Red Hat RPM download link and a SHA256 checksum.
                container = parent
                max_levels = 5  # Avoid infinite loops
                for _ in range(max_levels):
                    # Check for download link pattern and SHA256 pattern
                    has_download = container.find(
                        "a", rel=re.compile(r"ICAClient-rhel-.*\.rpm")
                    )
                    has_sha256 = re.search(
                        r"SHA-256\s*[-:]\s*[a-fA-F0-9]{64}",
                        container.get_text(),
                        re.IGNORECASE,
                    )
                    if has_download and has_sha256:
                        return container
                    if container.parent:
                        container = container.parent
                    else:
                        break
    return None


def extract_download_url(section):
    """
    Extract the RPM download URL from the Red Hat section.

    Looks for <a> tags with 'rel' attribute containing the Citrix downloads URL.
    The rel attribute contains the full download URL with query parameters.
    """
    if not section:
        return None, None

    # Find all links with rel attribute
    for link in section.find_all("a", rel=True):
        rel_value = link.get("rel")

        # rel can be a list or string
        if isinstance(rel_value, list):
            rel_value = " ".join(rel_value)

        # Check if this is the Red Hat RPM download link
        if "ICAClient-rhel-" in rel_value and ".rpm" in rel_value:
            # Extract version from the URL
            version_match = re.search(
                r"ICAClient-rhel-([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+)\.x86_64\.rpm",
                rel_value,
            )

            if version_match:
                version = version_match.group(1)

                # Construct full URL - keep ALL parameters (like ?__gda__=...)
                if rel_value.startswith("//"):
                    download_url = "https:" + rel_value
                elif rel_value.startswith("http"):
                    download_url = rel_value
                else:
                    download_url = "https://" + rel_value

                # Ensure the download_url uses HTTPS for security
                if not download_url.startswith("https://"):
                    return None, None

                return version, download_url

    return None, None


def extract_sha256(section):
    """
    Extract SHA-256 checksum from the Red Hat section.

    Looks for text pattern "SHA-256" followed by a 64-character hex string.
    """
    if not section:
        return None

    section_text = section.get_text()

    # Look for SHA-256 followed by the hash (case-insensitive hex)
    sha_match = re.search(
        r"SHA-256\s*[-:]\s*([a-fA-F0-9]{64})", section_text, re.IGNORECASE
    )

    if sha_match:
        return sha_match.group(1).lower()

    return None


def extract_redhat_info(html):
    """
    Extract Red Hat RPM information from Citrix downloads page.

    Returns tuple: (version, sha256, download_url)

    Uses BeautifulSoup to navigate the DOM structure and find the Red Hat section,
    then extracts the download URL with all query parameters and the SHA256 checksum.
    """
    soup = BeautifulSoup(html, "html.parser")

    # Find the section containing Red Hat package info
    redhat_section = find_redhat_section(soup)

    if not redhat_section:
        return None, None, None

    # Extract download URL and version
    version, download_url = extract_download_url(redhat_section)

    if not version or not download_url:
        return None, None, None

    # Extract SHA256
    sha256 = extract_sha256(redhat_section)

    return version, sha256, download_url


def main():
    """Main function to detect and output version information."""
    url = "https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html"

    try:
        html = fetch_citrix_page(url)
        version, sha256, download_url = extract_redhat_info(html)

        if not version or not sha256 or not download_url:
            print(
                f"ERROR: Could not extract Red Hat RPM information from {url}",
                file=sys.stderr,
            )
            print(f"Found version: {version or 'N/A'}", file=sys.stderr)
            print(f"Found sha256: {sha256 or 'N/A'}", file=sys.stderr)
            print(f"Found download_url: {download_url or 'N/A'}", file=sys.stderr)
            sys.exit(1)

        # Determine output format
        output_format = sys.argv[1] if len(sys.argv) > 1 else "default"

        if output_format == "--json":
            print(
                json.dumps(
                    {
                        "ICA_CLIENT_VERSION": version,
                        "ICA_CLIENT_SHASUM": sha256,
                        "ICA_CLIENT_DOWNLOAD_URL": download_url,
                    },
                    indent=2,
                )
            )
        elif output_format == "--shell":
            print(f'export ICA_CLIENT_VERSION="{version}"')
            print(f'export ICA_CLIENT_SHASUM="{sha256}"')
            print(f'export ICA_CLIENT_DOWNLOAD_URL="{download_url}"')
        else:
            # Default: simple human output
            print(f"Version: {version}")
            print(f"SHA256: {sha256}")
            print(f"URL: {download_url}")

    except Exception as e:
        print(f"ERROR: Failed to detect latest version: {e}", file=sys.stderr)
        import traceback

        traceback.print_exc(file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
