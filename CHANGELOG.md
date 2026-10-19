# Changelog

Todas as mudanças relevantes da apostila ficam neste arquivo.
O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e as versões seguem o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado

- Parte I, Testes: aulas 1 e 2 e a ponte para o Quarkus.
- Parte II, Java e a JVM: Java moderno, profissionalismo, JVM por dentro e lendo bytecode.
- Parte III, A JVM com Quarkus: o que o Quarkus faz em build time (augmentation, Jandex, Gizmo), arquitetura hexagonal com CDI, Panache e REST, e as decisões de modo nativo, reflexão, virtual threads e memória em container.
- Parte IV, Outras VMs e modelos históricos: HotSpot, BEAM e GraalVM comparadas (concorrência, GC, falhas e supervisão, carga de código, JIT e AOT, com tabela-resumo), as VMs de onde vêm as ideias da JVM (p-code, Smalltalk-80, Self, CLR, Dalvik/ART), como ler benchmarks com números publicados e suas fichas, e o que levar da BEAM para Java/Quarkus.
- Apêndices: onde achar conteúdo (livros, papers, vídeos, artigos, cursos gratuitos e comunidades em pt-BR), glossário inglês–português dos termos explicados no texto, ferramentas e bibliografia separada por tipo.
- Onde comprar ou baixar cada referência: página da editora, edição brasileira e leitura gratuita legal (ou "acesso pago"/"esgotado"), geradas dos campos `acesso`, `urlpt`, `edicaopt` e `urlgratis` do `.bib`; o `check.sh` falha se um livro ou paper ficar sem isso.
- Exemplos em Java com listagens `javap` geradas com o JDK 25.
- CI que compila o PDF e verifica os links.
- Site no GitHub Pages com o PDF, a fonte LaTeX, a lista de versões e este changelog, mais releases versionadas (`vX.Y.Z`).
