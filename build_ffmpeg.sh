#!/bin/bash
# build_ffmpeg.sh - Builds mobile-ffmpeg audio variant for iOS arm64
# Run this on macOS with Xcode command line tools installed
#
# Usage: ./build_ffmpeg.sh
# Output: FFmpeg/lib/*.a and FFmpeg/include/
#
# Prerequisites:
#   - macOS with Xcode (or command line tools)
#   - autoconf, automake, libtool, pkg-config (brew install autoconf automake libtool pkg-config)
#   - gas-preprocessor.pl (brew install gas-preprocessor)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="/tmp/mobile-ffmpeg-build"
FFMPEG_DIR="$SCRIPT_DIR/FFmpeg"
OUTPUT_LIB="$FFMPEG_DIR/lib"
OUTPUT_INCLUDE="$FFMPEG_DIR/include"

IOS_MIN_VERSION="13.0"
ARCH="arm64"

echo "=== Building mobile-ffmpeg (audio variant) for iOS arm64 ==="
echo "Build directory: $BUILD_DIR"
echo "Output: $FFMPEG_DIR/{lib,include}"

# Check prerequisites
if ! command -v xcrun &> /dev/null; then
    echo "Error: Xcode command line tools required. Install with: xcode-select --install"
    exit 1
fi

SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null)
if [ -z "$SDK_PATH" ]; then
    echo "Error: iOS SDK not found"
    exit 1
fi
echo "Using SDK: $SDK_PATH"

CC=$(xcrun --sdk iphoneos --find clang)
echo "Using compiler: $CC"

# Clone FFmpeg source
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -d "ffmpeg" ]; then
    echo "=== Cloning FFmpeg 4.4 ==="
    git clone --depth 1 --branch n4.4 https://github.com/FFmpeg/FFmpeg.git ffmpeg
fi

FFMPEG_SRC="$BUILD_DIR/ffmpeg"
FFMPEG_BUILD="$BUILD_DIR/build-ios-arm64"

mkdir -p "$FFMPEG_BUILD"
cd "$FFMPEG_SRC"

echo "=== Configuring FFmpeg ==="

CFLAGS="-arch arm64 -isysroot $SDK_PATH -miphoneos-version-min=$IOS_MIN_VERSION -Oz -DMOBILE_FFMPEG_LTS"
LDFLAGS="-arch arm64 -isysroot $SDK_PATH -miphoneos-version-min=$IOS_MIN_VERSION"

./configure \
    --prefix="$FFMPEG_BUILD" \
    --enable-cross-compile \
    --target-os=darwin \
    --arch=aarch64 \
    --sysroot="$SDK_PATH" \
    --cc="$CC" \
    --extra-cflags="$CFLAGS" \
    --extra-ldflags="$LDFLAGS" \
    --enable-pic \
    --enable-static \
    --disable-shared \
    --enable-small \
    --disable-doc \
    --disable-programs \
    --disable-debug \
    --disable-network \
    --disable-autodetect \
    --enable-videotoolbox \
    --enable-audiotoolbox \
    --disable-openssl \
    --disable-securetransport \
    --disable-xlib \
    --disable-sdl2 \
    --disable-txtpages \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-swresample \
    --enable-swscale \
    --enable-avfilter \
    --enable-avdevice \
    --enable-postproc

echo "=== Building FFmpeg ==="
make -j$(sysctl -n hw.ncpu) 2>&1 | tail -5
make install

echo "=== Copying output ==="
mkdir -p "$OUTPUT_LIB" "$OUTPUT_INCLUDE"

# Copy static libraries
cp "$FFMPEG_BUILD/lib/"*.a "$OUTPUT_LIB/"

# Copy headers
cp -r "$FFMPEG_BUILD/include/"* "$OUTPUT_INCLUDE/"

# Copy config.h (needed by fftools)
cp "$FFMPEG_SRC/config.h" "$OUTPUT_INCLUDE/"

echo ""
echo "=== Build complete ==="
echo "Static libraries:"
ls -la "$OUTPUT_LIB/"
echo ""
echo "Headers in: $OUTPUT_INCLUDE/"
echo ""
echo "Now run 'make package' to build the tweak."
