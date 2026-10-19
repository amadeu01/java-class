#!/usr/bin/env bash
# Compila examples/ (JDK 25) e gera listagens javap e fontes em latex/generated/.
# Uso: scripts/gen-bytecode.sh   (sem argumentos)
# Classe aninhada na lista: Externa$Interna -> arquivo Externa_Interna.txt
# Usa javac/javap do PATH se forem 25; senão, container eclipse-temurin:25-jdk.
set -euo pipefail
cd "$(dirname "$0")/.."

SRC=examples/src/main/java
OUT=out/examples
PKG=apostila/bytecode
LIST=scripts/bytecode-list.txt

versao() { "$@" -version 2>&1 | sed -n 's/^javac \([0-9]*\).*/\1/p'; }

if command -v javac >/dev/null && [ "$(versao javac)" = "25" ]; then
  jdk() { "$@"; }
else
  echo "gen-bytecode: javac 25 ausente no PATH; usando eclipse-temurin:25-jdk"
  jdk() {
    docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
      -v "$PWD":/work -w /work eclipse-temurin:25-jdk "$@"
  }
fi
[ "$(versao jdk javac)" = "25" ] || { echo "gen-bytecode: JDK 25 obrigatório" >&2; exit 1; }

rm -rf "$OUT" latex/generated/bytecode latex/generated/source
mkdir -p "$OUT" latex/generated/bytecode latex/generated/source
jdk javac --release 25 -g -d "$OUT" "$SRC/$PKG"/*.java

while read -r classe flags; do
  case "$classe" in ''|'#'*) continue ;; esac
  flags=${flags:--c -p}
  # shellcheck disable=SC2086
  jdk javap $flags -cp "$OUT" "apostila.bytecode.$classe" > "latex/generated/bytecode/${classe//\$/_}.txt"
  cp "$SRC/$PKG/${classe%%\$*}.java" "latex/generated/source/${classe%%\$*}.java"
  echo "gerado: $classe ($flags)"
done < "$LIST"
