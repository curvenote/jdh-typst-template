# Journal of Digital History

A typst template for Journal of Digital History Articles using MyST Markdown.

![](thumbnail.png)

## Fonts

The template uses two font families by name:

- **Libertinus Serif** – body text, footer, sidebar (`theme.font`)
- **Fira Sans** – main article title (`theme.title-font`)

Font paths are defined **inside the template** so you don't have to remember them:

- **`font-paths.txt`** – list of bundled font directories (one per line), relative to the template root.
- **`template.yml`** – `typst.font_paths` mirrors that list for tools or scripts that read YAML.

To compile using these paths (no system fonts required), run the bundled script with the path to this template, then the usual typst input/output:

```bash
# From an article repo that uses this template (e.g. template: ../jdh-typst-template)
../jdh-typst-template/scripts/compile-with-fonts.sh ../jdh-typst-template article.typ article.pdf

# From inside the template repo
./scripts/compile-with-fonts.sh . article.typ article.pdf
```

The script reads `font-paths.txt` and passes each line as `--font-path TEMPLATE_ROOT/<line>` to `typst compile`. Typst still falls back to system fonts if a family name isn't found in those paths.
