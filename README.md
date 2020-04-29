# ISC DHCP Relay Agent

A simple ISC DHCP Relay Agent

In this config, udp port 67 must be free on the host.

```bash
version: "2.4"

services:

  #DHCPRelay - DHCP Relay between host network and PiHole bridge
  dhcprelay:
    #image: modem7/hda:dhcprelay
    image: modem7/hda:dhcprelayalpine
    restart: always
    network_mode: host
    container_name: DHCPRelay
    command: ["-id", "eno1", "-iu", "br_pihole", "172.33.0.100"] #https://fedoramagazine.org/build-network-bridge-fedora/
    cap_add:
      - NET_ADMIN
    mem_limit: 20m
    mem_reservation: 5m
```