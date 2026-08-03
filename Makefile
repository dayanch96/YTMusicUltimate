ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME = rootless
else ifeq ($(ROOTHIDE),1)
THEOS_PACKAGE_SCHEME = roothide
endif

ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTubeMusic
TARGET = iphone:clang:16.5:13.0
PACKAGE_VERSION = 2.4.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTMusicUltimate
$(TWEAK_NAME)_FILES = $(filter-out Source/Sideloading.x, $(wildcard Source/*.x))
$(TWEAK_NAME)_FILES += $(shell find Source -name '*.m')
# Discord application used by Rich Presence. Defaults to Metrolist's, whose
# registered OAuth2 redirect URI matches YTMUDiscordCallbackURL. Override with
# make DISCORD_APP_ID=... (your application must register that redirect URI too).
DISCORD_APP_ID ?= 1447278780795064401

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -DTWEAK_VERSION=$(PACKAGE_VERSION) -DYTMU_DISCORD_APP_ID=$(DISCORD_APP_ID)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AudioToolbox VideoToolbox MediaPlayer AuthenticationServices Security
$(TWEAK_NAME)_OBJ_FILES = $(shell find Source/Utils/lib -name '*.a')
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z
ifeq ($(SIDELOADING),1)
$(TWEAK_NAME)_FILES += Source/Sideloading.x
endif

include $(THEOS_MAKE_PATH)/tweak.mk
