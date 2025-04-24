FROM ghcr.io/ublue-os/fedora-toolbox:latest

RUN --mount=type=bind,source=./init.sh,destination=/tmp/init.sh /tmp/init.sh
