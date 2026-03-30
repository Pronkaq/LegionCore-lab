#!/usr/bin/env bash
set -e

mkdir -p /usr/local/etc
mkdir -p /opt/legioncore/logs

if [ ! -f /usr/local/etc/worldserver.conf ] && [ -f /usr/local/etc/worldserver.conf.dist ]; then
  cp /usr/local/etc/worldserver.conf.dist /usr/local/etc/worldserver.conf
fi

if [ ! -f /usr/local/etc/bnetserver.conf ] && [ -f /usr/local/etc/bnetserver.conf.dist ]; then
  cp /usr/local/etc/bnetserver.conf.dist /usr/local/etc/bnetserver.conf
fi

exec "$@"
