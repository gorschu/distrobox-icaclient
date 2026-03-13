FROM quay.io/almalinux/almalinux:9

# Container metadata
LABEL org.opencontainers.image.title="Citrix ICA Client Distrobox"
LABEL org.opencontainers.image.description="AlmaLinux 9 container with Citrix Workspace (ICA Client) for distrobox usage"
LABEL org.opencontainers.image.source="https://github.com/gorschu/distrobox-icaclient"
LABEL org.opencontainers.image.authors="gorschu"
LABEL org.opencontainers.image.licenses="MIT"

# Install dependencies: Python for web scraping, jq for JSON parsing
# python3-beautifulsoup4 and jq live in EPEL on RHEL9 derivatives
RUN dnf install -y epel-release && \
    dnf install -y python3 python3-beautifulsoup4 jq sudo && \
    dnf clean all

# Run init script for detection of latest version and installation
RUN --mount=type=bind,source=./init.sh,destination=/tmp/init.sh,relabel=shared \
  --mount=type=bind,source=./detect_latest.py,destination=/tmp/detect_latest.py,relabel=shared \
  /tmp/init.sh
