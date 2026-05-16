#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
FEED_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
OPENWRT_ROOT="${OPENWRT_ROOT:-$(pwd)}"
APPLY="$FEED_DIR/luci-color-patch/files/usr/libexec/luci-color-patch/apply"

[ -x "$APPLY" ] || {
	echo "Missing patcher: $APPLY" >&2
	exit 1
}

LUCI_CFG="$OPENWRT_ROOT/feeds/luci/modules/luci-base/root/etc/config/luci" \
SYSTEM_JS="$OPENWRT_ROOT/feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/system.js" \
HEADER_UT="$OPENWRT_ROOT/feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/header.ut" \
CASCADE_CSS="$OPENWRT_ROOT/feeds/luci/themes/luci-theme-bootstrap/htdocs/luci-static/bootstrap/cascade.css" \
NO_BACKUP="${NO_BACKUP:-1}" \
RESTART_SERVICES=0 \
"$APPLY"

