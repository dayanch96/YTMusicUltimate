ARCHS = arm64
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard YouTubeMusic
TARGET = iphone:clang:15.5:12.1.2
PACKAGE_VERSION = 1.2.8

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate

EXTRA_CFLAGS := $(addprefix -I,$(shell find Tweaks/FLEX -name '*.h' -exec dirname {} \;))

YTMusicUltimate_FILES = $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTMusicUltimate_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable $(EXTRA_CFLAGS)

include $(THEOS_MAKE_PATH)/tweak.mk