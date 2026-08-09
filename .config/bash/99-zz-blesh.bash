# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

if [ -n "${BLE_VERSION:-}" ]; then
  ble-attach
fi
