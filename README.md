# Apostila de Java

Apostila em pt-BR para a disciplina de Java, escrita em LaTeX e compilada para PDF pelo GitHub Actions. Cobre Java e a JVM, a JVM com Quarkus e, em menor profundidade, outras VMs e modelos históricos. Cada capítulo traz um resumo, onde aprofundar (livros, artigos, vídeos), ferramentas e documentação, e desafios práticos.

## PDF

O PDF mais recente fica na Release `latest`:
<https://github.com/amadeu01/java-class/releases/tag/latest>

A Release só passa a existir depois do primeiro merge na branch `main`.

## Compilar localmente

O comando local de build é `scripts/build.sh` (ainda não existe; será adicionado nas próximas tarefas). Requer Docker.

```sh
./scripts/build.sh
```

## Licenças

- Texto da apostila: [CC BY-SA 4.0](LICENSE).
- Código em `examples/`: [MIT](examples/LICENSE).
