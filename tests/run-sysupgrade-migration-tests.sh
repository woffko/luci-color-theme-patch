#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
APPLY="$REPO_DIR/luci-color-patch/files/usr/libexec/luci-color-patch/apply"
BOOTSTRAP="$REPO_DIR/luci-color-patch/files/usr/libexec/luci-color-patch/bootstrap-r6"
FIXTURES="$SCRIPT_DIR/fixtures"

command -v node >/dev/null 2>&1 || {
	echo "node is required for JavaScript syntax checks" >&2
	exit 1
}

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/luci-color-migration-tests.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

prepare_root() {
	root="$1"
	mkdir -p \
		"$root/etc/config" \
		"$root/etc/init.d" \
		"$root/etc/rc.d" \
		"$root/etc/uci-defaults" \
		"$root/lib/upgrade/keep.d" \
		"$root/tmp" \
		"$root/usr/libexec/luci-color-patch" \
		"$root/usr/share/luci-color-patch/r6" \
		"$root/www/luci-static/bootstrap" \
		"$root/www/luci-static/resources/view/system" \
		"$root/usr/share/ucode/luci/template/themes/bootstrap"

	cp "$FIXTURES/luci-config" "$root/etc/config/luci"
	cp "$FIXTURES/header.ut" "$root/usr/share/ucode/luci/template/themes/bootstrap/header.ut"
	cp "$FIXTURES/cascade.css" "$root/www/luci-static/bootstrap/cascade.css"
	cp "$FIXTURES/system-unpatched-minified.js" "$root/www/luci-static/resources/view/system/system.js"
	cp "$APPLY" "$root/usr/share/luci-color-patch/r6/apply"
	cp "$BOOTSTRAP" "$root/usr/libexec/luci-color-patch/bootstrap-r6"
	chmod 0755 "$root/usr/share/luci-color-patch/r6/apply" "$root/usr/libexec/luci-color-patch/bootstrap-r6"

	(
		LUCI_COLOR_PATCH_LIBRARY_ONLY=1
		SYSTEM_JS="$root/www/luci-static/resources/view/system/system.js"
		export LUCI_COLOR_PATCH_LIBRARY_ONLY SYSTEM_JS
		. "$APPLY"
		patch_system_js
	)

	cat > "$root/usr/libexec/luci-color-patch/apply" <<'EOF'
#!/bin/sh
exit 97
EOF
	chmod 0755 "$root/usr/libexec/luci-color-patch/apply"

	printf '%s\n' legacy > "$root/etc/init.d/luci-color-patch"
	printf '%s\n' legacy > "$root/lib/upgrade/keep.d/luci-color-patch"
	printf '%s\n' legacy > "$root/usr/libexec/luci-color-patch/reinstall"
	printf '%s\n' legacy > "$root/usr/share/luci-color-patch/luci-color-patch.apk"
	mkdir -p "$root/etc/luci-color-patch"
	printf '%s\n' legacy > "$root/etc/luci-color-patch/luci-color-patch.apk"
	printf '%s\n' legacy > "$root/etc/uci-defaults/99-luci-color-patch"
	ln -s ../../init.d/luci-color-patch "$root/etc/rc.d/S99luci-color-patch"
}

assert_current_apply_and_system() {
	root="$1"
	cmp "$root/usr/share/luci-color-patch/r6/apply" "$root/usr/libexec/luci-color-patch/apply"
	node --check "$root/www/luci-static/resources/view/system/system.js"
	grep -q 'luci-colorpatch-system-v8' "$root/www/luci-static/resources/view/system/system.js"
	grep -q 'data-accent="{{ safeaccent }}"' "$root/usr/share/ucode/luci/template/themes/bootstrap/header.ut"
}

plain_root="$tmp_dir/plain"
prepare_root "$plain_root"
cp "$FIXTURES/system-broken-minified.js" "$plain_root/www/luci-static/resources/view/system/system.js"
if node --check "$plain_root/www/luci-static/resources/view/system/system.js" >/dev/null 2>&1; then
	echo "legacy-corrupted plain fixture unexpectedly passed syntax validation" >&2
	exit 1
fi
ROOT="$plain_root" NO_BACKUP=1 RESTART_SERVICES=0 "$BOOTSTRAP"
assert_current_apply_and_system "$plain_root"

for legacy_path in \
	etc/rc.d/S99luci-color-patch \
	etc/init.d/luci-color-patch \
	lib/upgrade/keep.d/luci-color-patch \
	usr/libexec/luci-color-patch/reinstall \
	usr/share/luci-color-patch/luci-color-patch.apk \
	etc/luci-color-patch/luci-color-patch.apk \
	etc/uci-defaults/99-luci-color-patch
do
	[ ! -e "$plain_root/$legacy_path" ] || {
		echo "plain migration retained legacy path: $legacy_path" >&2
		exit 1
	}
done

selfrestore_root="$tmp_dir/selfrestore"
prepare_root "$selfrestore_root"
cp "$FIXTURES/system-stale-marker-minified.js" "$selfrestore_root/www/luci-static/resources/view/system/system.js"
cp "$REPO_DIR/luci-color-patch/files/usr/libexec/luci-color-patch/reinstall" "$selfrestore_root/usr/share/luci-color-patch/r6/reinstall"
cp "$REPO_DIR/luci-color-patch/files/etc/init.d/luci-color-patch" "$selfrestore_root/usr/share/luci-color-patch/r6/init"
cp "$REPO_DIR/luci-color-patch/files/lib/upgrade/keep.d/luci-color-patch" "$selfrestore_root/usr/share/luci-color-patch/r6/keep"
printf '%s\n' r6-seed > "$selfrestore_root/usr/share/luci-color-patch/r6/seed.apk"

ROOT="$selfrestore_root" NO_BACKUP=1 RESTART_SERVICES=0 "$BOOTSTRAP"
assert_current_apply_and_system "$selfrestore_root"
cmp "$selfrestore_root/usr/share/luci-color-patch/r6/reinstall" "$selfrestore_root/usr/libexec/luci-color-patch/reinstall"
cmp "$selfrestore_root/usr/share/luci-color-patch/r6/init" "$selfrestore_root/etc/init.d/luci-color-patch"
cmp "$selfrestore_root/usr/share/luci-color-patch/r6/keep" "$selfrestore_root/lib/upgrade/keep.d/luci-color-patch"
cmp "$selfrestore_root/usr/share/luci-color-patch/r6/seed.apk" "$selfrestore_root/usr/share/luci-color-patch/luci-color-patch.apk"
cmp "$selfrestore_root/usr/share/luci-color-patch/r6/seed.apk" "$selfrestore_root/etc/luci-color-patch/luci-color-patch.apk"

if grep -Eq '/usr/libexec/luci-color-patch/apply|/etc/uci-defaults|/usr/share/luci-color-patch/luci-color-patch.apk' "$selfrestore_root/lib/upgrade/keep.d/luci-color-patch"; then
	echo "selfrestore r6 keep list still preserves mutable package payload" >&2
	exit 1
fi

echo "sysupgrade migration tests passed"
