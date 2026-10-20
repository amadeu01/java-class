#!/usr/bin/env bash
# Benchmark JMH de contenção (synchronized x AtomicLong x LongAdder).
# Constrói examples/bench e roda em container JDK 25 (mesmo padrão do build.sh).
# Gera latex/dados/bench/contencao.txt (cabeçalho + tabelas do JMH) e
# latex/dados/bench/contencao-tabela.tex (tabular gerado a partir do .txt).
# Uso: scripts/bench.sh
#   JMH_OPTS="-wi 1 -i 1 -r 1s" scripts/bench.sh   # teste rápido de fiação
#   scripts/bench.sh --tabela   # só regera o .tex a partir do .txt existente
set -euo pipefail
cd "$(dirname "$0")/.."
opts=${JMH_OPTS:-"-wi 3 -i 5 -f 1"}
out=latex/dados/bench
mkdir -p "$out"

if [ "${1:-}" != "--tabela" ]; then
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e JMH_OPTS="$opts" \
  -v "$PWD":/work -w /work/examples/bench maven:3-eclipse-temurin-25 bash -c '
    set -euo pipefail
    mvn -q -B -Dmaven.repo.local=target/.m2 package
    java -version 2>&1 | head -1 > target/jdk.txt
    nproc > target/cpus.txt
    { grep -m1 "^model name" /proc/cpuinfo || echo "model name: desconhecido"; } \
      | sed "s/^[^:]*: *//" > target/cpu.txt
    for t in 1 8; do
      java -jar target/benchmarks.jar Contencao -t "$t" $JMH_OPTS \
        -rf text -rff "target/jmh-t$t.txt"
    done
  '

b=examples/bench/target
{
  echo "# jdk: $(cat "$b/jdk.txt")"
  echo "# cpus: $(cat "$b/cpus.txt")"
  echo "# cpu: $(cat "$b/cpu.txt")"
  echo "# data: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# jmh: $opts -rf text (imagem maven:3-eclipse-temurin-25)"
  for t in 1 8; do
    echo
    echo "## threads: $t"
    cat "$b/jmh-t$t.txt"
  done
} > "$out/contencao.txt"
fi
[ -f "$out/contencao.txt" ] || { echo "bench.sh: $out/contencao.txt ausente" >&2; exit 1; }

# Tabela LaTeX gerada do .txt: nunca editar à mão.
awk '
  # Escapa caracteres especiais do LaTeX em texto vindo do cabeçalho.
  function tex(x) {
    gsub(/\\/, "\001", x)
    gsub(/[&%$#_{}]/, "\\\\&", x)
    gsub(/~/, "\\textasciitilde{}", x)
    gsub(/\^/, "\\textasciicircum{}", x)
    gsub(/\001/, "\\textbackslash{}", x)
    return x
  }
  # Vírgula decimal (pt-BR) nos números do JMH.
  function dec(x) { sub(/\./, "{,}", x); return x }
  BEGIN {
    print "% Gerado por scripts/bench.sh a partir de contencao.txt. Não edite."
    print "\\begin{tabular}{@{}llrrr@{}}"
    print "\\toprule"
    print "Benchmark & Modo & Threads & Score (ops/\\textmu{}s) & Erro ($\\pm$) \\\\"
    print "\\midrule"
  }
  /^# jdk:/  { sub(/^# jdk: */, ""); gsub(/"/, ""); jdk = tex($0); next }
  /^# cpus:/ { cpus = tex($3); next }
  /^# cpu:/  { sub(/^# cpu: */, ""); cpu = tex($0); next }
  /^# jmh:/  { sub(/^# jmh: */, ""); sub(/ \(imagem.*/, ""); jmh = tex($0); next }
  /^## threads:/ { t = $3; if (n++) print "\\addlinespace"; next }
  /^Contencao\./ {
    name = $1; sub(/^Contencao\./, "", name)
    if ($NF != "ops/us") { print "bench.sh: unidade inesperada: " $NF > "/dev/stderr"; exit 1 }
    pm = 0; for (i = 3; i <= NF; i++) if ($i == "±") pm = i
    score = dec(pm ? $(pm - 1) : $(NF - 1))
    err = pm ? dec($(pm + 1)) : "--"
    printf "\\texttt{%s} & \\texttt{%s} & %s & %s & %s \\\\\n", name, $2, t, score, err
  }
  END {
    print "\\bottomrule"; print "\\end{tabular}"
    printf "\\\\[1ex]{\\footnotesize %s; %s CPUs lógicas (%s); JMH \\texttt{%s}.}\n", jdk, cpus, cpu, jmh
  }
' "$out/contencao.txt" > "$out/contencao-tabela.tex"

echo "bench.sh: $out/contencao.txt e $out/contencao-tabela.tex"
