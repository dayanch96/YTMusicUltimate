ARCHS = arm64
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard YouTubeMusic
TARGET = iphone:clang:14.4:12.1.2
PACKAGE_VERSION = 1.2.5

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate

YTMusicUltimate_FILES = $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTMusicUltimate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk