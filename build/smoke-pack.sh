#!/usr/bin/env bash
# smoke-pack.sh — the package as a consumer sees it: a new project that restores it from dist/nupkg (and nothing else of this repository) and runs.
#
#   bash build/smoke-pack.sh <version>      # after `bash build/pack.sh <version>`
#
# It checks what a unit test cannot: that the package restores, that the dll loads, and that the sources are in the package where the compiler of fsharp-wasm looks for them
# (fable/).  The packages cache is the temporary folder's own, so a package of the same version from an earlier run cannot be what is tested.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:?usage: smoke-pack.sh <version>}"
DIR="$(mktemp -d)"; trap 'rm -rf "$DIR"' EXIT
export NUGET_PACKAGES="$DIR/packages"
cd "$DIR"
cat > nuget.config <<XML
<configuration><packageSources><clear/><add key="local" value="$ROOT/dist/nupkg"/><add key="nuget.org" value="https://api.nuget.org/v3/index.json"/></packageSources></configuration>
XML
cat > Smoke.fsproj <<XML
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net10.0</TargetFramework></PropertyGroup>
  <ItemGroup>
    <Compile Include="Program.fs" />
    <PackageReference Include="GlyphAura" Version="$VERSION" />
  </ItemGroup>
</Project>
XML
cat > Program.fs <<'FS'
let asm = System.Reflection.Assembly.Load("GlyphAura")
if asm.GetTypes().Length = 0 then (eprintfn "GlyphAura has no types"; exit 1)
printfn "%s %s: %d types" (asm.GetName().Name) (asm.GetName().Version.ToString()) (asm.GetTypes().Length)
FS
dotnet run -c Release --nologo -v q
ls "$NUGET_PACKAGES/glyphaura/$VERSION/fable/"*.fsproj > /dev/null || { echo "GlyphAura: no sources under fable/" >&2; exit 1; }
echo "smoke: the package restores, loads and carries its sources"
