# Apostila de Java

Apostila em pt-BR para a disciplina de Java, escrita em LaTeX e compilada para PDF pelo GitHub Actions. Cobre Java e a JVM, a JVM com Quarkus e, em menor profundidade, outras VMs e modelos históricos. Cada capítulo traz um resumo, onde aprofundar (livros, artigos, vídeos), ferramentas e documentação, e desafios práticos.

## PDF e fonte LaTeX

O site da apostila tem o PDF e a fonte LaTeX da versão atual, a lista de versões e o changelog:
<https://amadeu01.github.io/java-class/>

Cada versão (`vX.Y.Z`) também fica em [Releases](https://github.com/amadeu01/java-class/releases), com `apostila-vX.Y.Z.pdf` e `apostila-latex-vX.Y.Z.zip`. As mudanças estão no [CHANGELOG.md](CHANGELOG.md).

## Compilar localmente

O comando local de build é `scripts/build.sh` e requer Docker. O PDF sai em `latex/build/apostila.pdf`.

```sh
./scripts/build.sh
```

## Licenças

- Texto da apostila: [CC BY-SA 4.0](LICENSE).
- Código em `examples/`: [MIT](examples/LICENSE).
