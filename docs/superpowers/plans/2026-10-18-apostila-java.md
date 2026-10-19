# Apostila da Turma de Java 2 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apostila em LaTeX (pt-BR), dividida em muitos arquivos, compilada para PDF por GitHub Action, com conteúdo de testes, Java/JVM, Quarkus e comparação de VMs, toda fonte verificada por peer review multiagente.

**Architecture:** `latex/main.tex` só tem preâmbulo e `\input`; cada conteúdo é um arquivo pequeno. Exemplos Java em `examples/` são compilados com JDK 25 e o `javap` gera listagens em `latex/generated/` (não versionadas) antes do LaTeX. Build idêntico local e no CI, via containers Docker (`texlive/texlive`, `eclipse-temurin:25-jdk`).

**Tech Stack:** LuaLaTeX, KOMA-Script `scrbook`, `babel` (brazilian), `biblatex` + `biber`, `listings`, `hyperref`, `latexmk`; JDK 25; GitHub Actions; `gh` CLI; lychee (link check).

**Spec:** `docs/superpowers/specs/2026-10-18-apostila-java-design.md`

## Global Constraints

- Idioma pt-BR; termos técnicos em inglês; nota de rodapé (`\footnote`) para traduzir/explicar termo em inglês na primeira ocorrência em que for necessário.
- Nenhuma fonte sem verificação: link, título, autor, ano, edição e número de benchmark são checados; o que não for confirmado sai ou fica marcado como `\naoverificado{}`.
- Bytecode no PDF é sempre saída real de `javap` do JDK 25 sobre `examples/`.
- O `.md` original (`~/Downloads/Testes na prática resumo das aulas e referências.md`) **não** é commitado.
- Nenhum arquivo `.tex` acima de 200 linhas; arquivo que mistura dois assuntos é dividido.
- Capítulos de aulas futuras levam a marca "Próximas aulas" (macro `\proximasaulas`).
- Formato de capítulo: resumo → onde aprofundar (livros, artigos, vídeos) → ferramentas/documentação → desafios práticos (texto, sem soluções).
- Ordem e profundidade: Parte II (Java e JVM) > Parte III (JVM com Quarkus) > Parte IV (outras VMs e modelos históricos).
- Livros com edição em português marcados "(PT)"; vídeos em português marcados "(PT)".
- Toda interação com GitHub via `gh`; trabalho em branch `feat/apostila`, PR aberto, **sem merge** sem pedido do Amadeu.
- Licenças: texto CC BY-SA 4.0, exemplos MIT.
- Benchmarks só citados de fontes publicadas, com fonte, data, versão e quem mediu; benchmark de fornecedor marcado como tal.

## Review Focus

1. Link morto ou URL errada numa referência: o build de CI falha no job de link check (lychee) — teste em Task 2.
2. Citação ou `\ref` indefinida (chave do `.bib` digitada errado): `scripts/check.sh` falha ao achar "undefined" no log — teste em Task 2.
3. Arquivo `.tex` crescendo além de 200 linhas durante a escrita: `scripts/check.sh` falha e lista o arquivo — teste em Task 2.
4. Listagem de bytecode desatualizada ou ausente (exemplo removido, `javap` não rodou): `\inputbytecode{nome}` de arquivo inexistente quebra o build — teste em Task 3.
5. Acentos e caracteres especiais (ç, ã, `<=`, `->`) em listagens de código saem quebrados no PDF: listing de teste com esses caracteres deve renderizar — checado visualmente em Task 3 Step 4.

---

### Task 1: Repositório inicial e branch

**Files:**
- Create: `README.md`, `LICENSE` (CC BY-SA 4.0 texto), `examples/LICENSE` (MIT), `.gitignore`

**Interfaces:**
- Produces: repo local ligado a `origin` = `https://github.com/amadeu01/java-class.git`, `main` com commit inicial, branch `feat/apostila` ativa.

- [ ] **Step 1:** `git init -b main` em `/home/amca/Developer/java-class`; `.gitignore` com `latex/generated/`, `latex/build/`, `*.aux`, `*.log`, `*.pdf`, `examples/**/target/`, `out/`.
- [ ] **Step 2:** `README.md` em pt-BR: o que é a apostila, link para a Release `latest`, como compilar localmente (`scripts/build.sh`), licenças.
- [ ] **Step 3:** Commit `chore: initial repository setup` com `README.md`, `LICENSE`, `examples/LICENSE`, `.gitignore`. O design e este plano vão no mesmo commit (`docs/`).
- [ ] **Step 4:** `git remote add origin https://github.com/amadeu01/java-class.git`; `git push -u origin main`. Verificar: `gh repo view amadeu01/java-class --json defaultBranchRef` mostra `main`.
- [ ] **Step 5:** `git switch -c feat/apostila`.

### Task 2: Esqueleto LaTeX, checagens e CI

**Files:**
- Create: `latex/main.tex`, `latex/latexmkrc`, `latex/preamble/{pacotes,macros,estilo}.tex`, `latex/bib/` (vazio com `.gitkeep`), `scripts/build.sh`, `scripts/check.sh`, `.github/workflows/pdf.yml`, `lychee.toml`

**Interfaces:**
- Produces:
  - `scripts/build.sh` — sem argumentos; roda `scripts/gen-bytecode.sh` (Task 3, se existir) e depois `latexmk` em container `texlive/texlive:latest`; saída `latex/build/apostila.pdf`.
  - `scripts/check.sh` — exit 0 só se: log sem `undefined` (citations/references), sem `.tex` > 200 linhas, sem `\todo`.
  - Macros em `latex/preamble/macros.tex`: `\proximasaulas` (caixa "Próximas aulas"), `\naoverificado{texto}`, `\termo{inglês}{explicação}` (itálico + footnote), `\pt` (marca "(PT)"), `\inputbytecode{nome}` (lê `generated/bytecode/nome.txt`), `\desafio{texto}`.
  - Bibliografia: arquivos `latex/bib/<tema>.bib` (`testes`, `java`, `jvm`, `quarkus`, `vms`, `videos`, `artigos`), todos carregados com `\addbibresource`.
  - Estrutura `\input` em `main.tex`: `parte1-testes/parte.tex`, `parte2-java-jvm/parte.tex`, `parte3-quarkus/parte.tex`, `parte4-vms/parte.tex`, `apendices/parte.tex`; cada `parte.tex` só faz `\part{}` e `\input` dos capítulos.

- [ ] **Step 1: Teste falhando.** Criar `main.tex` mínimo com `\cite{chave-inexistente}` e um `latex/teste-longo.tex` de 201 linhas; rodar `scripts/check.sh` após `scripts/build.sh`. Esperado: FAIL listando a citação indefinida e o arquivo longo.
- [ ] **Step 2:** Implementar preâmbulo: `scrbook` (a4paper, 11pt), `fontspec`, `babel[brazilian]`, `csquotes`, `biblatex[backend=biber,style=authoryear]`, `listings` (UTF-8 com `literate` para acentos), `hyperref`, `xcolor`, `tcolorbox` (caixas). `latexmkrc`: `$pdf_mode=4` (lualatex), `$out_dir='build'`, `$jobname='apostila'`.
- [ ] **Step 3:** Remover a citação falsa e o arquivo longo; páginas de rosto (título, "Turma de Java 2 (CEF e Alun Business, Jornada Reskilling, CaixaVerso 2ª onda)", autor Amadeu, data via `\today`), sumário, partes vazias com um capítulo-placeholder cada. Rodar `scripts/build.sh && scripts/check.sh`. Esperado: PASS, `latex/build/apostila.pdf` existe.
- [ ] **Step 4: CI.** `.github/workflows/pdf.yml`, em `push` e `pull_request`:
  - job `bytecode`: `actions/setup-java` (temurin 25), roda `scripts/gen-bytecode.sh` se existir (ele só chega na Task 3), sobe `latex/generated` como artifact;
  - job `pdf` (needs bytecode): container `texlive/texlive:latest`, baixa artifact, `latexmk`, `scripts/check.sh`, sobe `apostila.pdf` como artifact;
  - job `links`: `lycheeverse/lychee-action` sobre `latex/**/*.tex` e `latex/bib/*.bib`, config `lychee.toml` (aceita 200/429, timeout 30s, exclui `youtube.com` de checagem estrita se der falso positivo — documentar no arquivo);
  - job `release` (só `push` em `main`, needs pdf): `gh release` — apaga e recria release `latest` com `apostila.pdf` (`GH_TOKEN: ${{ github.token }}`, `permissions: contents: write`).
- [ ] **Step 5:** Commit `build: LaTeX skeleton, checks and CI`; `git push -u origin feat/apostila`; `gh pr create --draft --title "Apostila: LaTeX, CI e conteúdo" --body ...` (corpo termina com a linha de atribuição). Verificar `gh pr checks --watch`: jobs `pdf` e `links` verdes.

### Task 3: Exemplos Java e geração de bytecode

**Files:**
- Create: `examples/src/main/java/apostila/bytecode/*.java`, `scripts/gen-bytecode.sh`, `latex/parte2-java-jvm/teste-listing.tex` (temporário)

**Interfaces:**
- Consumes: `\inputbytecode{nome}` (Task 2).
- Produces: `scripts/gen-bytecode.sh` — compila `examples/` com `javac --release 25 -g` e, para cada classe listada em `scripts/bytecode-list.txt` (linha: `NomeClasse [flags-javap]`), grava `latex/generated/bytecode/NomeClasse.txt` e `latex/generated/source/NomeClasse.java`. Usa `javac`/`javap` do PATH se for versão 25, senão container `eclipse-temurin:25-jdk`. Falha se a versão não for 25.
- Classes iniciais (o conteúdo da Task 5 pode acrescentar): `ConcatenacaoStrings`, `LambdaInvokeDynamic`, `Autoboxing` (armadilha `Integer ==` acima de 127), `SwitchStrings`, `TryWithResources`, `Sincronizacao`, `PatternSwitch`, `RecordExemplo`.

- [ ] **Step 1: Teste falhando.** `teste-listing.tex` com `\inputbytecode{Autoboxing}`; `scripts/build.sh`. Esperado: FAIL (arquivo não existe).
- [ ] **Step 2:** Escrever as classes (comentários em pt-BR, cada uma demonstra exatamente um comportamento) e `scripts/gen-bytecode.sh`.
- [ ] **Step 3:** `scripts/build.sh && scripts/check.sh`. Esperado: PASS; `latex/generated/bytecode/Autoboxing.txt` contém `Integer.valueOf`.
- [ ] **Step 4:** Abrir o PDF e conferir que a listagem de teste com `ç`, `ã`, `<=` e `->` renderiza correto (Review Focus 5). Remover `teste-listing.tex`.
- [ ] **Step 5:** Commit `feat: Java examples and javap listings`; push; CI verde.

### Task 4: Parte I — Testes (aulas já dadas)

**Files:**
- Create: `latex/parte1-testes/parte.tex`, `aula1/{capitulo,ciclos-tdd,fake-it-triangulacao,pedido-ao-teste,vocabulario-dubles,robustez,desafios}.tex`, `aula2/{capitulo,visao-geral,mutacao,carga,caos,segunda-feira}.tex`, `ponte-quarkus.tex`, `latex/bib/{testes,artigos,videos}.bib`, `latex/apendices/ferramentas.tex` (tabela de ferramentas)

**Interfaces:**
- Consumes: macros da Task 2.
- Produces: chaves bib com prefixo por tipo — `livro:<sobrenome><ano>`, `artigo:<slug>`, `video:<slug>` (ex.: `livro:beck2002`, `artigo:cycles-tdd`, `video:cooper-tdd-wrong`). Tasks 5–8 seguem o mesmo padrão.

- [ ] **Step 1:** Reescrever em LaTeX o conteúdo das duas aulas do `.md`, fielmente (datas 28/09/2026 e 02/10/2026, tabelas dos ciclos e das práticas, perguntas do pedido ao teste, cinco camadas, Right-BICEP, desafios, "para começar na segunda-feira"). Termos como SUT, fixture, stub, mock, load shedding, blast radius recebem `\termo`.
- [ ] **Step 2:** Livros, artigos e vídeos do `.md` viram entradas `.bib` (com `url`, `urldate={2026-10-18}`, `langid`) e tabelas de "onde aprofundar" por aula geradas a partir das chaves (`\citetitle`, `\citeauthor`, `\citeyear`).
- [ ] **Step 3:** `ponte-quarkus.tex`: `@QuarkusTest`, Dev Services (Testcontainers), PIT em projeto Quarkus, SmallRye Fault Tolerance como equivalente a Resilience4j, Gatling contra app Quarkus. Cada afirmação com fonte na documentação oficial (`quarkus.io/guides/...`).
- [ ] **Step 4:** `scripts/build.sh && scripts/check.sh` PASS; push; job `links` verde (corrigir ou marcar `\naoverificado` qualquer link morto).
- [ ] **Step 5:** Commit `feat: Part I, testing lessons`.

### Task 5: Parte II — Java e a JVM (1º bloco, maior profundidade)

**Files:**
- Create: `latex/parte2-java-jvm/parte.tex`, `cap-java-moderno/{capitulo,records,sealed-pattern,virtual-threads,...}.tex`, `cap-profissional/{capitulo,clean-coder,clean-code}.tex`, `cap-jvm-por-dentro/{capitulo,class-loading,interpretador-jit,gc,modelo-memoria}.tex`, `cap-lendo-bytecode/{capitulo,javap-basico,constant-pool,invokedynamic,autoboxing,switch,try-with-resources,sincronizacao,ferramentas}.tex`, `latex/bib/{java,jvm}.bib`

**Interfaces:**
- Consumes: listagens da Task 3 via `\inputbytecode`; padrão de chaves da Task 4.

- [ ] **Step 1: Pesquisa.** Subagente de pesquisa (internet) levanta fontes primárias: Deitel (*Java: How to Program* / *Java: Como Programar*, edição atual), *The Clean Coder*, *Clean Code*, *Effective Java* 3ª ed., JVM Specification (Java SE 25), JEPs relevantes, *Java Performance* 2ª ed. (Scott Oaks), *Optimizing Java*, documentação de G1/ZGC/Shenandoah, JFR/JMC, JITWatch, async-profiler; palestras (ex.: Devoxx, JVMLS) com URL. Saída: entradas `.bib` com URL.
- [ ] **Step 2:** Escrever os capítulos. Cada seção de bytecode segue: código → `\inputbytecode` → leitura linha a linha das instruções que importam → bug ou decisão que isso explica → "Ponte com Quarkus" quando houver.
- [ ] **Step 3:** Desafios de texto por capítulo (ex.: "rode `javap -c` na sua classe com lambda e ache o `invokedynamic`").
- [ ] **Step 4:** `scripts/build.sh && scripts/check.sh` PASS; push; CI verde.
- [ ] **Step 5:** Commit `feat: Part II, Java and the JVM`.

### Task 6: Parte III — A JVM com Quarkus

**Files:**
- Create: `latex/parte3-quarkus/parte.tex`, `cap-build-time/{capitulo,augmentation,jandex,gizmo-bytecode}.tex`, `cap-arquitetura/{capitulo,clean-architecture,hexagonal-cdi,panache-rest,testes,resiliencia,observabilidade}.tex`, `cap-decisoes/{capitulo,jvm-vs-nativo,reflexao-nativo,virtual-threads-vs-reativo,memoria-container}.tex`, `cap-onde-aprender.tex`, `latex/bib/quarkus.bib`

- [ ] **Step 1: Pesquisa.** Guias oficiais Quarkus (writing extensions, CDI reference, native reference, virtual threads, Dev Services), Quarkus Insights, *Quarkus in Action*, *Kubernetes Native Microservices with Quarkus*, *Clean Architecture* (Robert C. Martin), números oficiais de startup/RSS do Quarkus com data e versão.
- [ ] **Step 2:** Escrever. Bytecode gerado pelo Quarkus: mostrar com `quarkus.package.jar.decompiler` ou listagem de classe gerada citada da documentação, sempre com fonte. Exemplo de arquitetura hexagonal com nomes de pacotes concretos.
- [ ] **Step 3:** Desafios de texto.
- [ ] **Step 4:** `scripts/build.sh && scripts/check.sh` PASS; push; CI verde.
- [ ] **Step 5:** Commit `feat: Part III, JVM with Quarkus`.

### Task 7: Parte IV — Outras VMs e modelos históricos

**Files:**
- Create: `latex/parte4-vms/parte.tex`, `cap-comparacao/{capitulo,concorrencia,gc,falhas-supervisao,hot-code-loading,jit-vs-aot,tabela-resumo}.tex`, `cap-historia/{capitulo,p-code,smalltalk,self-hotspot,clr,dalvik-art}.tex`, `cap-benchmarks/{capitulo,como-ler-benchmark,numeros-publicados}.tex`, `cap-decisoes-vm.tex`, `latex/bib/vms.bib`

- [ ] **Step 1: Pesquisa.** BEAM (*The BEAM Book*, *Designing for Scalability with Erlang/OTP*, documentação Erlang/OTP), GraalVM (docs, papers Graal/Truffle, Native Image closed-world), Self (papers de Ungar/Hölzle sobre PICs e deoptimização), Smalltalk-80 "Blue Book", UCSD p-System, CLR (ECMA-335), Dalvik/ART; benchmarks: TechEmpower (rodada e data), Renaissance suite (paper PLDI 2019), números oficiais GraalVM/Quarkus.
- [ ] **Step 2:** Escrever. Tabela-resumo HotSpot × BEAM × GraalVM com linhas: modelo de concorrência, GC, tratamento de falha, carga de código, compilação, startup/memória (com fonte). Cada número numa nota com fonte, data, versão, quem mediu, "(fornecedor)" quando for o caso.
- [ ] **Step 3:** `cap-decisoes-vm.tex`: quando a BEAM seria melhor, o que trazer dela para Java/Quarkus, quando escolher nativo.
- [ ] **Step 4:** `scripts/build.sh && scripts/check.sh` PASS; push; CI verde.
- [ ] **Step 5:** Commit `feat: Part IV, other VMs and historical models`.

### Task 8: Apêndices

**Files:**
- Create: `latex/apendices/{parte,onde-achar-conteudo,glossario,bibliografia}.tex`

- [ ] **Step 1:** "Onde achar conteúdo": índice por tipo (livros com "(PT)", artigos, vídeos com "(PT)", cursos, comunidades em pt-BR como SouJava), tudo via chaves bib já verificadas.
- [ ] **Step 2:** Glossário pt-BR ↔ inglês com todos os `\termo` usados (gerar a lista por `grep '\\termo' -r latex/`; nenhum termo de fora).
- [ ] **Step 3:** `\printbibliography` dividido por `keyword` (livros, artigos, vídeos).
- [ ] **Step 4:** `scripts/build.sh && scripts/check.sh` PASS; push; CI verde. Commit `feat: appendices`.

### Task 9: Peer review multiagente

Workflow (tool `Workflow`, opt-in explícito do Amadeu) com até 10 agentes, cada um com internet (WebSearch/WebFetch; Chrome se o site bloquear fetch):

| Agente | Escopo | Saída |
|---|---|---|
| refs-livros | toda entrada `livro:*` | por chave: existe? autor, ano, edição, (PT) confirmado? |
| refs-online | `artigo:*`, `video:*`, ferramentas | URL viva, título e autor batem, (PT) correto |
| tecnico-testes | Parte I | afirmações vs fonte primária |
| tecnico-jvm | Parte II + listagens | afirmações vs JVMS/JEPs; leitura de bytecode correta |
| tecnico-quarkus | Parte III | vs guias oficiais Quarkus |
| tecnico-vms | Parte IV | BEAM/GraalVM/história vs fontes primárias |
| benchmarks | todo número no texto | rastreado até a fonte, versão e data |
| idioma | todos os `.tex` | pt-BR, consistência de termos, falta de `\termo` |
| latex-ci | `latex/`, `scripts/`, `.github/` | build, warnings, regras de tamanho, CI |

- [ ] **Step 1:** Rodar o workflow; cada achado vem com arquivo:linha, evidência (URL) e correção proposta. Achados passam por verificação adversarial antes de aceitos.
- [ ] **Step 2:** Aplicar achados confirmados; o que não puder ser confirmado é removido ou marcado `\naoverificado`.
- [ ] **Step 3:** `scripts/build.sh && scripts/check.sh` PASS; CI verde.
- [ ] **Step 4:** Commit `fix: apply peer review findings`; salvar o relatório do review em `docs/peer-review/2026-10-18.md`.

### Task 10: Entrega

- [ ] **Step 1:** `gh pr ready`; atualizar corpo do PR com resumo das partes, link do artifact do PDF e resumo do peer review (termina com a linha de atribuição).
- [ ] **Step 2:** `gh pr checks` todos verdes. **Não fazer merge**; informar o Amadeu que o merge na `main` dispara a Release `latest`.

---

## Adições aprovadas (2026-10-18)

Ordem de execução: 5 → 11 → 6 → 7 → 8 → 12 → 9 → 10.

### Task 11: GitHub Pages, releases versionadas e changelog

**Files:**
- Create: `CHANGELOG.md`, `scripts/build-site.sh`, `scripts/test-site.sh`, `scripts/package-latex.sh`, `site/template.html`, `site/estilo.css`
- Modify: `.github/workflows/pdf.yml` (remover job `release` da tag `latest`; adicionar jobs `release` em tag e `pages`), `README.md` (link do site e das releases)

**Interfaces:**
- Consumes: artifact `apostila` (PDF) do job `pdf`; `latex/`, `examples/`, `scripts/`.
- Produces:
  - `scripts/package-latex.sh VERSAO` → `dist/apostila-latex-VERSAO.zip` via `git archive` de `latex/ examples/ scripts/ README.md LICENSE examples/LICENSE latexmkrc` (sem gerados).
  - `scripts/build-site.sh` → `public/index.html`, `public/apostila.pdf`, `public/apostila-latex.zip`, `public/estilo.css`. Lê `CHANGELOG.md` (convertido com `pandoc`) e a lista de releases (`gh release list --json tagName,publishedAt` + assets); sem releases ainda, mostra só a versão em desenvolvimento.
  - `scripts/test-site.sh` → exit 0 só se `public/index.html` existe, contém o título da apostila, links para `apostila.pdf` e `apostila-latex.zip`, a seção de changelog, e os arquivos linkados existem em `public/`.

- [ ] **Step 1: Teste falhando.** `scripts/test-site.sh` antes de existir o build do site. Esperado: FAIL ("public/index.html não existe").
- [ ] **Step 2:** `CHANGELOG.md` pt-BR (*Keep a Changelog*): seção `[Não lançado]` listando o que existe (Parte I, Parte II, CI, exemplos de bytecode). Escrever `package-latex.sh`, `build-site.sh`, `site/template.html` + `site/estilo.css` (cores e fonte coerentes com o PDF: azul dos títulos, sans nos títulos; responsivo; claro/escuro).
- [ ] **Step 3:** rodar `scripts/build-site.sh && scripts/test-site.sh` localmente (pandoc via container `pandoc/core` se não houver local). Esperado: PASS. Abrir `public/index.html` renderizado (screenshot) e conferir.
- [ ] **Step 4: CI.**
  - job `release` (em `push` de tag `v*`, needs pdf): extrai a seção da versão do `CHANGELOG.md` como notas; `gh release create vX.Y.Z apostila-vX.Y.Z.pdf apostila-latex-vX.Y.Z.zip --notes-file ...`.
  - job `pages` (em push na `main` e em tag `v*`, needs pdf e release quando houver): `build-site.sh`, `test-site.sh`, `actions/upload-pages-artifact`, `actions/deploy-pages`; `permissions: pages: write, id-token: write`; `concurrency: pages`.
  - remover o job antigo que recriava a release `latest`.
  - em PR: rodar `build-site.sh && test-site.sh` (sem deploy) para validar.
- [ ] **Step 5:** habilitar Pages com origem "GitHub Actions": `gh api -X POST repos/amadeu01/java-class/pages -f build_type=workflow` (se já existir, `-X PUT`). Não criar tags.
- [ ] **Step 6:** Commit `feat: GitHub Pages site, versioned releases and changelog`; push; CI verde (job de validação do site no PR).

### Task 12: Pesquisa acadêmica na apostila

**Files:**
- Create: `latex/bib/academico.bib`, `latex/apendices/pesquisa-academica/{capitulo,por-tema,por-instituicao}.tex` (dividir se passar de 200 linhas)
- Modify: `latex/preamble/pacotes.tex` (`\addbibresource{bib/academico.bib}`), arquivos "aprofundar" de cada capítulo (Partes I–IV), `latex/apendices/parte.tex`, `CHANGELOG.md`

**Interfaces:**
- Consumes: `.superpowers/sdd/2026-10-18-apostila-java/research-academic-testing-arch.md` e `research-academic-jvm-vms.md` (tabelas verificadas + BibTeX proposto).
- Produces: chaves `paper:*`, `doc:*` com `keywords`, `langid`, `url`, `urldate`, `doi` quando houver.

- [ ] **Step 1:** Reconferir uma amostra (≥ 20%) das URLs/DOIs da pesquisa com WebFetch; remover o que não confirmar.
- [ ] **Step 2:** `academico.bib` sem chaves duplicadas com os outros `.bib` (se já existir a obra, reutilizar a chave existente).
- [ ] **Step 3:** Em cada capítulo, subseção "Pesquisa acadêmica" dentro de "Onde aprofundar" com os itens que conectam, uma frase em pt-BR cada, marcando `\pt` para os em português.
- [ ] **Step 4:** Apêndice "Pesquisa acadêmica": por tema e por instituição; "Recomendação de leitura" (top 5, ≥ 2 em pt-BR).
- [ ] **Step 5:** `scripts/build.sh && scripts/check.sh` PASS; CI verde (lychee checa todas as URLs novas). Commit `feat: academic research references`.
