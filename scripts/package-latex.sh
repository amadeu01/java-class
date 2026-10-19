#!/usr/bin/env bash
# Empacota fonte LaTeX, exemplos e scripts de build (sem arquivos gerados).
# Uso: scripts/package-latex.sh VERSAO   -> dist/apostila-latex-VERSAO.zip
# O zip descompactado compila sozinho com scripts/build.sh (precisa de Docker).
set -euo pipefail
cd "$(dirname "$0")/.."
[ $# -eq 1 ] || { echo "uso: $0 VERSAO" >&2; exit 2; }
v="$1"
mkdir -p dist
out="dist/apostila-latex-$v.zip"
rm -f "$out"
# git archive usa só arquivos versionados: latex/generated e latex/build ficam de fora.
# latexmkrc fica em latex/.
git archive --format=zip --prefix="apostila-latex-$v/" -o "$out" HEAD \
  latex examples scripts README.md LICENSE
echo "$out"
