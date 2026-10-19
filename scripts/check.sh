#!/usr/bin/env bash
# Checagens da apostila. Exit 0 só se tudo passar.
# Uso: scripts/check.sh   (após scripts/build.sh)
set -u
cd "$(dirname "$0")/.."
fail=0
log=latex/build/apostila.log
blg=latex/build/apostila.blg

if [ ! -f "$log" ]; then
  echo "ERRO: $log não existe; rode scripts/build.sh antes."; exit 1
fi

out=$(grep -nE "(Citation|Reference) .*undefined|There were undefined (references|citations)|Label .* multiply defined" "$log")
if [ -n "$out" ]; then
  echo "ERRO: citações/referências indefinidas em $log:"; echo "$out" | sed 's/^/  /'; fail=1
fi
if [ -f "$blg" ]; then
  out=$(grep -nE "WARN - I didn't find a database entry|ERROR - " "$blg")
  if [ -n "$out" ]; then
    echo "ERRO: biber reporta entradas ausentes/erros em $blg:"; echo "$out" | sed 's/^/  /'; fail=1
  fi
fi

out=$(find latex -name '*.tex' -not -path 'latex/build/*' -print0 | xargs -0 wc -l \
  | awk '$2!="total" && $1>200 {print "  " $2 " (" $1 " linhas)"}')
if [ -n "$out" ]; then
  echo "ERRO: arquivos .tex com mais de 200 linhas (divida em arquivos menores):"; echo "$out"; fail=1
fi

out=$(grep -rnF '\todo' latex --include='*.tex' --exclude-dir=build)
if [ -n "$out" ]; then
  echo "ERRO: \\todo encontrado:"; echo "$out" | sed 's/^/  /'; fail=1
fi

# Onde comprar/baixar: todo livro e paper tem acesso={compra|aberto|pago|esgotado}
# e um link (url, urlgratis ou doi); acesso=pago exige doi.
# Convenção no cabeçalho dos .bib.
out=$(perl -0777 -ne '
  for my $e (split /\n(?=@)/) {
    $e =~ s/^\s*%.*$//mg;   # comentários (cabeçalho) não contam
    next unless $e =~ /^\s*@\w+\s*\{\s*([^,\s]+)\s*,/; my $k = $1;
    next unless $e =~ /\bkeywords\s*=\s*\{[^}]*\b(livro|paper)\b[^}]*\}/i;
    my ($ac) = $e =~ /\bacesso\s*=\s*\{\s*([^}]*?)\s*\}/i;
    if (!defined $ac || $ac !~ /^(compra|aberto|pago|esgotado)$/) { print "  $ARGV: $k sem acesso válido\n" }
    elsif ($ac eq "pago" && $e !~ /\bdoi\s*=\s*\{/i) { print "  $ARGV: $k acesso=pago sem doi\n" }
    elsif ($e !~ /\b(url|urlgratis|doi)\s*=\s*\{/i) { print "  $ARGV: $k sem url/urlgratis/doi\n" }
  }' latex/bib/*.bib)
if [ -n "$out" ]; then
  echo "ERRO: referências sem onde comprar/baixar:"; echo "$out"; fail=1
fi

[ "$fail" -eq 0 ] && echo "check.sh: OK"
exit "$fail"
