include $(TOPDIR)/rules.mk

PKG_NAME:=luci-color-patch
PKG_VERSION:=1.2.2
PKG_RELEASE:=1

PKG_MAINTAINER:=woffko
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/luci-color-patch
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI Bootstrap accent color patch
  DEPENDS:=+luci-base +luci-mod-system +luci-theme-bootstrap
  PKGARCH:=all
endef

define Package/luci-color-patch/description
  Adds a LuCI Bootstrap accent color palette and header color CSS overrides,
  with a self-preserved local APK cache for unattended reinstall after
  sysupgrade.
endef

define Build/Compile
endef

define Package/luci-color-patch/install
	$(INSTALL_DIR) $(1)/usr/libexec/luci-color-patch
	$(INSTALL_BIN) ./files/usr/libexec/luci-color-patch/apply $(1)/usr/libexec/luci-color-patch/apply
	$(INSTALL_BIN) ./files/usr/libexec/luci-color-patch/reinstall $(1)/usr/libexec/luci-color-patch/reinstall
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/luci-color-patch $(1)/etc/init.d/luci-color-patch
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-luci-color-patch $(1)/etc/uci-defaults/99-luci-color-patch
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/lib/upgrade/keep.d/luci-color-patch $(1)/lib/upgrade/keep.d/luci-color-patch
	if [ -f ./files/usr/share/luci-color-patch/luci-color-patch.apk ]; then \
		$(INSTALL_DIR) $(1)/usr/share/luci-color-patch; \
		$(INSTALL_DATA) ./files/usr/share/luci-color-patch/luci-color-patch.apk $(1)/usr/share/luci-color-patch/luci-color-patch.apk; \
	fi
endef

define Package/luci-color-patch/postinst
#!/bin/sh

[ -n "$${IPKG_INSTROOT}" ] && exit 0

[ -x /etc/init.d/luci-color-patch ] && /etc/init.d/luci-color-patch enable >/dev/null 2>&1 || true
if [ "$${LUCI_COLOR_PATCH_SELF_REINSTALL}" != "1" ]; then
	[ -x /usr/libexec/luci-color-patch/reinstall ] && /usr/libexec/luci-color-patch/reinstall --refresh-cache || true
fi
[ -x /usr/libexec/luci-color-patch/apply ] && NO_BACKUP=1 RESTART_SERVICES=1 /usr/libexec/luci-color-patch/apply || true

exit 0
endef

define Package/luci-color-patch/prerm
#!/bin/sh

[ -n "$${IPKG_INSTROOT}" ] && exit 0

if [ "$${PKG_UPGRADE}" != "1" ]; then
	[ -x /etc/init.d/luci-color-patch ] && /etc/init.d/luci-color-patch disable >/dev/null 2>&1 || true
	rm -f /etc/luci-color-patch/luci-color-patch.apk
fi

exit 0
endef

$(eval $(call BuildPackage,luci-color-patch))
