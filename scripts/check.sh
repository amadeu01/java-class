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

# O último build tem de ter dado certo: sem erro TeX e com PDF gerado.
if grep -qE '^! |^No pages of output|Emergency stop' "$log" || ! grep -q '^Output written on' "$log"; then
  echo "ERRO: o último build falhou (veja $log); corrija e rode scripts/build.sh."; exit 1
fi
# E tem de ser mais novo que as fontes; o .blg, mais novo que os .bib.
newer=$(find latex -path latex/build -prune -o \( -name '*.tex' -o -name '*.bib' -o -name '*.dbx' -o -name latexmkrc \) -newer "$log" -print)
if [ -n "$newer" ]; then
  echo "ERRO: $log é anterior às fontes; rode scripts/build.sh. Mais novos:"; echo "$newer" | sed 's/^/  /'; exit 1
fi
if [ -f "$blg" ]; then
  newer=$(find latex/bib -name '*.bib' -newer "$blg" -print)
  if [ -n "$newer" ]; then
    echo "ERRO: $blg é anterior aos .bib; rode scripts/build.sh. Mais novos:"; echo "$newer" | sed 's/^/  /'; exit 1
  fi
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

# Resultado do benchmark de contenção (seção sec:juc): gerado por scripts/bench.sh.
bench=latex/dados/bench/contencao.txt
if [ ! -f "$bench" ]; then
  echo "ERRO: $bench não existe; rode scripts/bench.sh e versione o resultado."; fail=1
elif ! grep -q '^# jdk:' "$bench"; then
  echo "ERRO: $bench sem a linha '# jdk:' no cabeçalho; gere de novo com scripts/bench.sh."; fail=1
fi

# Saídas dos experimentos do capítulo cap:por-que: geradas por scripts/experimentos.sh.
for exp in verifyerror noverify vt versao; do
  f=latex/dados/experimentos/$exp.txt
  if [ ! -f "$f" ]; then
    echo "ERRO: $f não existe; rode scripts/experimentos.sh e versione o resultado."; fail=1
  elif ! grep -q '^# jdk:' "$f"; then
    echo "ERRO: $f sem a linha '# jdk:' no cabeçalho; gere de novo com scripts/experimentos.sh."; fail=1
  fi
done

# Glossário: todo \termo{...} da apostila tem uma linha no apêndice (inglês ou
# português na 1ª/2ª coluna, sem diferenciar maiúsculas; "X (sigla)" casa com X).
out=$(find latex -name '*.tex' -not -path 'latex/build/*' -not -path 'latex/preamble/*' -print0 \
  | xargs -0 perl -0777 -e '
    my %k;
    for my $g (glob "latex/apendices/glossario*.tex") {
      open my $h, "<", $g or die; local $/ = "\n";
      while (<$h>) {
        next unless /^\\textit\{((?:[^{}]|\{[^}]*\})*)\}\s*&\s*([^&]*?)\s*&/;
        my ($en, $pt) = (lc $1, lc $2); $k{$en} = $k{$pt} = 1;
        (my $s = $en) =~ s/\s*\(.*\)\s*$//; $k{$s} = 1;
        $k{lc $1} = 1 if $en =~ /\(([^)]*)\)/;
      }
    }
    $k{desmonta} = 1;   # flexão de "desmontar" (unmount)
    for my $f (@ARGV) {
      open my $h, "<", $f or die; my $t = <$h>;
      while ($t =~ /\\termo\s*(\{((?:[^{}]++|(?1))*)\})/g) {
        (my $a = $2) =~ s/\s+/ /g;
        print "  $f: $a\n" unless $k{lc $a};
      }
    }')
if [ -n "$out" ]; then
  echo "ERRO: \\termo sem linha no glossário (latex/apendices/glossario.tex):"; echo "$out"; fail=1
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
