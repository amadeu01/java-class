# Changelog

Todas as mudanças relevantes da apostila ficam neste arquivo.
O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e as versões seguem o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado

- Linha do tempo do documentário *The Java Story* no apêndice "Quem fez o Java": as fases do Oak ao Project Loom com a minutagem do vídeo, por que o J2EE quase fracassou, e as datas conferidas nas fontes primárias onde o filme arredonda (JCP em 1998, não 1999; um JDK compilável por completo sob GPL em maio de 2007; virtual threads finais no JDK 21), cada nota com a fonte (comunicados da Sun, da Microsoft e da Oracle, blog de Mark Reinhold, JEP 322 e as páginas do Tomcat, do Hibernate e do Spring), e cada fase aponta para a seção correspondente do capítulo "Por que o Java é assim".
- Parte II, capítulo novo "Por que o Java é assim", com foco em concorrência (muitos requests, memória compartilhada, vários núcleos): objetivos de projeto, verificação do bytecode, monitores e `wait`/`notify`, de threads de plataforma a virtual threads, o modelo de memória e a JSR 133, `java.util.concurrent` e servidores com muitos requests. Cada seção conta o problema da época, a decisão (com a seção da JLS/JVMS 2ª ed.), o que mudou até o Java SE 25 e o que isso muda no seu código; listagens `javap` de `VerificacaoTipos`, `EsperaEmLaco` e `PublicacaoSegura`; "Onde aprofundar" e desafios práticos.
- Benchmark JMH de contenção (`synchronized` × `AtomicLong` × `LongAdder`, com 1 e 8 threads), rodado em container por `scripts/bench.sh`, com JDK, CPUs e máquina impressos junto dos números; o `check.sh` falha se `latex/dados/bench/contencao.txt` não existir ou não tiver o cabeçalho `# jdk:`.
- Perguntas respondidas nos capítulos que já tratavam do assunto: como a HotSpot decide entre interpretador, JIT e AOT e o efeito no startup (seção do JIT); como ZGC e Shenandoah encurtam as pausas stop-the-world (seção de GC); e se um heap por thread funciona, com os resultados de Steensgaard (2000) e Domani et al. (2002), o TLAB da HotSpot e o heap por processo da BEAM (seção de GC, com ponte para a Parte IV).
- Experimentos reproduzíveis do capítulo "Por que o Java é assim": `scripts/experimentos.sh` roda em container os programas de `examples/experimentos` (bytecode com `aload_1` trocado por `iload_1`, carregado normalmente e com `-Xverify:none`; 10.000 tarefas de 1 s com virtual threads e com um pool fixo de 200 threads; class file compilado para o JDK 25 e para o 21, executado nos dois) e grava as saídas em `latex/dados/experimentos/`, com JDK, CPUs, processador e data no cabeçalho; o texto inclui esses arquivos em vez de números digitados, e o `check.sh` falha se algum faltar ou não tiver o cabeçalho `# jdk:`.
- Glossário com todos os termos explicados em nota de rodapé no capítulo novo, nas seções novas e na linha do tempo; o `check.sh` falha se um `\termo` ficar sem linha no glossário.

### Corrigido

Fatos do texto da 0.1.0 corrigidos na revisão por pares do capítulo novo (relatório em `docs/peer-review/2026-10-19-historia.md`):

- G1 não é o padrão em toda máquina: no JDK 25 a ergonomia escolhe o G1 só em máquinas server-class (duas ou mais CPUs e ao menos 1792 MB de memória) e o Serial nas outras. Corrigido na seção de GC da Parte II e na nota do G1 do "Onde aprofundar" dela, em "Memória em container" (Parte III) e na comparação de GC e na tabela-resumo da Parte IV.
- Conselho para container reescrito: com poucos recursos a JVM já escolhe o Serial; para usar o G1 é preciso `-XX:+UseG1GC`; e `-Xlog:gc` mostra qual coletor foi escolhido.
- `contador++` ocupa os offsets 4 a 11 (`aload_0` e `dup` antes do `getfield` no 6, `putfield` no 11), não 6 a 11 (seção do modelo de memória).
- O modelo de memória não diz que um programa sem data race "se comporta como se fosse sequencial": a seção agora dá a definição de execução sequencialmente consistente (JLS §17.4.3) e a garantia para programas corretamente sincronizados (§17.4.5).
- `invokedynamic`: a regra de que o bootstrap não é chamado de novo está na JVMS §5.4.3 (a chamada do bootstrap é a §5.4.3.6), não na §5.4.3.6.
- O conselho do lock privado em "Sincronização" ganhou fonte (regra LCK00-J do padrão CERT para Java).
- `livro:lindholm1999` (JVMS 2ª ed.) aponta para a cópia oficial que a Oracle ainda publica; o Internet Archive ficou na nota.

## [0.1.0] - 2026-10-19

### Adicionado

- Parte I, Testes: aulas 1 e 2 e a ponte para o Quarkus.
- Parte II, Java e a JVM: Java moderno, profissionalismo, JVM por dentro e lendo bytecode.
- Parte III, A JVM com Quarkus: o que o Quarkus faz em build time (augmentation, Jandex, Gizmo), arquitetura hexagonal com CDI, Panache e REST, e as decisões de modo nativo, reflexão, virtual threads e memória em container.
- Parte IV, Outras VMs e modelos históricos: HotSpot, BEAM e GraalVM comparadas (concorrência, GC, falhas e supervisão, carga de código, JIT e AOT, com tabela-resumo), as VMs de onde vêm as ideias da JVM (p-code, Smalltalk-80, Self, CLR, Dalvik/ART), como ler benchmarks com números publicados e suas fichas, e o que levar da BEAM para Java/Quarkus.
- Apêndices: onde achar conteúdo (livros, papers, vídeos, artigos, cursos gratuitos e comunidades em pt-BR), glossário inglês–português dos termos explicados no texto, ferramentas e bibliografia separada por tipo.
- Pesquisa acadêmica: papers, teses e cursos abertos de universidades (Stanford, MIT, CMU, ETH, KTH, TU Delft, USP, Unicamp, UFMG, PUC-Rio e outras) sobre TDD, testes, arquitetura, JVM e outras VMs, em inglês e pt-BR, na seção "Onde aprofundar" de cada capítulo e num apêndice novo por tema e por instituição, com recomendação de leitura; acesso aberto só quando confirmado para o paper, senão "acesso pago" com DOI.
- Quem fez o Java: apêndice novo com o que escreveram e disseram Gosling, Bloch, Davidson, Goetz, Lindholm, Polese, Reinhold, Saab, Sandoz, Schroer, Chander e VanCura (especificações, JEPs, design notes, livros, palestras e entrevistas), começando pelo documentário *The Java Story*; cada pessoa com uma bio de uma linha e a página oficial de onde ela veio. Os itens que conectam entram no "Onde aprofundar" dos capítulos.
- Referências da JetBrains: posts do blog do IntelliJ IDEA e tutoriais do JetBrains Guide sobre testes, Java moderno, JVM (depuração e profiling) e código limpo, no apêndice "Quem fez o Java" e no "Onde aprofundar" dos capítulos; o blog é conferido pelo Internet Archive (o WAF bloqueia o link check).
- Onde comprar ou baixar cada referência: página da editora, edição brasileira e leitura gratuita legal (ou "acesso pago"/"esgotado"), geradas dos campos `acesso`, `urlpt`, `edicaopt` e `urlgratis` do `.bib`; o `check.sh` falha se um livro ou paper ficar sem isso.
- Exemplos em Java com listagens `javap` geradas com o JDK 25.
- CI que compila o PDF e verifica os links.
- Site no GitHub Pages com o PDF, a fonte LaTeX, a lista de versões e este changelog, mais releases versionadas (`vX.Y.Z`).

### Alterado

- Revisão por pares multiagente aplicada: referências corrigidas (vídeos, edições, acesso aberto confirmado na editora), conteúdo técnico das Partes I a IV, terminologia (AOT, desotimização, steady state) e `check.sh` falhando com build falho ou desatualizado. Relatório em `docs/peer-review/2026-10-19.md`.
