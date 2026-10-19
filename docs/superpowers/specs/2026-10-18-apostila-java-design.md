# Apostila da Turma de Java 2 — documento de design

Data: 2026-10-18 · Autor do pedido: Amadeu · Repositório: https://github.com/amadeu01/java-class (público, vazio hoje)

## 1. Intenção e porquê

Amadeu dá aulas para a Turma de Java 2 (CEF e Alun Business, Jornada Reskilling, CaixaVerso 2ª onda). Os alunos precisam de um material único, confiável e bonito, que:

- resuma as aulas já dadas;
- diga onde aprofundar cada assunto (livros, artigos, vídeos, ferramentas, benchmarks);
- adiante os temas das próximas aulas, para quem quiser se preparar.

O fio condutor é prático: entender Java e a JVM a ponto de tomar decisões melhores de código e de arquitetura, sempre ligando ao **Quarkus** (https://quarkus.io/) — como usá-lo bem, como arquitetar para ele e por que ele funciona do jeito que funciona.

Um diferencial pedido explicitamente: **ler bytecode** (`javap` e afins) como ferramenta para entender bugs e problemas e embasar decisões de arquitetura.

## 2. Público

Profissionais em requalificação (reskilling) com Java já em uso no dia a dia; turma "Java 2", portanto não iniciantes absolutos. O texto deve ser acessível, mas não didático demais nos fundamentos da linguagem.

## 3. Objetivos

1. Uma apostila em **LaTeX**, organizada **por tópicos** (capítulos), escrita em **pt-BR**, com **termos técnicos em inglês**. Quando um termo em inglês precisar de explicação, usar **nota de rodapé** com a tradução ou explicação.
2. PDF gerado por **GitHub Action** a cada push/PR.
3. Toda interação com o GitHub (criar branch, push, PR, releases) feita pelo **`gh` CLI**.
4. Conteúdo verificado por **peer review com múltiplos subagentes**, checando cada fonte (links, autores, anos, edições, números de benchmark) contra a internet. Chrome pode ser usado na pesquisa quando necessário.

## 4. Conteúdo (capítulos)

Cada capítulo segue o formato que o `.md` atual já usa: **resumo** → **onde aprofundar** (livros, artigos, vídeos) → **ferramentas/documentação** → **desafios práticos**. Capítulos de aulas ainda não dadas recebem a marca visual **"Próximas aulas"** e trazem material para adiantar; depois da aula, o resumo é acrescentado.

### Parte I — Testes (aulas já dadas)

Fonte: `~/Downloads/Testes na prática resumo das aulas e referências.md`. **O `.md` não é commitado**: o conteúdo dele é reescrito em LaTeX (decisão do Amadeu).

- **Cap. Aula 1 · TDD sob carga (28/09/2026):** ciclos do TDD (Uncle Bob), fake it / triangulação / implementação óbvia (Kent Beck), do pedido ao teste, vocabulário de Fowler/Meszaros (SUT, fixture, quatro fases, cinco dublês), robustez (exemplos, bordas, inválidos, propriedades com jqwik, mutação com PIT), Right-BICEP, desafios.
- **Cap. Aula 2 · Mutação, carga e caos (02/10/2026):** tabela das práticas, PIT e limites (mutantes equivalentes, Goodhart, DORA), carga (tipos, quatro sinais, percentis, modelo aberto, omissão coordenada, load shedding), caos (método experimental, raio de explosão, padrões de resiliência).
- Todas as tabelas de livros, artigos, vídeos e ferramentas do `.md` entram, verificadas pelo peer review.
- **Ponte com Quarkus** (novo): como fazer isso num projeto Quarkus (`@QuarkusTest`, Dev Services/Testcontainers, PIT com Quarkus, SmallRye Fault Tolerance como equivalente ao Resilience4j).

Ordem definida pelo Amadeu para as próximas aulas: **primeiro Java com a JVM** (detalhes, como entender a JVM), **depois como usar a JVM com Quarkus da melhor forma**, **por fim a comparação com outras VMs e modelos históricos**. A profundidade segue essa ordem.

### Parte II — Java e a JVM (próximas aulas, 1º bloco)

Bases pedidas: **Deitel (Java: How to Program / Java: Como Programar)**, **The Clean Coder**, **Clean Architecture** (Robert C. Martin), além de Clean Code e outros que o pesquisador julgar fortes (ex.: *Effective Java*, Joshua Bloch).

- Java moderno relevante para a turma (records, sealed types, pattern matching, virtual threads etc.; escolha final com o builder, priorizando o que muda decisões de código).
- Profissionalismo e disciplina (The Clean Coder).
- **Como a JVM funciona:** class loading, bytecode, interpretador, JIT (C1/C2, tiered compilation), GC (G1, ZGC, Shenandoah, Parallel/Serial, visão geral), modelo de memória.
- **Como entender a JVM na prática:** `javap -c -v`, constant pool, `invokedynamic` (lambdas, concatenação de strings), autoboxing, `switch` de strings, `try-with-resources`, sincronização. Cada exemplo mostra um bug ou uma decisão que o bytecode explica. Ferramentas: `javap`, JITWatch, `-XX:+PrintCompilation`, JFR/JMC, async-profiler.

### Parte III — A JVM com Quarkus, da melhor forma (2º bloco)

- O que o Quarkus faz em build time (augmentation, Jandex, geração de bytecode com Gizmo) e por que isso reduz reflexão e startup, mostrado com bytecode gerado.
- **Arquitetar para Quarkus:** Clean Architecture aplicada (hexagonal/ports & adapters com CDI, onde ficam extensões, Panache, REST), testes (`@QuarkusTest`, Dev Services), resiliência (SmallRye Fault Tolerance), observabilidade.
- **Decisões:** modo JVM vs nativo (GraalVM Native Image), reflexão e o que quebra no nativo, virtual threads vs reativo, tuning de GC e memória em container.
- Onde achar conteúdo: guias oficiais, Quarkus Insights, livros (ex.: *Quarkus in Action*, *Kubernetes Native Microservices with Quarkus*), sujeitos à verificação.

### Parte IV — Outras VMs e modelos históricos (3º bloco)

- **Comparação principal: HotSpot (JVM) × BEAM (Erlang VM) × GraalVM** (JIT Graal e Native Image), com menção a OpenJ9 se útil. Threads do SO / virtual threads vs processos leves da BEAM; GC por heap global vs por processo; "let it crash" e supervisão vs exceções e padrões de resiliência; hot code loading; JIT vs AOT, closed-world assumption.
- **Modelos históricos:** de onde vêm as ideias da JVM (ex.: UCSD p-System/p-code, Smalltalk-80, Self e a origem do HotSpot, CLR/.NET, Dalvik/ART). Escolha final com o pesquisador, sempre ligada ao que explica a JVM de hoje.
- **Benchmarks e números:** apenas fontes publicadas e verificáveis (ex.: TechEmpower, números oficiais do Quarkus de startup/RSS, Renaissance suite, artigos acadêmicos). Cada número traz fonte, data, versão e quem mediu; benchmarks de fornecedor são marcados como tal.
- **Como isso influencia decisões de código:** quando a BEAM seria a ferramenta melhor (e por que não estamos nela), o que levar de ideia dela para Java/Quarkus.
- Livros e artigos (ex.: *Java Performance* de Scott Oaks, *Optimizing Java*, *Designing for Scalability with Erlang/OTP*, *The BEAM Book*, papers do GraalVM/Truffle e do Self). Lista final do pesquisador, sujeita à verificação.

### Apêndices

- **Onde achar conteúdo:** índice geral de livros (marcando edição em português "(PT)"), artigos, vídeos (marcando "(PT)"), cursos, comunidades.
- Glossário pt-BR ↔ inglês.

### 4.1 Organização dos arquivos LaTeX (decisão do Amadeu)

Nada de arquivo único. Um `main.tex` só com preâmbulo e `\input`/`\include`; **um arquivo por conteúdo** (por exemplo, cada seção de um capítulo, cada tabela de referências), e **o que ficar grande é quebrado** em mais arquivos. Sugestão de forma, final com o builder:

```
latex/
  main.tex
  preamble/        (pacotes, cores, macros, glossário)
  parte1-testes/aula1/{ciclos-tdd,pedido-ao-teste,vocabulario,robustez,desafios}.tex
  parte1-testes/aula2/{...}.tex
  parte2-java-jvm/...
  parte3-quarkus/...
  parte4-vms/...
  referencias/{livros,artigos,videos,ferramentas}/...
  apendices/...
  bib/             (.bib divididos por tema)
```

Regra prática minha: quando um arquivo passar de ~150 a 200 linhas ou misturar dois assuntos, ele é dividido.

## 5. Restrições

- Idioma: pt-BR; termos técnicos em inglês; notas de rodapé para traduzir/explicar quando necessário.
- **Nenhuma fonte sem verificação.** Todo link, título, autor, ano, edição e número de benchmark passa pelo peer review. Fonte que não puder ser confirmada sai do texto (ou fica explicitamente marcada como não verificada, nunca silenciosamente).
- Exemplos de bytecode devem ser **saída real** do `javap` sobre código real do repositório, não escritos à mão.
- Repositório público: o `.md` original não é commitado; nada de dados internos da CEF/Alun Business além do nome da turma.

## 6. Anti-objetivos (seria falha mesmo funcionando)

- Referências alucinadas: livro com autor/ano errado, link quebrado, vídeo que não existe, benchmark sem origem.
- Texto genérico de "tutorial de Java" sem ligação com decisões reais e com o Quarkus.
- Apostila em inglês ou com tradução forçada de termos que a indústria usa em inglês.
- PDF que só compila na máquina do Amadeu.

## 7. Peer review (como verificar)

Pedido explícito do Amadeu: múltiplos subagentes com acesso à internet revisando **todo o source e todo o conteúdo**. Mínimo esperado:

- **Verificação de referências:** cada livro/artigo/vídeo/ferramenta checado (existe? autor, ano, edição, link vivo, PT confirmado?).
- **Verificação técnica:** afirmações sobre JVM, BEAM, GraalVM, Quarkus e testes checadas contra documentação oficial ou fonte primária.
- **Verificação de benchmarks:** cada número rastreado até a fonte, com versão e data.
- **Revisão de idioma/estilo:** pt-BR correto, termos em inglês consistentes, notas de rodapé onde fazem falta.
- **Revisão do LaTeX/CI:** compila limpo, sem warnings relevantes (refs indefinidas, overfull grosseiro), Action funciona.

Achados confirmados são corrigidos; o que não puder ser confirmado é removido ou marcado.

## 8. Decisões que foram do Amadeu

- LaTeX + GitHub Action para gerar o PDF; `gh` para tudo no GitHub (push, PR).
- Conteúdo: testes (já dado), Java, JVM, comparação JVM × Erlang VM × GraalVM e modelos históricos, bytecode, Quarkus como fio condutor.
- Ordem: Java com JVM → JVM com Quarkus → outras VMs e modelos históricos.
- Bases: Deitel, The Clean Coder, Clean Architecture.
- Benchmarks, artigos e livros para embasar.
- Peer review com múltiplos subagentes e internet; Chrome permitido.
- pt-BR com termos técnicos em inglês e notas de rodapé.
- LaTeX dividido em múltiplos arquivos por conteúdo; o que ficar grande é quebrado.
- O `.md` original não vai para o repositório; tudo vira LaTeX.
- Palpites aprovados: formato por capítulo (resumo → aprofundar → desafios), capítulos futuros marcados "Próximas aulas", PDF cresce aula a aula.

## 9. Decisões minhas (Claude), para o Amadeu conferir

- **Quarkus:** a Parte III é dedicada a ele, e as Partes I e IV têm uma seção "Ponte com Quarkus".
- **Estrutura do repo:** `latex/` (main + arquivos por conteúdo, ver seção 4.1), `examples/` (código Java pequeno usado nos exemplos de bytecode), `docs/` (este design). Sem `source/`.
- **Nome da turma:** a linha "Turma de Java 2 (CEF e Alun Business, Jornada Reskilling, CaixaVerso 2ª onda)" do `.md` entra no LaTeX como está, já que o Amadeu pediu o conteúdo inteiro em LaTeX.
- **LaTeX:** classe de livro (KOMA-Script `scrbook` ou equivalente), `babel` pt-BR, `biblatex`+`biber` para bibliografia, `hyperref` com links clicáveis, `minted` ou `listings` para código. Compilação com `latexmk`.
- **CI:** Action em container TeX Live (ex.: `xu-cheng/latex-action` ou imagem `texlive`), roda em push e PR, publica o PDF como artifact; em push na `main`, publica o PDF numa GitHub Release "latest" para os alunos baixarem por um link fixo. A Action também compila `examples/` e gera as listagens `javap` (JDK 21 LTS ou 25 LTS), para que o bytecode no PDF seja sempre real.
- **Fluxo GitHub:** commit inicial com README na `main`; todo o trabalho em branch, aberto como PR via `gh`. **Não faço merge** sem o Amadeu pedir.
- **Licença:** CC BY-SA 4.0 para o texto, MIT para os exemplos (repo é público). Fácil de trocar.
- **Benchmarks:** apenas citados de fontes publicadas; não rodamos benchmarks próprios nesta versão.

### Decisões tomadas após a revisão do builder

- **Escopo da v1:** todas as partes (I a V) escritas por completo e revisadas, não só esqueletos. O Amadeu pediu a pesquisa e a escrita "desde agora" para os alunos se adiantarem.
- **JDK das listagens `javap`:** JDK 25 (LTS). O texto avisa quando o bytecode muda entre versões (concatenação de strings via `invokedynamic` desde o 9, pattern matching em `switch`).
- **Desafios práticos:** em texto. Os exemplos de código em `examples/` são pequenos, compilam no CI e servem às listagens de bytecode. Nenhuma solução publicada, porque o repositório é público.
- **Seção 9:** continua como decisão minha, a conferir pelo Amadeu ao ler o documento.

## 10. Deixado para o builder

- Lista final de tópicos de Java moderno, escolha exata de exemplos de bytecode, layout visual do PDF, divisão fina de seções, quais livros/artigos extras entram (desde que verificados), número e organização dos agentes de peer review.
