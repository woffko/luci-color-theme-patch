# luci-color-patch

OpenWrt feed package for the local LuCI Bootstrap accent color patch.

The package installs an idempotent runtime patcher, a `uci-defaults` hook, an
init script and a preserved local APK cache. A manually installed package can
therefore re-install itself after sysupgrade and still show up as installed in
the OpenWrt 25.x `apk` database.

The repository also carries a build-time helper that patches LuCI feed sources
before image generation, which makes the generated sysupgrade image contain the
patched LuCI files immediately.

## Runtime APK Install

Install an unsigned local build with:

```sh
apk add --allow-untrusted ./luci-color-patch-1.1.0-r1.apk
```

The package post-install script enables `/etc/init.d/luci-color-patch`, copies
the embedded self-reinstall APK to
`/etc/luci-color-patch/luci-color-patch.apk` and applies the LuCI patch.

Check the install state with:

```sh
apk info -e luci-color-patch
test -f /etc/luci-color-patch/luci-color-patch.apk && echo cache-ok
```

After sysupgrade, `/lib/upgrade/keep.d/luci-color-patch` preserves the cached
APK and the small restore scripts. On the first boot, the init script runs:

```sh
/usr/libexec/luci-color-patch/reinstall
```

If the package is missing from the new `apk` database, the restore script uses:

```sh
apk add --allow-untrusted --force-overwrite /etc/luci-color-patch/luci-color-patch.apk
```

This intentionally bypasses package signing for the preserved local APK and
allows overwriting the package's own restored files.

## OpenWrt Feed

For GitHub-backed builds:

```sh
src-git lucicolor https://github.com/woffko/luci-color-theme-patch.git
```

For local development:

```sh
src-link lucicolor /home/w0w/luci-color-patch
```

Then run:

```sh
./scripts/feeds update lucicolor
./scripts/feeds install -a -p lucicolor
./feeds/lucicolor/scripts/apply-openwrt-tree.sh
```

Enable `PACKAGE_luci-color-patch=y` in `.config` and rebuild LuCI/image
artifacts.
