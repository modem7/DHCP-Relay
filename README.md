# ISC DHCP Relay Agent

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/dhcprelay) ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/dhcprelay/latest)

A simple ISC DHCP Relay Agent.

The Internet Systems Consortium DHCP Relay Agent, dhcrelay, provides a means for relaying DHCP and BOOTP requests from a subnet to which no DHCP server is directly connected to one or more DHCP servers on other subnets. It supports both DHCPv4/BOOTP and DHCPv6 protocols. 

More info can be found here: https://linux.die.net/man/8/dhcrelay

# Configuration

In this config, udp port 67 must be free on the host.

```bash
version: "2.4"

services:

 #############
 ##DHCPRelay##
 #############
 
 #DHCPRelay - DHCP Relay between host network and PiHole bridge
  dhcprelay:
    image: modem7/dhcprelay:latest
    container_name: DHCPRelay
    command: ["-id", "eno1", "-iu", "br_pihole", "172.33.0.100"] #https://fedoramagazine.org/build-network-bridge-fedora/
    cap_add:
      - NET_ADMIN
    network_mode: host
    restart: always
    mem_limit: 20m
    mem_reservation: 5m
```
