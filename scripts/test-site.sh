#!/usr/bin/env bash
# Valida public/ gerado por scripts/build-site.sh. Uso: scripts/test-site.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
err() { echo "FAIL: $*" >&2; fail=1; }
idx=public/index.html
if [ ! -f "$idx" ]; then echo "FAIL: public/index.html não existe" >&2; exit 1; fi
grep -q 'Testes na prática, Java e a JVM' "$idx" || err "título da apostila ausente"
grep -q 'href="apostila.pdf"' "$idx" || err "link para apostila.pdf ausente"
grep -q 'href="apostila-latex.zip"' "$idx" || err "link para apostila-latex.zip ausente"
grep -q 'id="changelog"' "$idx" || err "seção de changelog ausente"
grep -q 'Não lançado\|\[[0-9]\+\.[0-9]\+\.[0-9]\+\]' "$idx" || err "changelog sem conteúdo"
# arquivos locais linkados (href/src relativos) existem
while IFS= read -r ref; do
  case "$ref" in http*|'#'*|mailto:*|'') continue ;; esac
  [ -e "public/${ref%%#*}" ] || err "arquivo linkado não existe: $ref"
done < <(grep -o '\(href\|src\)="[^"]*"' "$idx" | sed 's/^[a-z]*="//;s/"$//')
[ "$fail" -eq 0 ] && echo "test-site: OK"
exit "$fail"
