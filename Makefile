ARCHS = arm64
TARGET = iphone:clang:latest:13.0
PACKAGE_VERSION = 1.1.5
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard
# PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

ifeq ($(SIDELOADED),1)
MODULES = jailed
DISPLAY_NAME = YouTube Music
BUNDLE_ID = com.google.ios.youtubemusic
CODESIGN_IPA = 0

YTMusicUltimate_IPA = ./tmp/Payload/YouTubeMusic.app
YTMusicUltimate_FRAMEWORKS = UIKit Security Foundation CoreGraphics
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate

YTMusicUltimate_FILES = $(wildcard *.xm) $(wildcard *.m)
YTMusicUltimate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
