FROM registry.fedoraproject.org/fedora-toolbox:44

ARG ICA_CLIENT_VERSION
ARG ICA_CLIENT_SHASUM

RUN --mount=type=bind,source=./init.sh,destination=/tmp/init.sh,relabel=shared /tmp/init.sh
