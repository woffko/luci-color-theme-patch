#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
APPLY="$REPO_DIR/luci-color-patch/files/usr/libexec/luci-color-patch/apply"
FIXTURES="$SCRIPT_DIR/fixtures"

command -v node >/dev/null 2>&1 || {
	echo "node is required for JavaScript syntax checks" >&2
	exit 1
}

command -v sha256sum >/dev/null 2>&1 || {
	echo "sha256sum is required for idempotency checks" >&2
	exit 1
}

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/luci-color-patch-tests.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

cp "$FIXTURES/system-unpatched-minified.js" "$tmp_dir/unpatched.js"
cp "$FIXTURES/system-broken-minified.js" "$tmp_dir/broken.js"

if node --check "$tmp_dir/broken.js" >/dev/null 2>&1; then
	echo "broken fixture unexpectedly passed the syntax check" >&2
	exit 1
fi

LUCI_COLOR_PATCH_LIBRARY_ONLY=1
export LUCI_COLOR_PATCH_LIBRARY_ONLY
. "$APPLY"

assert_patched() {
	file="$1"
	node --check "$file"

	grep -qE "o[[:space:]]*\.[[:space:]]*value[[:space:]]*\([[:space:]]*uci[[:space:]]*\.[[:space:]]*get[[:space:]]*\([[:space:]]*'luci'[[:space:]]*,[[:space:]]*'themes'[[:space:]]*,[[:space:]]*t[[:space:]]*\)[[:space:]]*,[[:space:]]*t[[:space:]]*\)[[:space:]]*;" "$file"
	grep -q 'luci-colorpatch-system-v8' "$file"

	palette_count="$(awk '{ count += gsub(/const[[:space:]]+accentPaletteChoices/, "&") } END { print count + 0 }' "$file")"
	[ "$palette_count" -eq 1 ] || {
		echo "expected one accent palette in $file, found $palette_count" >&2
		exit 1
	}

	marker_count="$(awk '{ count += gsub(/const[[:space:]]+luciColorPatchSystemMarker/, "&") } END { print count + 0 }' "$file")"
	[ "$marker_count" -eq 1 ] || {
		echo "expected one persistent marker in $file, found $marker_count" >&2
		exit 1
	}
}

assert_idempotent() {
	file="$1"
	SYSTEM_JS="$file"
	patch_system_js
	assert_patched "$file"
	first_hash="$(sha256sum "$file" | awk '{ print $1 }')"

	patch_system_js
	assert_patched "$file"
	second_hash="$(sha256sum "$file" | awk '{ print $1 }')"

	[ "$first_hash" = "$second_hash" ] || {
		echo "system.js patch is not idempotent for $file" >&2
		exit 1
	}
}

assert_idempotent "$tmp_dir/unpatched.js"
assert_idempotent "$tmp_dir/broken.js"

if [ -n "${JSMIN:-}" ]; then
	[ -x "$JSMIN" ] || {
		echo "JSMIN is not executable: $JSMIN" >&2
		exit 1
	}

	"$JSMIN" < "$tmp_dir/unpatched.js" > "$tmp_dir/current-minified.js"
	assert_patched "$tmp_dir/current-minified.js"
	SYSTEM_JS="$tmp_dir/current-minified.js"
	before_hash="$(sha256sum "$SYSTEM_JS" | awk '{ print $1 }')"
	patch_system_js
	after_hash="$(sha256sum "$SYSTEM_JS" | awk '{ print $1 }')"
	[ "$before_hash" = "$after_hash" ] || {
		echo "current minified system.js was unexpectedly rewritten" >&2
		exit 1
	}
fi

echo "system.js patch tests passed"
