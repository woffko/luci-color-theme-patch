include $(TOPDIR)/rules.mk

PKG_NAME:=luci-color-patch
PKG_VERSION:=1.0.0
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
  Adds a LuCI Bootstrap accent color selector and header color CSS overrides.
  The patch is idempotent and can be applied at build time or on first boot
  after sysupgrade.
endef

define Build/Compile
endef

define Package/luci-color-patch/install
	$(INSTALL_DIR) $(1)/usr/libexec/luci-color-patch
	$(INSTALL_BIN) ./files/usr/libexec/luci-color-patch/apply $(1)/usr/libexec/luci-color-patch/apply
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-luci-color-patch $(1)/etc/uci-defaults/99-luci-color-patch
endef

$(eval $(call BuildPackage,luci-color-patch))

