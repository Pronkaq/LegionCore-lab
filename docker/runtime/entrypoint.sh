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

if [ "${1:-}" = "/usr/local/bin/worldserver" ]; then
  if [ ! -d /usr/local/bin/ClientData ] || [ -z "$(ls -A /usr/local/bin/ClientData 2>/dev/null)" ]; then
    if [ -n "${CLIENTDATA_URL:-}" ]; then
      echo "ClientData not found, downloading from ${CLIENTDATA_URL}"
      rm -f /tmp/clientdata.zip /tmp/clientdata.rar
      rm -rf /tmp/clientdata_unpack
      mkdir -p /tmp/clientdata_unpack

      case "${CLIENTDATA_URL}" in
        *.zip)
          curl -L "${CLIENTDATA_URL}" -o /tmp/clientdata.zip
          unzip -o /tmp/clientdata.zip -d /tmp/clientdata_unpack
          ;;
        *.rar)
          curl -L "${CLIENTDATA_URL}" -o /tmp/clientdata.rar
          7z x /tmp/clientdata.rar -o/tmp/clientdata_unpack -y
          ;;
        *)
          echo "Unsupported archive type in CLIENTDATA_URL: ${CLIENTDATA_URL}"
          exit 1
          ;;
      esac

      rm -rf /usr/local/bin/ClientData
      mkdir -p /usr/local/bin/ClientData

      if [ -d /tmp/clientdata_unpack/ClientData ]; then
        mv /tmp/clientdata_unpack/ClientData/* /usr/local/bin/ClientData/
      elif [ -d /tmp/clientdata_unpack/Data ]; then
        mv /tmp/clientdata_unpack/Data /usr/local/bin/ClientData
      else
        echo "Archive does not contain ClientData or Data directory"
        echo "Archive contents:"
        ls -la /tmp/clientdata_unpack || true
        find /tmp/clientdata_unpack -maxdepth 2 -type d || true
        exit 1
      fi
    else
      echo "ClientData not found and CLIENTDATA_URL is not set"
      exit 1
    fi
  fi
fi
exec "$@"
