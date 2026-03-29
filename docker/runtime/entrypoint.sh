#!/usr/bin/env bash
set -e

mkdir -p /opt/legioncore/etc
mkdir -p /opt/legioncore/logs

if [ ! -f /opt/legioncore/etc/worldserver.conf ] && [ -f /opt/legioncore/etc/worldserver.conf.dist ]; then
  cp /opt/legioncore/etc/worldserver.conf.dist /opt/legioncore/etc/worldserver.conf
fi

if [ ! -f /opt/legioncore/etc/bnetserver.conf ] && [ -f /opt/legioncore/etc/bnetserver.conf.dist ]; then
  cp /opt/legioncore/etc/bnetserver.conf.dist /opt/legioncore/etc/bnetserver.conf
fi

exec "$@"
