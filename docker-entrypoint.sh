#!/bin/bash
set -e

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "${1:0:1}" = '-' ]; then
  set -- squid3 "$@"
fi

# check for the expected command
if [ "$1" = "squid3" ]; then
  # docker volume mounts sometimes reset this to root:root
  chown proxy:proxy /var/cache/squid-deb-proxy /var/log/squid-deb-proxy

  if [ ! -d "/var/cache/squid-deb-proxy/00" ]; then
    echo "Initializing cache..."
    squid3 -N -f /etc/squid-deb-proxy/squid-deb-proxy.conf -z
  fi

  exec "$@" -f /etc/squid-deb-proxy/squid-deb-proxy.conf -NYCd 1
fi

# otherwise, don't get in their way
exec "$@"
