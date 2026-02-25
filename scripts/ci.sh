#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAC_GUI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_MAIN_REPO_ROOT="$(cd "$MAC_GUI_DIR/../.." && pwd)"

MAA_MAIN_REPO_ROOT="${MAA_MAIN_REPO_ROOT:-$DEFAULT_MAIN_REPO_ROOT}"
SKIP_MAC_GUI_BUILD="${SKIP_MAC_GUI_BUILD:-0}"

log() {
  printf '\n==> %s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  printf '+ %s\n' "$*"
  "$@"
}

ensure_cmd() {
  has_cmd "$1" || die "Missing required command: $1"
}

detect_core_lib_dir() {
  local dir="$1"

  if [ ! -d "$dir" ]; then
    return 1
  fi

  if [ -n "$(find "$dir" -maxdepth 1 -type f \( -name 'libMaaCore.*' -o -name 'MaaCore.dll' \) -print -quit)" ]; then
    printf '%s' "$dir"
    return 0
  fi

  return 1
}

resolve_core_dir() {
  local core_dir
  core_dir="${MAA_CORE_DIR:-}"

  if [ -n "$core_dir" ]; then
    [ -d "$core_dir" ] || die "MAA_CORE_DIR does not exist: $core_dir"
    printf '%s' "$core_dir"
    return
  fi

  core_dir="$(detect_core_lib_dir "$MAA_MAIN_REPO_ROOT/install" || true)"
  if [ -n "$core_dir" ]; then
    printf '%s' "$core_dir"
    return
  fi

  die "Could not find MaaCore library. Expected one in $MAA_MAIN_REPO_ROOT/install or set MAA_CORE_DIR"
}

resolve_headers_dir() {
  local headers_dir
  headers_dir="${MAA_HEADERS_DIR:-}"

  if [ -n "$headers_dir" ]; then
    [ -d "$headers_dir" ] || die "MAA_HEADERS_DIR does not exist: $headers_dir"
    printf '%s' "$headers_dir"
    return
  fi

  headers_dir="$MAA_MAIN_REPO_ROOT/include"
  [ -d "$headers_dir" ] || die "Could not find MaaCore headers. Expected one in $headers_dir or set MAA_HEADERS_DIR"
  printf '%s' "$headers_dir"
}

resolve_xcframework_output_dir() {
  local output_dir
  output_dir="${MAA_XCFRAMEWORK_OUTPUT_DIR:-$MAA_MAIN_REPO_ROOT/build}"
  printf '%s' "$output_dir"
}

run_macos_gui_build() {
  [ "$SKIP_MAC_GUI_BUILD" = "1" ] && return

  local os
  os="$(uname -s)"
  if [ "$os" != "Darwin" ]; then
    log "Skipping Xcode GUI build on $os"
    return
  fi

  ensure_cmd xcodebuild

  local core_dir headers_dir xcframework_output_dir
  core_dir="$(resolve_core_dir)"
  headers_dir="$(resolve_headers_dir)"
  xcframework_output_dir="$(resolve_xcframework_output_dir)"

  local maa_core_lib maa_utils_lib fastdeploy_lib onnxruntime_lib opencv_lib
  maa_core_lib="$core_dir/libMaaCore.dylib"
  maa_utils_lib="$core_dir/libMaaUtils.dylib"
  fastdeploy_lib="$core_dir/libfastdeploy_ppocr.dylib"
  onnxruntime_lib="$(find "$core_dir" -maxdepth 1 -type f -name 'libonnxruntime*.dylib' -print -quit)"
  opencv_lib="$(find "$core_dir" -maxdepth 1 -type f -name 'libopencv*.dylib' -print -quit)"

  [ -f "$maa_core_lib" ] || die "Missing required library for Xcode build: $maa_core_lib"
  [ -f "$maa_utils_lib" ] || die "Missing required library for Xcode build: $maa_utils_lib"
  [ -f "$fastdeploy_lib" ] || die "Missing required library for Xcode build: $fastdeploy_lib"
  [ -n "$onnxruntime_lib" ] || die "Missing required library for Xcode build: libonnxruntime*.dylib"
  [ -n "$opencv_lib" ] || die "Missing required library for Xcode build: libopencv*.dylib"

  log "Building XCFrameworks for MaaMacGui"
  run mkdir -p "$xcframework_output_dir"
  pushd "$xcframework_output_dir" >/dev/null
  run rm -rf MaaCore.xcframework MaaUtils.xcframework fastdeploy_ppocr.xcframework ONNXRuntime.xcframework OpenCV.xcframework
  run xcodebuild -create-xcframework -library "$maa_core_lib" -headers "$headers_dir" -output MaaCore.xcframework
  run xcodebuild -create-xcframework -library "$maa_utils_lib" -output MaaUtils.xcframework
  run xcodebuild -create-xcframework -library "$fastdeploy_lib" -output fastdeploy_ppocr.xcframework
  run xcodebuild -create-xcframework -library "$onnxruntime_lib" -output ONNXRuntime.xcframework
  run xcodebuild -create-xcframework -library "$opencv_lib" -output OpenCV.xcframework
  popd >/dev/null

  local arch
  arch="$(uname -m)"

  log "Building MaaMacGui with Xcode (no signing, arch=$arch)"
  pushd "$MAC_GUI_DIR" >/dev/null
  run xcodebuild CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS="$arch" -destination "platform=macOS,arch=$arch" -project MeoAsstMac.xcodeproj -scheme MAA -archivePath MAA.xcarchive archive
  popd >/dev/null
}

run_macos_gui_build

log "MaaMacGui CI gate passed"
