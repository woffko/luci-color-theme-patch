# luci-color-patch

OpenWrt feed package for the local LuCI Bootstrap accent color patch.

The package installs an idempotent runtime patcher and a `uci-defaults` hook so
the color selector survives sysupgrade. The repository also carries a build-time
helper that patches LuCI feed sources before image generation, which makes the
generated sysupgrade image contain the patched LuCI files immediately.

## OpenWrt Feed

For local builds:

```sh
src-link lucicolor /home/w0w/luci-color-patch
```

For GitHub-backed builds after the remote repository is created:

```sh
src-git lucicolor https://github.com/woffko/luci-color-patch.git
```

Then run:

```sh
./scripts/feeds update lucicolor
./scripts/feeds install -a -p lucicolor
./feeds/lucicolor/scripts/apply-openwrt-tree.sh
```

Enable `PACKAGE_luci-color-patch=y` in `.config` and rebuild LuCI/image
artifacts.
