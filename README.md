# distrobox-icaclient

Create a [distrobox](https://github.com/89luca89/distrobox) to run the
Citrix ICAClient in a containerized environment.

## Usage

Clone the repository and either just

```bash
distrobox assemble create
```

to have the ICAClient installed via `init_hooks` or

```bash
just build
distrobox assemble create --file ./distrobox.prebuilt.ini
```

for a ready-to-go image for faster subsequent startup times.

`wfica.sh` is exported to the host and can be used to start the ICAClient
with the provided `.ica` file.

You might want to adjust the `home` key in `distrobox.ini` and/or `distrobox.prebuilt.ini`
to suit your preferences.
