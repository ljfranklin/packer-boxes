## Packer boxes

Collection of [Packer](https://packer.io/) box templates

#### Build Raspberry Pi Ubuntu box

```bash
# takes over an hour...
docker run -v $PWD:/build -w /build -p 127.0.0.1:5901:5901/tcp -it ljfranklin/packer-boxes ubuntu1904/build-rpi3.sh
```

To view the screen output:

```bash
vncviewer -Shared 127.0.0.1:5901
```

#### Update deps, e.g. EDK2

```bash
docker run -v $PWD:/build -w /build -it ljfranklin/packer-boxes ubuntu1904/build-deps.sh
```

#### Debugging

To get debug logs from the QEMU install, add the following lines to `qemuargs`:

```
  [
    "-netdev",
    "user,id=user.0,hostfwd=tcp::8080-:80"
  ],
  [ "-device", "virtio-net,netdev=user.0"],
  [ "-device", "virtio-scsi-device"],
  [ "-device", "scsi-cd,drive=cdrom"],
```

On failed installs, select Save Debug Logs > Web from the menu.
Then `curl localhost:8080/syslog` from the host.
Note: The CDROM flags are needed as setting `-device` will remove all the default
`-device` flags that QEMU builder normally adds.
