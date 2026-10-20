# História das decisões do Java — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the chapter "Por que o Java é assim" to Part II. Answer the seven required JVM questions with sources. Add a JMH contention benchmark. Fold in the PR #2 timeline. Re-review Parts II–IV against the JLS/JVMS (2nd edition and SE 25).

**Architecture:** The plan has three stages.
- **Research first.** A source dossier is checked live and lives in the plan workspace, which is gitignored. Every sentence the writers produce must trace back to it.
- **Writing.** The new chapter lives in `latex/parte2-java-jvm/cap-por-que/` as one file per section, cited from `latex/bib/historia.bib`. Bytecode comes through the existing `examples/` + `bytecode-list.txt` + `\inputbytecode` pipeline. The benchmark is a separate Maven/JMH project; its committed results file is read by LaTeX.
- **Review.** A fresh multi-agent peer review runs at the end.

**Tech Stack:**
- LuaLaTeX, KOMA scrbook, biblatex+biber (custom `apostila.dbx`), latexmk, run in `texlive/texlive:latest`.
- JDK 25 (`eclipse-temurin:25-jdk`), JMH via Maven (`maven:3-eclipse-temurin-25`).
- GitHub CLI.

**Spec:** `docs/superpowers/specs/2026-10-19-historia-decisoes-design.md`. It continues `docs/superpowers/specs/2026-10-18-apostila-java-design.md`.

## Global Constraints

- **Language:** pt-BR prose. Technical terms stay in English, explained with `\termo{en}{explicação}` the first time they appear in the chapter.
- **File size:** every `.tex` has 200 lines or fewer. Split by subject when it grows.
- **Checks:** `scripts/check.sh` must pass. It fails on undefined citations or references, a `.tex` over 200 lines, `\todo`, a stale or failed build, a livro or paper without `acesso` plus a link, and `acesso=pago` without `doi`.
- **Bibliography entries:**
  - Every entry has `keywords` (a type: livro|paper|artigo|video|doc|bio|ferramenta|curso|comunidade, plus an optional `tema-*`) and `langid`.
  - Key prefixes are `livro:`, `paper:`, `artigo:`, `video:`, `doc:`, `bio:`.
  - Never duplicate an existing key. Grep `latex/bib/` first; for example, `livro:lindholm1999`, `paper:java-memory-model`, `paper:manson-tese-jmm-2004`, `doc:jls25`, `doc:jvms25`, `doc:jep444`, `doc:jep491` and `artigo:forward-faster` already exist.
- **Open access:** an item is `aberto` only with evidence for that exact work. That means its own publisher page showing Free/Open access, or a repository holding the exact paper. A same-title tech report or preprint means `pago` + `doi`, with the copy in `urlgratis` and a `note`.
- **No source, no sentence:** a claim with no source opened in this round does not go in. `\naoverificado` is not used in the new chapter. A source reachable only through the Internet Archive is fine; print the official URL and keep the snapshot in the dossier.
- **Wikipedia:** it is a lead only. It is never the sole support for a claim and is never cited.
- **Spec quotes:** at most two lines verbatim. Everything else is paraphrase with the section number, written as "JLS 2ª ed., §17.x".
- **Section shape:** problem of the era → decision (cited) → what changed later → "O que isso muda no seu código" → where the handbook goes deeper (`\ref`).
- **Privacy:** never send the owner's name or email to any external service. That includes the `mailto=` parameter on OpenAlex or Crossref.
- **Downloads:** never commit anything from `~/Downloads`.
- **Bytecode:** listings are real `javap` output from JDK 25 via `scripts/gen-bytecode.sh`. They are never hand-written.
- **Benchmark numbers:** printed only from the committed results file. Show the machine, CPU count and JDK beside them, plus the caveat that the numbers belong to that machine.
- **Git:**
  - All commits go on branch `feat/linha-do-tempo` (PR #2).
  - Commit messages are in English, conventional-commit style, and end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
  - Push with `git -c credential.helper='!gh auth git-credential' push`.
  - No merge and no tag.
- **Builds:** build locally with `scripts/build.sh` (Docker) and check with `scripts/check.sh`.

## Review Focus

1. **A historical date or version that is off by one release.** Examples: green threads dropped in 1.2 vs 1.3, JCP 1998 vs 1999, JSR-133 in Java 5. Each date in the text must match a dossier row whose source was opened.
   - **Pin:** Task 1 dossier rows have source + quote. Tasks 3–7 cite only dossier rows.
   - **Check:** Task 9's review dimension "datas e versões".
2. **A "what the spec said" claim that cites the wrong edition or section.** For example, the old memory model is attributed to JLS 2nd ed. ch. 17 but the text paraphrases JLS 3rd ed.
   - **Pin:** every before/after table row carries the exact section numbers from both editions, taken from the dossier.
3. **Concurrency advice that is wrong on JDK 25 but was right on JDK 21.** Examples: pinning, the `-Xverify:none` warning, TLAB defaults.
   - **Pin:** every "no seu código" box states the JDK version it applies to.
4. **Benchmark numbers in the text that do not match the committed results file**, or a file with no machine or JDK header.
   - **Pin:** in Task 6, `check.sh` gains a check that the results file exists and has a `# jdk:` header line. The text reads the numbers via `\input` of a table generated from that file, never typed by hand.
5. **A cross-reference to a label that moved.** The new chapter is first in Part II, so chapter numbers shift.
   - **Pin:** use `\ref` only, never typed numbers. Task 8 greps for hard-coded "capítulo N" / "seção N.M".

---

### Task 1: Source dossier (research)

**Files:**
- Create: `<workspace>/research-historia.md`. Workspace = `.superpowers/sdd/2026-10-19-historia-decisoes/`, gitignored.
- Create: `latex/bib/historia.bib`.
- Modify: `latex/preamble/pacotes.tex`. Add `\addbibresource{bib/historia.bib}` after the `academico.bib` line.

**Interfaces:**
- **Produces:**
  - Dossier sections D1–D9, matching chapter sections 1–7 plus questions Q1–Q3 (JIT/AOT/startup, ZGC/Shenandoah, thread-local GC).
  - Each row: claim (pt-BR, one sentence) | source key | exact location (edition + §/page, or URL anchor) | verbatim supporting quote of ≤2 lines | date opened | how opened (direct/Wayback/Chrome).
  - Bib keys in `historia.bib` that later tasks cite.

- [ ] **Step 1: Locate and open the two anchor specs.**
  - JLS 2nd ed. (Gosling, Joy, Steele, Bracha, 2000) and JVMS 2nd ed. (Lindholm, Yellin, 1999).
  - Find the official HTML (Oracle-hosted copies of the old java.sun.com books, or Internet Archive snapshots of `java.sun.com/docs/books/jls/second_edition/` and `java.sun.com/docs/books/vmspec/2nd-edition/`).
  - Record working URLs.
  - Add `livro:gosling2000-jls2` (new; `acesso=esgotado`, `urlgratis` = the working HTML).
  - Add `urlgratis` to the existing `livro:lindholm1999`.
- [ ] **Step 2: Fill D1–D9 with live-checked rows.** Minimum content per section:
  - **D1 Objectives:** the white paper (existing key `paper:java-language-environment`; verify the edition and URL).
  - **D2 Verification:**
    - JVMS 2nd ed. §4.9 and JVMS SE 25 §4.10.
    - The split verifier history (JSR 202 / Java 6).
    - `-Xverify:none`/`-noverify` deprecated in JDK 13. Find the JDK bug ID in bugs.openjdk.org or the JDK 13 release notes.
    - What disabling breaks: the release-note wording.
  - **D3 Monitors:**
    - JLS 2nd ed. ch. 17 and JVMS 2nd ed. ch. 8.
    - Hoare 1974 CACM "Monitors" (DOI).
    - Brinch Hansen 1999 "Java's Insecure Parallelism" (ACM SIGPLAN Notices, DOI).
  - **D4 Threads → VT:**
    - Green threads vs native threads per JDK release and OS (primary: Sun/Oracle docs or release notes).
    - Quasar (GitHub `puniverse/quasar`).
    - Loom project page and proposal (2017).
    - JEP 425, 436, 444, 491.
    - Ron Pressler's "State of Loom" (cr.openjdk.org).
    - At least one published number comparing VT vs platform-thread cost (JEP 444 text or an Oracle/inside.java article).
  - **D5 Memory model:**
    - JLS 2nd ed. ch. 17 vs JLS SE 25 §17.4.
    - JSR-133 page.
    - Pugh "The Java Memory Model is Fatally Flawed" (2000, Concurrency: Practice and Experience, DOI).
    - "The 'Double-Checked Locking is Broken' Declaration" (cs.umd.edu).
    - Existing `paper:java-memory-model`.
  - **D6 j.u.c.:**
    - Doug Lea's `EDU.oswego.cs.dl.util.concurrent` page.
    - JSR-166 page.
    - Lea 2005 "The java.util.concurrent Synchronizer Framework" (Science of Computer Programming, DOI).
    - Lea 2000 "A Java Fork/Join Framework" (Java Grande, DOI).
    - JDK 7/8 release docs for ForkJoin/CompletableFuture.
  - **D7 Many requests:**
    - Servlet spec thread model (Jakarta Servlet spec).
    - Dan Kegel "The C10K problem".
    - JSR 51 (NIO).
    - Reactive Streams spec (reactive-streams.org, GitHub).
    - `java.util.concurrent.Flow` (Java 9 API doc).
    - Quarkus virtual threads guide (existing `doc:quarkus-virtual-threads`).
  - **D8 Q1–Q2:**
    - Tiered compilation docs.
    - JEP 483/514/515 (existing).
    - ZGC/Shenandoah papers (existing `paper:zgc-deep-dive`, `paper:shenandoah`) and JEPs 377/379/439/474 (existing).
  - **D9 Q3 thread-local GC:**
    - Steensgaard 2000 "Thread-Specific Heaps for Multi-Threaded Programs" (ISMM, DOI).
    - Domani et al. 2002 "Thread-Local Heaps for Java" (ISMM, DOI).
    - HotSpot TLAB documentation (an Oracle GC tuning guide or a source comment on GitHub `openjdk/jdk`).
    - BEAM per-process heap (erlang.org docs; Part IV may already cite it, so grep `vms.bib`).
- [ ] **Step 3: Write `historia.bib` entries** for every new source, following the Global Constraints rules on `acesso`, `keywords` and `langid`.
- [ ] **Step 4: Verify the build.**
  - Run: `scripts/build.sh && scripts/check.sh`
  - Expected: `check.sh: OK`. New entries are not yet cited, which is fine. Biber must parse the file.
- [ ] **Step 5: Commit** `latex/bib/historia.bib` and `latex/preamble/pacotes.tex` with `chore(bib): sources for Java history chapter`.

Rows whose source cannot be opened are listed at the end of the dossier under "Descartado", with the reason. Later tasks must not use them.

### Task 2: Chapter skeleton and wiring

**Files:**
- Create: `latex/parte2-java-jvm/cap-por-que/capitulo.tex`. It holds `\chapter{Por que o Java é assim}`, `\label{cap:por-que}`, a short intro stating the chapter's question and its sources, and `\input`s of the section files below.
- Create stub section files, one per section, each with only `\section{...}` and `\label{...}`:
  - `objetivos.tex` (`sec:objetivos-1995`)
  - `verificacao.tex` (`sec:verificacao`)
  - `monitores.tex` (`sec:monitores`)
  - `threads-vt.tex` (`sec:threads-ate-vt`)
  - `modelo-memoria-historia.tex` (`sec:jmm-historia`)
  - `juc.tex` (`sec:juc`)
  - `muitos-requests.tex` (`sec:muitos-requests`)
  - `aprofundar.tex`
  - `desafios.tex`
- Modify: `latex/parte2-java-jvm/parte.tex`. Make `cap-por-que/capitulo` the first `\input` inside the `\sloppy` group.

**Interfaces:**
- **Produces:** the labels above. Tasks 3–8 fill these files and may split them (for example `threads-vt-loom.tex`), keeping each file to 200 lines or fewer.

- [ ] **Step 1:** Create the files and wire them.
- [ ] **Step 2:** Run `scripts/build.sh && scripts/check.sh`. Expected: OK, and the chapter appears as chapter 5 in the TOC, the first of Part II.
- [ ] **Step 3:** Commit with `feat(parte2): skeleton for 'Por que o Java é assim' chapter`.

### Task 3: Sections 1–2: 1995 objectives, bytecode and verification (answers Q4, Q5)

**Files:**
- Modify: `cap-por-que/objetivos.tex` and `cap-por-que/verificacao.tex`.
- Create: `examples/src/main/java/apostila/bytecode/VerificacaoTipos.java`. It is a small class whose `javap -c -p` shows typed local/stack use (for example `iload` vs `aload` for an `int` and an `Object` local), so the text can explain what the verifier checks.
- Modify: `scripts/bytecode-list.txt`. Add `VerificacaoTipos -c -p`.

**Interfaces:**
- **Consumes:** dossier D1 and D2. Labels `cap:lendo-bytecode` and `sec:invokedynamic`, plus whatever label `class-loading.tex` defines; grep for it.

- [ ] **Step 1:** Write the sections in the Global Constraints shape. Q4 and Q5 are each answered in a paragraph whose first sentence restates the question.
  - **Q4:** how the verifier proves type safety. Cover the JVMS 2nd ed. §4.9 type inference vs the SE 25 §4.10 StackMapTable type checking, and what it does not prove.
  - **Q5:** what happens when it is disabled. Cover the JDK 13 deprecation, and that malformed bytecode can then crash the VM or break memory safety, worded as the source words it.
- [ ] **Step 2:** Run `scripts/gen-bytecode.sh` and check that `latex/generated/bytecode/VerificacaoTipos.txt` exists. Then run `scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 3:** Commit with `feat(parte2): 1995 design goals and bytecode verification`.

### Task 4: Section 3: threads and monitors since 1.0

**Files:**
- Modify: `cap-por-que/monitores.tex`.
- Create: `examples/src/main/java/apostila/bytecode/EsperaEmLaco.java`. It is a bounded buffer with `synchronized` + `while (cond) wait()`; `notifyAll`.
- Modify: `scripts/bytecode-list.txt`. Add `EsperaEmLaco -c -p`.

**Interfaces:**
- **Consumes:** D3, plus `sec:sincronizacao`, which already shows `monitorenter`/`monitorexit`. Reference it; do not repeat it.

- [ ] **Step 1:** Write the section.
  - Show the before/after table: JLS 2nd ed. ch. 17 / JVMS 2nd ed. ch. 8 against JLS SE 25 ch. 17 / JVMS SE 25 §2.11.10 and §3.14, with sections from the dossier.
  - "No seu código" covers three things: `wait` in a loop (spurious wakeups, as the spec states), a private lock object, and preferring `java.util.concurrent` → `\ref{sec:juc}`.
  - Explain the listing: where `wait` sits inside the monitor.
- [ ] **Step 2:** Run `scripts/gen-bytecode.sh && scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 3:** Commit with `feat(parte2): monitors and wait/notify history`.

### Task 5: Section 5: the memory model that was wrong

**Files:**
- Modify: `cap-por-que/modelo-memoria-historia.tex`.
- Create: `examples/src/main/java/apostila/bytecode/PublicacaoSegura.java`. It has a `volatile` field, a `final` field, and a correct DCL (double-checked locking) singleton with a `volatile` holder.
- Modify: `scripts/bytecode-list.txt`. Add `PublicacaoSegura -v -p`; `-v` shows `ACC_VOLATILE` and `ACC_FINAL` in the field flags.

**Interfaces:**
- **Consumes:** D5. The existing `cap-jvm-por-dentro/modelo-memoria.tex` (grep its label) explains today's JMM. This section is the history and the "why"; reference that section for details instead of re-explaining happens-before.

- [ ] **Step 1:** Write the section.
  - Show the before/after table: the old JLS 2nd ed. ch. 17 rules (main memory / working memory, as the dossier quotes) against SE 25 §17.4 happens-before.
  - Cover what was broken (Pugh 2000), the DCL declaration, and JSR-133 in Java 5.
  - "No seu código": `volatile` for flags/publication, `final` for immutable published objects, the holder-class idiom vs DCL, all stated for JDK 5+.
  - Explain the `-v` listing flags.
- [ ] **Step 2:** Run `scripts/gen-bytecode.sh && scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 3:** Commit with `feat(parte2): Java memory model history and JSR-133`.

### Task 6: Section 6: java.util.concurrent, plus the JMH contention benchmark

**Files:**
- Modify: `cap-por-que/juc.tex`.
- Create: `examples/bench/pom.xml`.
  - JMH 1.37 (`jmh-core`, `jmh-generator-annprocess`).
  - `maven.compiler.release` 25.
  - A shade plugin producing `target/benchmarks.jar`.
- Create: `examples/bench/src/main/java/apostila/bench/Contencao.java`.
  - `@State(Scope.Benchmark)`, with three `@Benchmark` methods each incrementing a shared counter: `synchronizedIncrement` (a `long` guarded by `synchronized`), `atomicLongIncrement` (`AtomicLong.incrementAndGet`) and `longAdderIncrement` (`LongAdder.increment`).
  - Run at `@Threads` 1 and 8 via two `@Fork`-ed parameter sets, or JMH `-t` passed by the script.
  - `@BenchmarkMode(Mode.Throughput)`, `@OutputTimeUnit(TimeUnit.MICROSECONDS)`.
- Create: `scripts/bench.sh`.
  - Builds and runs in `maven:3-eclipse-temurin-25` under Docker, with the same `--user`/`HOME=/tmp` pattern as `build.sh`.
  - Runs `java -jar target/benchmarks.jar Contencao -t 1` and `-t 8` with `-wi 3 -i 5 -f 1 -rf text`.
  - Writes `latex/dados/bench/contencao.txt`, whose first lines are `# jdk: <java -version line>`, `# cpus: <nproc>`, `# cpu: <model from /proc/cpuinfo>` and `# data: <ISO date>`, followed by the JMH result table.
  - Also writes `latex/dados/bench/contencao-tabela.tex`, a `tabular` generated from the results with mode, threads, score and error. The text `\input`s it.
- Modify: `scripts/check.sh`. Fail if `latex/dados/bench/contencao.txt` is missing or lacks a `# jdk:` line.
- Commit: `latex/dados/bench/contencao.txt` and `contencao-tabela.tex`, the generated output.

**Interfaces:**
- **Consumes:** D6.
- **Produces:** label `sec:juc`, and `latex/dados/bench/contencao-tabela.tex` (`\input` path `dados/bench/contencao-tabela`).

- [ ] **Step 1:** Write `pom.xml` and `Contencao.java`. Run `scripts/bench.sh`. Expected: the two files are written, the header has a jdk line containing `25`, and there are six result rows (3 benchmarks × 2 thread counts).
- [ ] **Step 2:** Add the `check.sh` rule. Delete the results file temporarily, run `scripts/check.sh`, and confirm it FAILS with a clear message. Restore the file.
- [ ] **Step 3:** Write the section.
  - History from the dossier: Lea's package → JSR-166 → AQS → Fork/Join → CompletableFuture.
  - "No seu código": executors instead of `new Thread`, concurrent collections, `LongAdder` for hot counters, when parallel streams help.
  - The benchmark table, with how to read it (it shows contention; it does not predict your service) and a pointer to the Part IV benchmark-reading chapter (grep its label).
- [ ] **Step 4:** Run `scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 5:** Commit with `feat(parte2): java.util.concurrent history and JMH contention benchmark`.

### Task 7: Sections 4 and 7: from green threads to virtual threads; many requests (answers Q6, Q7)

**Files:**
- Modify: `cap-por-que/threads-vt.tex` (split into `threads-vt-loom.tex` if it goes over 200 lines) and `cap-por-que/muitos-requests.tex`.
- Modify: `latex/parte2-java-jvm/cap-java-moderno/virtual-threads.tex`. Add one sentence pointing to `\ref{sec:threads-ate-vt}`. The existing pointer to `sec:linha-do-tempo` stays.

**Interfaces:**
- **Consumes:** D4 and D7, plus `sec:virtual-threads` and `sec:vt-vs-reativo`. Reference them and do not repeat their rules.

- [ ] **Step 1:** Write the threads section following the spec §3.1 "Seção 4 em detalhe" sequence. Every step is backed by a dossier row.
  - **Q7:** answered by the sequence itself, opening with a sentence that states the question.
  - **Q6:** a paragraph on the cost of 1:1 vs M:N, with the published number from D4, its source, and the JDK it applies to.
- [ ] **Step 2:** Write the many-requests section: thread-per-request → C10K → NIO → reactive (Reactive Streams, `Flow`) → VT, plus the Quarkus bridge (`@RunOnVirtualThread`, event loop) → `\ref{sec:vt-vs-reativo}`.
- [ ] **Step 3:** Run `scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 4:** Commit with `feat(parte2): road to virtual threads and handling many requests`.

### Task 8: Q1–Q3 in the existing chapters; aprofundar/desafios; timeline links; changelog

**Files:**
- Modify: `latex/parte2-java-jvm/cap-jvm-por-dentro/interpretador-jit.tex` (Q1).
- Modify: `latex/parte2-java-jvm/cap-jvm-por-dentro/gc.tex` (Q2, Q3), splitting into `gc-heaps-por-thread.tex` if needed.
- Modify: the Part IV GC section `latex/parte4-vms/cap-comparacao/gc.tex`. Add only a cross-ref for Q3 if BEAM is already explained.
- Modify: `cap-por-que/aprofundar.tex` (the `\obra` list of the chapter's key sources, using the existing `\obra`/`\obra*` macros) and `cap-por-que/desafios.tex` (3–5 `\desafio{}` items, one per concurrency problem: many requests, shared memory, multi-core).
- Modify: `latex/apendices/pessoas/linha-do-tempo.tex`.
  - Recheck every "Conferido" sentence against the dossier and fix any that the dossier contradicts.
  - Add a `\ref` to the matching `cap-por-que` section in each phase.
  - Leave the film's timestamps and summary untouched.
- Modify: `CHANGELOG.md`. Extend the existing `[Não lançado]` → `### Adicionado` list with the chapter, the benchmark and the answered questions.

**Interfaces:**
- **Consumes:** D8 and D9, and all `cap-por-que` labels.

- [ ] **Step 1:** Answer Q1–Q3 where they belong, each in a paragraph opening with the question. Q1 needs the real startup impact with a published number (Leyden JEP or Quarkus JVM vs native figures already in `jvm-vs-nativo.tex`; reference, don't copy). Q3 covers the Steensgaard and Domani results, why HotSpot uses TLABs instead (allocation is local, the heap is shared), and BEAM's per-process heap.
- [ ] **Step 2:** Fill `aprofundar.tex` and `desafios.tex`, and update the timeline and the changelog.
- [ ] **Step 3:** Run `grep -rnE 'cap[ií]tulo~?[0-9]|se[cç][aã]o~?[0-9]' latex --include=*.tex`. Expected: no hard-coded numbers.
- [ ] **Step 4:** Run `scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 5:** Commit with `feat: answer JIT/GC questions in place, timeline links, changelog`.

### Task 9: Peer review (fresh pass) and fixes

**Files:**
- Create: `docs/peer-review/2026-10-19-historia.md`.
- Modify: whatever the confirmed findings touch.

The controller runs this as a Workflow (multi-agent, under 10 agents) over `latex/parte2-java-jvm/`, `latex/parte3-quarkus/`, `latex/parte4-vms/`, `latex/apendices/pessoas/`, `latex/bib/historia.bib`, and the benchmark files.

**Dimensions:**
1. Dates and versions.
2. Claims about JLS/JVMS 2nd edition against the 2nd-edition text.
3. Current-spec claims against JLS/JVMS SE 25.
4. Concurrency correctness of the advice and examples on JDK 25.
5. References: `acesso`, links, DOI, edition.
6. pt-BR clarity, `\termo` usage, and the section shape.

Each finding is verified adversarially by a second agent with live sources before it counts.

- [ ] **Step 1:** Run the workflow and write the report with confirmed and refuted counts.
- [ ] **Step 2:** One fix dispatch applies every confirmed finding. Add a "Correções aplicadas" section to the report.
- [ ] **Step 3:** Run `scripts/gen-bytecode.sh && scripts/build.sh && scripts/check.sh`. Expected: OK.
- [ ] **Step 4:** Commit with `fix: apply peer review of history chapter and Parts II-IV`.

### Task 10: PR update

- [ ] **Step 1:** Push.
  - Retitle PR #2: `gh pr edit 2 --title "Por que o Java é assim: história das decisões, timeline e revisão"`.
  - Rewrite the body: what was added, the seven questions with where each is answered, benchmark machine/JDK, the peer-review summary and link, and the attribution line `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- [ ] **Step 2:** Run `gh pr checks 2 --watch`. Expected: bytecode, pdf, links and site pass.
  - If links fails on a single transient host timeout, rerun once with `gh run rerun <id> --failed`.
  - A persistent bot-blocking domain gets a commented exclude in `lychee.toml`, as before.
- [ ] **Step 3:** Report to the owner. Do not merge or tag.
