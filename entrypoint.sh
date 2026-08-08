#!/bin/sh
set -eu

# Passthrough: any args given (e.g. via compose `command:`) go straight to
# dhcrelay, unchanged - this keeps existing configs working as-is.
if [ "$#" -gt 0 ]; then
    exec dhcrelay -d "$@"
fi

# Otherwise build the command line from env vars, so the image is usable
# without hand-editing a compose `command:` array.
if [ -z "${DHCRELAY_DOWN_INTERFACE:-}" ] || [ -z "${DHCRELAY_UP_INTERFACE:-}" ]; then
    echo "dhcrelay: no arguments and no DHCRELAY_* env vars set." >&2
    echo "Set DHCRELAY_DOWN_INTERFACE and DHCRELAY_UP_INTERFACE (and DHCRELAY_SERVERS for DHCPv4), or pass dhcrelay flags directly as the container command." >&2
    exit 1
fi

set -- -id "$DHCRELAY_DOWN_INTERFACE" -iu "$DHCRELAY_UP_INTERFACE"

if [ "${DHCRELAY_MODE:-4}" = "6" ]; then
    set -- -6 "$@"
else
    if [ -z "${DHCRELAY_SERVERS:-}" ]; then
        echo "dhcrelay: DHCRELAY_SERVERS is required in DHCPv4 mode (space-separated DHCP server IPs)." >&2
        exit 1
    fi
    # Intentional word-splitting: DHCRELAY_SERVERS is a space-separated list.
    # shellcheck disable=SC2086
    set -- "$@" $DHCRELAY_SERVERS
fi

# Intentional word-splitting: DHCRELAY_EXTRA_ARGS is a space-separated list.
# shellcheck disable=SC2086
exec dhcrelay -d "$@" ${DHCRELAY_EXTRA_ARGS:-}
