ICA_CLIENT_VERSION := "<VERSION>"
ICA_CLIENT_SHASUM := "<HASH>"

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
