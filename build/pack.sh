#!/usr/bin/env bash
# pack.sh — the NuGet package of GlyphAura: dist/nupkg/GlyphAura.<version>.nupkg
#
#   bash build/pack.sh [version]        # default: the version of the project
#
# Nothing is published; the release workflow uploads what this makes.  FSharp.Graphics.Host (fsharp-wasm-graphics) names this package by the version it was built with,
# so a release here carries the same version as the one there.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist/nupkg"
VERSION_ARG=()
[[ $# -gt 0 ]] && VERSION_ARG=("-p:Version=$1")
rm -rf "$OUT"; mkdir -p "$OUT"
dotnet pack "$ROOT/src/GlyphAura/GlyphAura.fsproj" -c Release "${VERSION_ARG[@]}" -o "$OUT" --nologo -v q
ls -1 "$OUT"
