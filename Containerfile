FROM quay.io/fedora/fedora-toolbox:42

# Container metadata
LABEL org.opencontainers.image.title="Citrix ICA Client Distrobox"
LABEL org.opencontainers.image.description="Fedora Toolbox container with Citrix Workspace (ICA Client) for distrobox usage"
LABEL org.opencontainers.image.source="https://github.com/gorschu/distrobox-icaclient"
LABEL org.opencontainers.image.authors="gorschu"

# Install Python dependencies for version detection
RUN dnf5 install -y python3-beautifulsoup4 && dnf5 clean all

# Run init script for detection of latest version and installation
RUN --mount=type=bind,source=./init.sh,destination=/tmp/init.sh,relabel=shared \
    --mount=type=bind,source=./detect_latest.py,destination=/tmp/detect_latest.py,relabel=shared \
    /tmp/init.sh
