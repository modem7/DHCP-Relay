# ISC DHCP Relay Agent

![Docker Pulls](https://img.shields.io/docker/pulls/modem7/dhcprelay)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/modem7/dhcprelay/latest)
[![status-badge](https://woodpecker.modem7.com/api/badges/10/status.svg?events=push%2Cmanual)](https://woodpecker.modem7.com/repos/10)
[![Lint Dockerfile](https://github.com/modem7/DHCP-Relay/actions/workflows/lint.yml/badge.svg)](https://github.com/modem7/DHCP-Relay/actions/workflows/lint.yml)
[![GitHub latest commit](https://badgen.net/github/last-commit/modem7/DHCP-Relay)](https://GitHub.com/modem7/DHCP-Relay/commit/)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/modem7)

A simple ISC DHCP Relay Agent.

The Internet Systems Consortium DHCP Relay Agent, dhcrelay, provides a means for relaying DHCP and BOOTP requests from a subnet to which no DHCP server is directly connected to one or more DHCP servers on other subnets. It supports both DHCPv4/BOOTP and DHCPv6 protocols.

More info can be found here: https://linux.die.net/man/8/dhcrelay

> [!IMPORTANT]
> **This repo has now been archived.** The changes below are the last planned update here.
> Upstream ISC-DHCP (including `dhcrelay`) has had no releases since 2022 and is EOL - see
> [#63](https://github.com/modem7/DHCP-Relay/issues/63). Rather than keep patching around a dead
> upstream, this has been replaced by [modem7/dnsmasq-relay](https://github.com/modem7/dnsmasq-relay).
> [Kea](https://www.isc.org/kea/) (ISC's supported DHCP successor) was the original plan, but Kea
> turned out to have no relay agent of its own - it's server-only - so the replacement is built on
> `dnsmasq`'s actively-maintained `--dhcp-relay` mode instead. No further feature work
> is planned here.

## What changed in this update

- Base image moved from Alpine (which dropped the `dhcrelay` package entirely as of 3.21) to
  `debian:trixie-slim`, which still packages and security-patches `isc-dhcp-relay`.
- The container now runs as a **non-root user**, with only the two capabilities it actually
  needs (`NET_RAW`, `NET_BIND_SERVICE`) - verified by testing, not just added out of caution.
- A real `HEALTHCHECK` (process-liveness based) replaces the old commented-out one, which
  wouldn't have worked against `dhcrelay`'s raw-socket relay model.
- Configuration can now be done via `DHCRELAY_*` environment variables instead of hand-editing
  the compose `command:` array (the old style still works unchanged - see below).
- A weekly check compares Debian's current `isc-dhcp-relay` version against the published image
  tag and opens a tracking issue if it's drifted, so security patches don't go unnoticed.
- CI/build tagging now reflects the actual `isc-dhcp-relay` version baked into the image (e.g.
  `4.4.3`) instead of a hardcoded, driftable tag.

# Tags
| Tag | Description |
| :----: | --- |
| Latest | Latest built image. |
| 4.4.x | The `isc-dhcp-relay` version baked into that build (e.g. `4.4.3`). |

# Configuration

In this config, UDP port 67 (DHCPv4) and/or 547 (DHCPv6) must be free on the host.

```yaml
services:

 #############
 ##DHCPRelay##
 #############

 #DHCPRelay - DHCP Relay between host network and Docker bridge
  dhcprelay:
    image: modem7/dhcprelay:latest
    container_name: DHCPRelay
    environment:
      DHCRELAY_DOWN_INTERFACE: eno1
      DHCRELAY_UP_INTERFACE: br_pihole #https://fedoramagazine.org/build-network-bridge-fedora/
      DHCRELAY_SERVERS: 172.33.0.100
    cap_drop:
      - ALL
    cap_add:
      - NET_RAW
      - NET_BIND_SERVICE
    network_mode: host
    restart: always
    mem_limit: 20m
    mem_reservation: 5m
```

The container runs as a non-root user; `NET_RAW` (to open the relay's raw socket) and
`NET_BIND_SERVICE` (to bind port 67 as non-root) are the only capabilities it needs -
`cap_drop: ALL` removes everything else.

If you'd rather pass `dhcrelay` flags directly (e.g. to replicate an existing setup, or use flags
the env vars don't cover), override `command:` instead - any command given is passed straight
through to `dhcrelay`, bypassing the env vars entirely:

```yaml
    command: ["-id", "eno1", "-iu", "br_pihole", "172.33.0.100"]
```

## Environment variables

| Variable | Required | Description |
| --- | :---: | --- |
| `DHCRELAY_DOWN_INTERFACE` | Yes | Downstream (client-facing) interface. |
| `DHCRELAY_UP_INTERFACE` | Yes | Upstream (server-facing) interface. |
| `DHCRELAY_SERVERS` | DHCPv4 only | Space-separated DHCP server IP(s) to relay to. |
| `DHCRELAY_MODE` | No | `4` (default) or `6` for DHCPv6 relay mode. |
| `DHCRELAY_EXTRA_ARGS` | No | Extra flags appended as-is, e.g. extra `-id`/`-iu` pairs for additional interfaces. |

# Commands explanation
https://linux.die.net/man/8/dhcrelay

## DHCPv4 relay

```bash
dhcrelay -id eno1 -iu br_pihole 172.33.0.100
```
```text
-id ifname   Downstream interface: listen for client DHCPv4/BOOTP requests here.
-iu ifname   Upstream interface: forward requests towards the DHCP server here.
eno1         Your NIC facing clients (find it with `ip -o link show`).
br_pihole    Your Docker network bridge facing the DHCP server.
172.33.0.100 The DHCP server's IP address - typically your PiHole bridge IP.
```

## DHCPv6 relay

```bash
dhcrelay -6 -id eno1 -iu br_pihole
```
```text
-6           DHCPv6 relay mode.
-id ifname   Downstream interface: listen for client requests here.
-iu ifname   Upstream interface: the address or interface to forward to. Defaults to the
             DHCPv6 All_DHCP_Relay_Agents_and_Servers multicast address if no address is given.
```

## Shared flags

```text
-d           Force dhcrelay to run in the foreground - this is how the container's entrypoint
             always runs it, so container logs show relay activity.
```
