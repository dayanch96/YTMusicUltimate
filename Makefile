ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
endif

ARCHS = arm64
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = SpringBoard YouTubeMusic
TARGET = iphone:clang:latest:13.0
PACKAGE_VERSION = 2.0.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate

$(TWEAK_NAME)_FILES = $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -DTWEAK_VERSION=$(PACKAGE_VERSION)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox
$(TWEAK_NAME)_OBJ_FILES = $(shell find Source/lib -name '*.a')
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z
ifeq ($(SIDELOADING),1)
$(TWEAK_NAME)_FILES += Sideloading.xm
endif

include $(THEOS_MAKE_PATH)/tweak.mk
