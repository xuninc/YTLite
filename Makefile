ifeq ($(ROOTLESS),1)
THEOS_PACKAGE_SCHEME=rootless
else ifeq ($(ROOTHIDE),1)
THEOS_PACKAGE_SCHEME=roothide
endif

DEBUG=0
FINALPACKAGE=1
ARCHS = arm64
PACKAGE_VERSION = 3.0.1
TARGET := iphone:clang:16.5:13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTLite
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation SystemConfiguration Photos Security AVFoundation AVKit AudioToolbox VideoToolbox CoreMedia
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -DTWEAK_VERSION=$(PACKAGE_VERSION) -Wall -Wno-unused-variable -Wno-unused-function -Wno-deprecated-declarations
$(TWEAK_NAME)_CFLAGS += -IFFmpeg/include -DMOBILE_FFMPEG_LTS
$(TWEAK_NAME)_FILES = $(wildcard *.x Utils/*.m FFmpeg/*.m)
$(TWEAK_NAME)_LDFLAGS = -LFFmpeg/lib
$(TWEAK_NAME)_LDFLAGS += -lavcodec -lavformat -lavutil -lswresample -lswscale -lavfilter -lavdevice -lpostproc
$(TWEAK_NAME)_LDFLAGS += -lz -lbz2 -liconv
$(TWEAK_NAME)_LIBRARIES = c++

include $(THEOS_MAKE_PATH)/tweak.mk
