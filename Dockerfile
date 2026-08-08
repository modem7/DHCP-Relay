# syntax = docker/dockerfile:1

FROM debian:trixie-slim

LABEL org.opencontainers.image.title="dhcprelay" \
      org.opencontainers.image.description="ISC DHCP Relay Agent (dhcrelay) in a minimal container" \
      org.opencontainers.image.source="https://github.com/modem7/DHCP-Relay" \
      org.opencontainers.image.licenses="MIT"

# isc-dhcp-relay is deliberately unpinned (hadolint DL3008) so every rebuild
# picks up Debian's latest security backport - upstream ISC-DHCP itself has
# had no releases since 2022, so Debian's own patching is what keeps this
# current. libcap2-bin is a build-only dependency, removed after setcap runs.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        isc-dhcp-relay \
        libcap2-bin \
        tzdata \
    && setcap cap_net_raw,cap_net_bind_service+eip /usr/sbin/dhcrelay \
    && apt-get purge -y --auto-remove libcap2-bin \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r -g 999 dhcp \
    && useradd -r -u 999 -g dhcp -M -s /usr/sbin/nologin dhcp

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

USER 999:999

EXPOSE 67/udp 547/udp

HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=5s \
    CMD ["sh", "-c", "[ \"$(cat /proc/1/comm)\" = dhcrelay ]"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
