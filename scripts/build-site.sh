#!/usr/bin/env bash
# Gera public/ (index.html, apostila.pdf, apostila-latex.zip, estilo.css).
# Uso: scripts/build-site.sh [PDF]   (PDF padrão: $APOSTILA_PDF ou latex/build/apostila.pdf)
# Env: GITHUB_REPOSITORY (padrão amadeu01/java-class); GH_TOKEN opcional (lista de releases).
# Sem releases ou sem gh: mostra só a versão em desenvolvimento.
set -euo pipefail
cd "$(dirname "$0")/.."
repo="${GITHUB_REPOSITORY:-amadeu01/java-class}"
pdf="${1:-${APOSTILA_PDF:-latex/build/apostila.pdf}}"
[ -f "$pdf" ] || { echo "build-site: PDF não encontrado: $pdf" >&2; exit 1; }

rm -rf public && mkdir -p public
cp "$pdf" public/apostila.pdf
cp site/estilo.css public/estilo.css
zip="$(scripts/package-latex.sh dev)"
cp "$zip" public/apostila-latex.zip

# Markdown -> HTML (pandoc local, ou container fixado)
if command -v pandoc >/dev/null; then
  pandoc() { command pandoc "$@"; }
else
  pandoc() { docker run --rm -i --user "$(id -u):$(id -g)" pandoc/core:3.6 "$@"; }
fi
sed 1d CHANGELOG.md | pandoc -f gfm -t html --shift-heading-level-by=1 > public/.changelog.html

# Releases (opcional)
releases='[]'
if command -v gh >/dev/null; then
  releases="$(gh release list --repo "$repo" --exclude-drafts --limit 100 \
    --json tagName,publishedAt,isPrerelease 2>/dev/null || echo '[]')"
fi
export REPO="$repo" RELEASES="$releases"
export COMMIT="$(git rev-parse --short HEAD)"
export DATA="$(date -u +%Y-%m-%d)"

python3 -I - <<'PY'
import html, json, os
repo, commit, data = os.environ["REPO"], os.environ["COMMIT"], os.environ["DATA"]
try:
    rels = json.loads(os.environ["RELEASES"] or "[]")
except ValueError:
    rels = []
rels = [r for r in rels if r.get("tagName")]
rels.sort(key=lambda r: r.get("publishedAt", ""), reverse=True)

def btns(pdf, zipf):
    return (f'<a class="btn" href="{pdf}">Baixar PDF</a>'
            f'<a class="btn btn-sec" href="{zipf}">Baixar fonte LaTeX (.zip)</a>')

def rel_urls(tag):
    base = f"https://github.com/{repo}/releases/download/{tag}"
    return f"{base}/apostila-{tag}.pdf", f"{base}/apostila-latex-{tag}.zip"

dev = (f'<p class="meta">Versão em desenvolvimento, gerada da branch <code>main</code> '
       f'(commit <code>{html.escape(commit)}</code>, {html.escape(data)}).</p>'
       f'<div class="botoes">{btns("apostila.pdf", "apostila-latex.zip")}</div>')
if rels:
    tag = html.escape(rels[0]["tagName"])
    p, z = rel_urls(rels[0]["tagName"])
    atual = (f'<h2>Versão atual: {tag}</h2><div class="botoes">{btns(html.escape(p), html.escape(z))}</div>'
             f'<details class="dev"><summary>Versão em desenvolvimento</summary>{dev}</details>')
    linhas = []
    for r in rels:
        t = r["tagName"]; p, z = rel_urls(t)
        pre = " (pré-lançamento)" if r.get("isPrerelease") else ""
        linhas.append(
            f'<li><strong>{html.escape(t)}</strong>{pre} '
            f'<span class="meta">{html.escape(r.get("publishedAt","")[:10])}</span> '
            f'<a href="{html.escape(p)}">PDF</a> · <a href="{html.escape(z)}">LaTeX</a> · '
            f'<a href="https://github.com/{repo}/releases/tag/{html.escape(t)}">notas</a></li>')
    versoes = '<ul class="versoes">' + "".join(linhas) + "</ul>"
else:
    atual = '<h2>Versão em desenvolvimento</h2>' + dev
    versoes = ('<p>Ainda não há versões lançadas. Quando houver, cada uma aparece aqui com '
               'PDF e fonte LaTeX.</p>')

tpl = open("site/template.html", encoding="utf-8").read()
cl = open("public/.changelog.html", encoding="utf-8").read()
out = (tpl.replace("{{ATUAL}}", atual).replace("{{VERSOES}}", versoes)
          .replace("{{CHANGELOG}}", cl).replace("{{REPO}}", repo))
open("public/index.html", "w", encoding="utf-8").write(out)
PY
rm -f public/.changelog.html
touch public/.nojekyll
echo "site: public/index.html"
