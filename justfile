build:
  podman build -t icaclient:latest .

assemble:
  distrobox assemble create

assemble-prebuilt:
  distrobox assemble create --file ./distrobox.prebuilt.ini

