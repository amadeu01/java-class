#!/usr/bin/env bash
# Gera latex/build/apostila.pdf em container texlive (igual ao CI).
# Uso: scripts/build.sh   (sem argumentos)
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -x scripts/gen-bytecode.sh ]; then
  scripts/gen-bytecode.sh
else
  echo "build.sh: scripts/gen-bytecode.sh ausente; pulando bytecode"
fi
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$PWD":/work -w /work/latex texlive/texlive:latest \
  latexmk -interaction=nonstopmode -halt-on-error main.tex
echo "PDF: latex/build/apostila.pdf"
