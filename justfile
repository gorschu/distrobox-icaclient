default:
  @just --list

# build base container image
build:
  podman build -t icaclient:latest .

# assemble a distrobox based on pre-built image
assemble-prebuilt: build
  distrobox assemble create --file ./distrobox.prebuilt.ini

# assemble the distrobox
assemble:
  distrobox assemble create


