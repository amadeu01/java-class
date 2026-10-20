#!/usr/bin/env bash
# Experimentos citados no capítulo cap:por-que, rodados em container JDK 25
# (mesmo padrão --user/HOME do build.sh). Fontes em examples/experimentos.
# Gera, em latex/dados/experimentos/ (cabeçalho # jdk/# cpus/# cpu/# data):
#   verifyerror.txt  classe com aload_1 trocado por iload_1, carregada normalmente
#   noverify.txt     a mesma classe com -Xverify:none
#   vt.txt           10.000 tarefas de 1 s: virtual threads x pool fixo de 200
#   versao.txt       class file 69 (--release 25) e 65 (--release 21) no JDK 25 e no 21
# Depois de rodar de novo, releia as frases que descrevem esses resultados em
# verificacao.tex, threads-vt-loom.tex e objetivos.tex (cap-por-que).
# Uso: scripts/experimentos.sh
set -euo pipefail
cd "$(dirname "$0")/.."
out=latex/dados/experimentos
t=examples/experimentos/target
rm -rf "$t"
mkdir -p "$out" "$t"

roda() { # roda IMAGEM COMANDO: container com o repositório em /work
  local imagem=$1; shift
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$PWD":/work -w /work "$imagem" bash -c "$@"
}

roda eclipse-temurin:25-jdk '
  set -euo pipefail
  t=examples/experimentos/target
  src=examples/experimentos/src/main/java
  java -version 2>&1 | head -1 > $t/jdk.txt
  nproc > $t/cpus.txt
  { grep -m1 "^model name" /proc/cpuinfo || echo "model name: desconhecido"; } \
    | sed "s/^[^:]*: *//" > $t/cpu.txt

  # (a) e (b): VerificacaoTipos compilada e corrompida num byte.
  javac --release 25 -g -d $t/original examples/src/main/java/apostila/bytecode/VerificacaoTipos.java
  javac --release 25 -d $t/classes $src/apostila/experimentos/*.java
  mkdir -p $t/corrompida/apostila/bytecode
  java -cp $t/classes apostila.experimentos.CorrompeVerificacao \
    $t/original/apostila/bytecode/VerificacaoTipos.class \
    $t/corrompida/apostila/bytecode/VerificacaoTipos.class > $t/patch.txt
  set +e
  java -cp $t/corrompida apostila.bytecode.VerificacaoTipos > $t/verifyerror.txt 2>&1
  echo $? > $t/verifyerror.rc
  java -Xverify:none -XX:ErrorFile=/tmp/hs_err_%p.log \
    -cp $t/corrompida apostila.bytecode.VerificacaoTipos > $t/noverify.txt 2>&1
  echo $? > $t/noverify.rc
  set -e

  # (c) virtual threads x pool fixo.
  java -cp $t/classes apostila.experimentos.ThreadsVirtuaisVsPool > $t/vt.txt 2>&1

  # (d) versão do class file: compila para 25 e para 21 e roda no JDK 25.
  javac --release 25 -d $t/v25 $src/apostila/experimentos/VersaoClasse.java
  javac --release 21 -d $t/v21 $src/apostila/experimentos/VersaoClasse.java
  for v in 25 21; do
    echo "\$ java -cp release-$v apostila.experimentos.VersaoClasse   (JDK 25)"
    java -cp $t/v$v apostila.experimentos.VersaoClasse 2>&1 || true
  done > $t/versao-25.txt
'
# (d) as mesmas classes no JDK 21.
roda eclipse-temurin:21-jdk '
  t=examples/experimentos/target
  java -version 2>&1 | head -1 > $t/jdk21.txt
  for v in 25 21; do
    echo "\$ java -cp release-$v apostila.experimentos.VersaoClasse   (JDK 21)"
    java -cp $t/v$v apostila.experimentos.VersaoClasse 2>&1 | head -2 || true
  done > $t/versao-21.txt
'

cabecalho() { # cabecalho DESCRIÇÃO
  echo "# jdk: $(cat "$t/jdk.txt")"
  echo "# cpus: $(cat "$t/cpus.txt")"
  echo "# cpu: $(cat "$t/cpu.txt")"
  echo "# data: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# experimento: $1 (gerado por scripts/experimentos.sh; não edite)"
}
{
  cabecalho "VerificacaoTipos com aload_1 trocado por iload_1, carregada normalmente"
  echo "# troca: $(cat "$t/patch.txt")"
  echo "# código de saída: $(cat "$t/verifyerror.rc")"
  echo
  echo '$ java -cp corrompida apostila.bytecode.VerificacaoTipos'
  cat "$t/verifyerror.txt"
} > "$out/verifyerror.txt"
{
  cabecalho "a mesma classe com -Xverify:none"
  echo "# código de saída: $(cat "$t/noverify.rc")"
  echo
  echo '$ java -Xverify:none -cp corrompida apostila.bytecode.VerificacaoTipos'
  # Só o começo: o aviso e o cabeçalho do erro fatal (o resto varia por execução;
  # a linha do core dump depende da configuração do host e fica de fora).
  grep -vE '^#[[:space:]]*$|^# Core dump' "$t/noverify.txt" | head -11
} > "$out/noverify.txt"
{
  cabecalho "10.000 tarefas de 1 s, virtual threads x newFixedThreadPool(200)"
  echo
  cat "$t/vt.txt"
} > "$out/vt.txt"
{
  cabecalho "class file compilado com --release 25 e 21, executado no JDK 25 e no 21"
  echo "# jdk 21: $(cat "$t/jdk21.txt")"
  echo
  cat "$t/versao-25.txt" "$t/versao-21.txt"
} > "$out/versao.txt"

echo "experimentos.sh: $(ls "$out" | tr '\n' ' ')"
