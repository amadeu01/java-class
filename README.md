# Apostila de Java

Apostila em pt-BR para a disciplina de Java, escrita em LaTeX e compilada para PDF pelo GitHub Actions. Cobre testes na prática (TDD, dublês, mutação, carga e caos), Java e a JVM, a JVM com Quarkus e, em menor profundidade, outras VMs e modelos históricos, além de apêndices (pesquisa acadêmica, quem fez o Java, glossário). Cada capítulo traz um resumo, onde aprofundar (livros, artigos, vídeos), ferramentas e documentação, e desafios práticos.

## PDF e fonte LaTeX

O site da apostila tem o PDF e a fonte LaTeX da versão atual, a lista de versões e o changelog:
<https://amadeu01.github.io/java-class/>

Cada versão (`vX.Y.Z`) também fica em [Releases](https://github.com/amadeu01/java-class/releases), com `apostila-vX.Y.Z.pdf` e `apostila-latex-vX.Y.Z.zip`. As mudanças estão no [CHANGELOG.md](CHANGELOG.md).

## Compilar localmente

O comando local de build é `scripts/build.sh` e requer Docker. O PDF sai em `latex/build/apostila.pdf`.

```sh
./scripts/build.sh
```

## Publicar uma versão

Antes de criar a tag, atualize o changelog: em `CHANGELOG.md`, renomeie `## [Não lançado]` para `## [X.Y.Z] - AAAA-MM-DD` e abra um novo `## [Não lançado]` vazio acima dele. Faça commit e merge na `main`. O job de release falha se o CHANGELOG não tiver uma seção para a versão.

Um push de tag `vX.Y.Z` cria a release e publica o site no GitHub Pages. Para o deploy da tag passar, o ambiente `github-pages` (Settings > Environments) precisa permitir o branch `main` **e** tags `v*`; sem a regra de tag, o job `pages` falha por proteção de ambiente. Para conferir:

```sh
gh api repos/amadeu01/java-class/environments/github-pages/deployment-branch-policies
```

## Licenças

- Texto da apostila: [CC BY-SA 4.0](LICENSE).
- Código em `examples/`: [MIT](examples/LICENSE).
