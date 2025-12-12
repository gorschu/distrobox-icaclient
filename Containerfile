FROM quay.io/fedora/fedora-toolbox:42

ARG ICA_CLIENT_VERSION
ARG ICA_CLIENT_SHASUM

RUN --mount=type=bind,source=./init.sh,destination=/tmp/init.sh,relabel=shared /tmp/init.sh
