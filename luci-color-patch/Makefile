include $(TOPDIR)/rules.mk

PKG_NAME:=luci-color-patch
PKG_VERSION:=1.2.2
PKG_RELEASE:=4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luci-color-patch
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI Bootstrap accent color patch
  URL:=https://github.com/woffko/luci-color-theme-patch
  MAINTAINER:=woffko
  DEPENDS:=+luci-base +luci-mod-system +luci-theme-bootstrap
  PKGARCH:=all
endef

define Package/luci-color-patch/description
  Adds a LuCI Bootstrap accent color palette and header color CSS overrides.
  This plain variant does not preserve or reinstall itself after sysupgrade.
endef

define Build/Compile
endef

define Package/luci-color-patch/install
	$(INSTALL_DIR) $(1)/usr/libexec/luci-color-patch
	$(INSTALL_BIN) ./files/usr/libexec/luci-color-patch/apply $(1)/usr/libexec/luci-color-patch/apply
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-luci-color-patch $(1)/etc/uci-defaults/99-luci-color-patch
endef

define Package/luci-color-patch/postinst
#!/bin/sh

[ -n "$${IPKG_INSTROOT}" ] && exit 0

[ -x /usr/libexec/luci-color-patch/apply ] && NO_BACKUP=1 RESTART_SERVICES=1 /usr/libexec/luci-color-patch/apply || true

exit 0
endef

$(eval $(call BuildPackage,luci-color-patch))
