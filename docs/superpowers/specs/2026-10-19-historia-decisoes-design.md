# História das decisões do Java e da JVM — documento de design

Data: 2026-10-19 · Pedido do Amadeu · Continua o design `2026-10-18-apostila-java-design.md` (todas as restrições de lá valem aqui).

## 1. Intenção e porquê

O aluno deve entender **por que** o Java e a JVM são como são: cada decisão de arquitetura da linguagem e da VM tem uma razão histórica, e essa razão muda a forma como ele escreve código hoje. Com isso ele decide melhor ao arquitetar uma aplicação Java/Quarkus, ao escrever código e, principalmente, ao resolver os problemas de concorrência do dia a dia:

- receber muitos requests ao mesmo tempo;
- compartilhar memória entre threads;
- aproveitar vários núcleos (multiprocessamento).

A história não é curiosidade: cada seção termina em "o que isso muda no seu código".

## 2. Fontes (direção do Amadeu)

Duas obras são a referência para conferir todos os dados históricos:

- **Tim Lindholm e Frank Yellin, *The Java Virtual Machine Specification*, 2ª ed. (Addison-Wesley, 1999)** — já está no `.bib` como `livro:lindholm1999`.
- **James Gosling, Bill Joy, Guy Steele e Gilad Bracha, *The Java Language Specification*, 2ª ed. (Addison-Wesley, 2000)** — entrada nova.

Regras:

1. Afirmação sobre como o Java **era** (1.0 a 1.4) é conferida no texto da JLS/JVMS 2ª ed., citando capítulo e seção.
2. Afirmação sobre como o Java **é** é conferida na JLS/JVMS SE 25 (`doc:jls25`, `doc:jvms25`).
3. "Antes e depois" mostra a mesma seção nas duas edições quando a regra mudou.
4. Fontes secundárias, em ordem de peso: JSRs (jcp.org) e JEPs; papers de revistas e conferências sérias (ACM, IEEE, Wiley, Springer) e teses (MIT, Maryland etc.); páginas e blogs dos próprios autores; histórico do código no GitHub (`openjdk/jdk`); benchmarks reproduzíveis (JMH, TechEmpower). **Wikipedia só como ponto de partida**, nunca como única fonte de uma afirmação.
5. Onde achar cada obra segue a regra do `.bib` de sempre (`acesso`, `url`, `urlgratis`, `doi`). As edições 2ª da JLS e da JVMS têm HTML oficial antigo (java.sun.com, hoje espelhado pela Oracle ou no Internet Archive); o builder confere qual link funciona.
6. Nada entra sem ter sido aberto e conferido nesta rodada (título, autor, data, e o trecho que sustenta a frase).

## 3. O que será feito

### 3.1 Capítulo novo na Parte II: "Por que o Java é assim"

Primeiro capítulo da Parte II, antes de "Java moderno". Uma decisão por seção, cada uma com: o problema da época → a decisão (com a citação da especificação) → o que mudou depois → o que isso muda no seu código → onde a apostila aprofunda.

Seções previstas (a ordem e os cortes finos ficam com o builder):

1. **Os objetivos de 1995:** o white paper *The Java Language Environment* (Gosling e McGilton, já no `.bib`): simples, robusto, seguro, neutro de arquitetura, multithreaded. Por que bytecode, verificador, GC e nada de ponteiros.
2. **Bytecode e verificação:** máquina de pilha e verificação de tipos (JVMS 2ª ed., cap. 4) → verificador por StackMapTable (JVMS SE 25 §4.10). O que isso garante e o que não garante.
3. **Threads e monitores desde o 1.0:** `synchronized`, `wait`/`notify` (JLS 2ª ed., cap. 17; JVMS 2ª ed., cap. 8), a origem em Hoare e Brinch Hansen e a crítica de Brinch Hansen ao Java (1999). No código: `wait` sempre em laço, monitor por objeto, `monitorenter`/`monitorexit` no bytecode.
4. **Green threads, threads nativas e virtual threads:** das threads gerenciadas pela VM às do sistema operacional e de volta às virtual threads (JEP 444). O que cada mudança fez com o modelo "uma thread por request".
5. **O modelo de memória que estava errado:** cap. 17 da JLS 2ª ed. lado a lado com o §17.4 atual (JSR-133, Java 5); o paper de Pugh sobre as falhas do modelo antigo; a declaração "Double-Checked Locking is Broken"; Manson, Pugh e Adve (POPL 2005, já no `.bib`). No código: `volatile`, campos `final`, publicação segura, *happens-before*.
6. **`java.util.concurrent`:** do pacote de Doug Lea ao JSR-166 (Java 5), o framework de sincronizadores (AQS), Fork/Join (Java 7), `CompletableFuture` e streams paralelos (Java 8). No código: executors em vez de `new Thread`, coleções concorrentes, `LongAdder`, quando paralelizar.
7. **Muitos requests:** thread por request dos Servlets, o problema C10K, NIO (JSR 51, Java 1.4), o modelo reativo e o Loom. Ligação com Quarkus (Vert.x, `@RunOnVirtualThread`) e com a seção `sec:vt-vs-reativo`.

GC, JIT/HotSpot e a herança do Self já estão em "JVM por dentro" e na Parte IV: aqui entram só como referência cruzada, sem repetir.

**Seção 4 em detalhe (pedido do Amadeu: "como avançou para o modelo de virtual threads?").** A sequência a contar, cada passo conferido nas fontes da §2:

1. Green threads nos primeiros JDKs (threads da VM sobre uma thread do sistema; sem uso de vários núcleos).
2. Threads nativas 1:1 (JDK 1.2/1.3, HotSpot): usam vários núcleos, mas cada thread custa uma pilha do sistema e troca de contexto no kernel; "uma thread por request" para em alguns milhares.
3. A saída assíncrona: NIO (JSR 51, Java 1.4), Netty, RxJava, Reactive Streams e `java.util.concurrent.Flow` (Java 9). Escala, mas o código fica difícil de ler e depurar.
4. Bibliotecas de fibers sobre a JVM (Quasar, com instrumentação de bytecode), o Project Loom (2017, Ron Pressler) com continuations dentro da JVM, o nome "fibers" trocado por virtual threads.
5. JEP 425 (preview, JDK 19) → JEP 436 (JDK 20) → JEP 444 (final, JDK 21) → JEP 491 (JDK 24, fim do pinning em `synchronized`). Como funciona: M:N, carriers num `ForkJoinPool`, a pilha copiada para o heap ao desmontar.

### 3.1.1 Perguntas que o conteúdo precisa responder

Pedido do Amadeu: o material (capítulo novo ou capítulos existentes, com referência cruzada) responde explicitamente cada pergunta abaixo, com fonte. Onde um capítulo existente já responde, a revisão da §3.3 confere e completa lá, sem duplicar.

1. Como a JVM decide entre interpretador, JIT e AOT? Qual o impacto real do *startup time* com compilação dinâmica × estática? (JVM por dentro; Parte IV JIT × AOT; Quarkus nativo × JVM.)
2. Como ZGC e Shenandoah reduzem as pausas *stop-the-world* em comparação com os coletores generacionais tradicionais? (JVM por dentro, GC.)
3. A hipótese de coleta de lixo local por thread (heaps por thread) é viável na prática? O que a pesquisa mostrou, o que o HotSpot faz em vez disso (TLABs) e como a BEAM faz com um heap por processo. (JVM por dentro e Parte IV, GC.)
4. Como o bytecode é verificado antes da execução para garantir segurança de memória? (Seção 2 do capítulo novo; JVMS.)
5. O que acontece quando o verificador é desativado (`-Xverify:none`/`-noverify`, depreciados no JDK 13)? (Seção 2.)
6. Como as virtual threads mudam o custo de escalar em comparação com o modelo 1:1 de threads nativas? (Seção 4, com número medido ou publicado.)
7. Como o Java chegou às virtual threads? (Seção 4, sequência acima.)

**Bytecode:** onde a decisão aparece no `.class`, mostrar com `javap` pelo mecanismo existente (`examples/` + `scripts/bytecode-list.txt` + `\inputbytecode`). Exemplos prováveis: campo `volatile` (`ACC_VOLATILE`), campo `final` e publicação segura, `wait` em laço.

**Benchmark:** um benchmark JMH pequeno e reproduzível sobre contenção (`synchronized` × `AtomicLong` × `LongAdder`), rodado em container como o resto do build, com a máquina e a versão do JDK impressas junto dos números e o aviso de que os números são daquela máquina. Benchmarks publicados (TechEmpower, números dos JEPs) entram com ficha, como na Parte IV.

### 3.2 Linha do tempo (PR #2)

O trabalho parte do branch do PR #2 (`feat/linha-do-tempo`) e o incorpora: a seção E.2 fica, as notas "conferido" são reconferidas pelas regras da §2, e cada fase aponta para a seção correspondente do capítulo novo. A minutagem continua vindo das notas do Amadeu (não é reconferida no vídeo).

### 3.3 Revisão de tudo

Peer review multiagente, como o de 2026-10-19, com foco novo: toda afirmação técnica das Partes II a IV e do apêndice "Quem fez o Java" conferida contra a JLS/JVMS SE 25 (o que é) e a 2ª ed. (o que era). Correções aplicadas e registradas em `docs/peer-review/`.

### 3.4 Publicação

CHANGELOG em `[Não lançado]`, PR único com tudo. Merge e tag (`v0.2.0`) só quando o Amadeu pedir.

## 4. Objetivos, não objetivos, anti-objetivos

- **Objetivo:** o aluno consegue explicar, para cada problema de concorrência comum, que decisão do Java está por trás dele e qual ferramenta atual usar.
- **Não objetivo:** história completa do Java (versões, marketing, disputas comerciais). Só entra o que explica uma decisão técnica.
- **Não objetivo:** reescrever capítulos que já estão certos.
- **Anti-objetivo:** uma data, versão ou citação errada, ou uma afirmação sustentada só pela Wikipedia ou pela memória do modelo.
- **Anti-objetivo:** história sem o "o que isso muda no seu código".

## 5. Restrições (herdadas)

pt-BR com termos em inglês e `\termo` para explicar; arquivos `.tex` ≤ 200 linhas; `check.sh` verde (citações, `acesso`, links); CI verde; nenhum dado pessoal do Amadeu enviado a serviço externo; o `.md` de `~/Downloads` não é commitado.

## 6. Decisões minhas (Claude), para o Amadeu conferir

1. **Capítulo próprio no início da Parte II**, e não espalhado: a história lida em sequência explica melhor o porquê; os outros capítulos ganham referências cruzadas. Custo se errado: mover seções.
2. **Construir em cima do PR #2** em vez de mergear antes: um só PR revisado. Custo: o PR #2 fica aberto até lá.
3. **Benchmark JMH próprio**, além dos publicados: mostra a contenção na prática. Custo: o build ganha um passo (rodado fora do CI de PDF, com resultado commitado).
4. **Escopo da revisão:** Partes II a IV e o apêndice "Quem fez o Java"; a Parte I (testes) não é tocada, porque não depende das especificações.

5. **Benchmark JMH:** projeto Maven em `examples/bench/`, rodado por um script novo (`scripts/bench.sh`) num container JDK 25 (Temurin, mesma versão do bytecode). A saída vai para um arquivo de resultados commitado, com a máquina e o JDK no cabeçalho. O PDF só lê esse arquivo, nunca roda o JMH. Ele é regenerado à mão, quando o texto do benchmark muda, e não a cada release. Custo se errado: os números envelhecem até alguém rodar o script de novo.
6. **Branch:** os commits novos entram no próprio `feat/linha-do-tempo`. O PR #2 cresce, ganha um título novo e vira o PR único.
7. **Afirmação sem fonte aberta:** sai do texto. Não usar `\naoverificado` neste capítulo, já que o objetivo é justamente conferir. Uma fonte disponível só no Internet Archive vale, com o link oficial impresso. Custo: alguma seção pode ficar mais curta.
8. **Linha do tempo:** reconfiro as notas "conferido" e os fatos ligados ao capítulo novo. A minutagem e o resumo do filme ficam como estão.
9. **Citação das especificações:** trechos curtos, de até duas linhas, e o resto em paráfrase com o número da seção. O "antes e depois" é uma tabela de duas colunas (2ª ed. × SE 25).
10. **Revisão:** uma passada nova, não só um delta da revisão anterior, focada nas afirmações que dependem das especificações, nas Partes II a IV e no apêndice "Quem fez o Java". Fica dentro do tamanho usual de workflow, com menos de 10 agentes.
11. **Bibliografia:** arquivo novo `latex/bib/historia.bib`. As entradas que já existem não são duplicadas.

## 7. Deixado para o builder

Divisão das seções em arquivos, títulos finais, quais exemplos de bytecode, o link exato de cada edição antiga, e como o benchmark é disparado.
