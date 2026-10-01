# Journal of Digital History

A typst template for Journal of Digital History Articles using MyST Markdown.

![](thumbnail.png)

## Usage

The template is used by [jdh-cli](https://github.com/curvenote/jdh-cli) for PDF export. An article's `meta-jdh.yml` points at it:

```yaml
exports:
  - format: pdf
    template: ../../jdh-typst-template
    article: article.md
    output: article.pdf
    qr_code: ./generated/qr.png
    fingerprint: ./generated/fingerprint.png
```

`jdh-cli build` then runs `myst build --pdf` in the article's `_improved/` workdir, so this repo is expected at `../../jdh-typst-template` relative to that folder (or pass `--template`).

## Options and frontmatter

| Option | Type | Purpose |
| --- | --- | --- |
| `qr_code` | file | QR code image shown in the sidebar |
| `fingerprint` | file | Fingerprint image shown in the sidebar |

Required frontmatter: `title`, `authors`. Also read when present: `subtitle`, `short_title`, `open_access`, `keywords`, `date`, `doi`, `venue`, `github`, `first_page`, and the `abstract` part. See `template.yml`.

## JDH theme

`jdh.typ` holds the layout and a `jdh-theme` dictionary of tunable tokens:

| Token | Controls |
| --- | --- |
| `code` | Monospace code: font, size, truncation (`max-lines`, `fade-lines`) |
| `heading`, `paragraph-number` | Heading styles and margin paragraph numbers |
| `hermeneutics` | Cyan full-width blocks (`#hermeneutics-block`) |
| `narrative-code` | Gray full-width code blocks (`#narrative-code-block`) |
| `table` | JDH tables (`#jdh-table-enter` / `#jdh-table-leave`): zebra striping, row and column limits |

The blocks are emitted by jdh-cli's MyST plugins as raw Typst.

Front matter uses the published [pubmatter](https://github.com/continuous-foundation/pubmatter) package (`@preview/pubmatter:0.2.2`). The JDH title block (title font and size from the theme, boxed author cards with affiliations and ORCID) is in `jdh-frontmatter.typ`, built on pubmatter's public functions.

## Fonts

Bundled under `fonts/` and listed in `font-paths.txt`:

- **Libertinus Serif** – body text, footer, sidebar (`theme.font`)
- **Fira Sans** – main article title (`theme.title-font`)
- **Fira Code** – code blocks (`theme.code.font`)

`jdh-cli build` sets `TYPST_FONT_PATHS` to `fonts/fira_code` only; Libertinus Serif and Fira Sans are resolved from system fonts unless installed. To compile with all bundled fonts directly with Typst:

```bash
typst compile \
  --font-path fonts/libertinus_serif \
  --font-path fonts/fira_sans \
  --font-path fonts/fira_code \
  article.typ article.pdf
```
