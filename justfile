ICA_CLIENT_VERSION := "25.08.10.111-0"
ICA_CLIENT_SHASUM := "7b2110b8a1b68fbf02b66c46fbbeef04c3665116c30d611032a5336d288ef38e"

build:
  podman build \
    --build-arg ICA_CLIENT_VERSION={{ ICA_CLIENT_VERSION }} \
    --build-arg ICA_CLIENT_SHASUM={{ ICA_CLIENT_SHASUM }} \
    -t icaclient:latest -t icaclient:{{ ICA_CLIENT_VERSION }} .

assemble:
  ICA_CLIENT_VERSION={{ ICA_CLIENT_VERSION }} \
    ICA_CLIENT_SHASUM={{ ICA_CLIENT_SHASUM }} \
    distrobox assemble create

assemble-prebuilt:
  distrobox assemble create --file ./distrobox.prebuilt.ini

