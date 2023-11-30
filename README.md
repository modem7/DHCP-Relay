# ISC DHCP Relay Agent

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/dhcprelay) 
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/dhcprelay/latest) 
[![Build Status](https://drone.modem7.com/api/badges/modem7/DHCP-Relay/status.svg)](https://drone.modem7.com/modem7/DHCP-Relay)
[![GitHub latest commit](https://badgen.net/github/last-commit/modem7/DHCP-Relay)](https://GitHub.com/modem7/DHCP-Relay/commit/)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

A simple ISC DHCP Relay Agent.

The Internet Systems Consortium DHCP Relay Agent, dhcrelay, provides a means for relaying DHCP and BOOTP requests from a subnet to which no DHCP server is directly connected to one or more DHCP servers on other subnets. It supports both DHCPv4/BOOTP and DHCPv6 protocols. 

More info can be found here: https://linux.die.net/man/8/dhcrelay

# Tags
| Tag | Description |
| :----: | --- |
| Latest | Latest release built upon the latest version. |
| 4.4.x | Versioned release. |

# Configuration

In this config, udp port 67 must be free on the host.

```bash
version: "2.4"

services:

 #############
 ##DHCPRelay##
 #############
 
 #DHCPRelay - DHCP Relay between host network and Docker bridge
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

# Commands explanation
https://linux.die.net/man/8/dhcrelay
```bash
-i ifname
Listen for DHCPv4/BOOTP queries on interface ifname. Multiple interfaces may be specified by using more than one -i option. If no interfaces are specified on the command line, dhcrelay will identify all network interfaces, eliminating non-broadcast interfaces if possible, and attempt to listen on all of them.

-d
Force dhcrelay to run as a foreground process. Useful when running dhcrelay under a debugger, or running out of inittab on System V systems.

eno1
Your NIC (you can find this with ifconfig -a)

-u [address%]ifname
Specifies the ''upper'' network interface for DHCPv6 relay mode: the interface to which queries from clients and other relay agents should be forwarded. At least one -u option must be included in the command line when running in DHCPv6 mode. The interface name ifname is a mandatory parameter. The destination unicast or multicast address can be specified by address%; if not specified, the relay agent will forward to the DHCPv6 All_DHCP_Relay_Agents_and_Servers multicast address.

br_pihole
Your Docker network bridge name.

172.33.0.100
The destination IP address for the packets. Typically your PiHole bridge IP address.
```
