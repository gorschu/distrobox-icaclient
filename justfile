ICA_CLIENT_VERSION := "25.08.0.88-0"
ICA_CLIENT_SHASUM := "1ebd3eae4e0ad97bc1a00d011d896e6b1d8e98206bc8815d8382b272576f348a"

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
