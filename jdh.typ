// Use local pubmatter (development). For the published package, use: #import "@preview/pubmatter:0.2.2"
#import "./pubmatter.typ"

#let venueLogo = "logo-text.svg";

#let jdh-theme = (
    color: black,
    font: "Libertinus Serif",
    title-color: black,
    title-font: "Fira Sans",
    title-size: 23pt,
    title-leading: 0.5em,
    author-box-gap-after-name: 9pt,
    author-box-gap-after-affiliation: 7.6pt,
    author-box-size: 11pt,
    author-box-meta-size: 10.6pt,
    keyword-badges-above: 1.2em,
    keyword-badges-below: 1.2em,
    keyword-badge-border-width: 0.4pt,
    keyword-badge-border-color: gray.darken(50%),
    keyword-badge-radius: 2pt,
    keyword-badge-text-size: 9pt,
    link-color: black,
    ref-color: black,
    body-size: 11pt,
    body-weight: 300,
    body-leading: 1em,
    body-spacing: 3em,
    body-tracking: 0em,
    // Code blocks (plain text, no container/padding/syntax highlighting).
    code: (
      font: "Fira Code",
      size: 8pt,
      weight: 400,
      line-height: 10pt,
      max-lines: 20,
      fade-lines: 6,
      // Rendered-line estimate: `max-lines` applies to estimated wrapped lines,
      // not just newline-separated source lines.
      wrap-estimate-char: "0",
      wrap-width-scale: 1.0,
      more-text-size: 10pt,
      more-text-weight: 400,
      more-text-bottom-inset: -4pt,
    ),
    // Explicit right margin (Typst defaults the right side when only `left` is set,
    // which leaves `page.margin.right` as `auto` and prevents exact bleed maths).
    // Tune with the body column if needed; typical default is ~11% of page width.
    page-margin-right: 11.2%,
    // Heading typography from JDH Figma tokens (px converted to pt at 96dpi).
    // 10px -> 7.5pt, 12px -> 9pt, 14px -> 10.5pt, 20px line-height -> 15pt.
    heading: (
      abstract: (size: 10pt, weight: 700, line_height: 15pt),
      h1: (size: 14pt, weight: 700, line_height: 20pt),
      h2: (size: 12pt, weight: 700, line_height: 20pt),
      h3: (size: 10pt, weight: 700, line_height: 20pt),
    ),
    // Paragraph numbering (margin-anchored counters next to each block).
    paragraph-number: (
      size: 10pt,
      weight: "regular",
      style: "normal",
      fill: gray.darken(20%),
      // Horizontal offset of the number column's left edge from the body
      // text column's left edge (negative = into the left margin).
      margin: 2.5em,
      // Width of the number column; the digits are right-aligned in it,
      // so the right edge sits `margin - width` to the left of the body.
      width: 2em,
      // Vertical offset of the number's top relative to the top of the
      // first line of the anchored block. Used by the heading rule
      // (block-level place anchored at the heading's top edge). 0pt
      // aligns the number's top with the line's top; positive values
      // push it down toward the line's baseline.
      baseline: 0.1em,
      // Same idea, but for paragraphs. The inline `box()` we use to
      // make the place follow page breaks anchors the place at the
      // first line's *baseline* (inline boxes sit on the baseline by
      // default), so we have to shift up by roughly the line's ascent
      // to get the number aligned with the line top. Tune in em units
      // of the body text size.
      inline-baseline: -0.64em,
    ),
    // Hermeneutics blocks (`:::{hermeneutics}`): fill and insets are tunable here.
    hermeneutics: (
      // Background — saturated aqua/cyan (tweak hex to match JDH target PDF).
      fill: rgb("#D3FFF6"),
      // Inset inside the colored block (large left pad vs body; generous vertical pad).
      inset: (left: 2.5em, right: 14pt, top: 18pt, bottom: 18pt),
      // Deliberately over-extend to the right; the page clips it at the edge.
      // This is more robust than trying to resolve Typst's automatic right margin.
      right-outset: 100%,
      code-marker: (
        // Position the marker in the left sidebar column, not in the paragraph
        // number gutter. Coordinates are relative to the padded code content.
        width: 12em,
        dx: -16.5em,
        // Align marker rules with the cyan block edges. These are relative to
        // the code content, which starts after the hermeneutics block inset.
        start-dy: -16.5pt,
        // End marker text sits above the line, so subtract approximately one
        // marker line-height + line gap from the bottom inset.
        end-dy: 4pt,
        text-size: 9pt,
        text-weight: 400,
        text-fill: black,
        stroke-width: 0.8pt,
        stroke-fill: black,
        line-gap: 6pt,
        text-line-height: 6pt,
      ),
    ),
)


#let show-jdh-copyright(fm) = {
  let author-names = if ("authors" in fm and fm.authors.len() > 0) {
    fm.authors.map(author => author.name).join(", ", last: ", and ")
  } else {
    none
  }
  let license-url = "https://creativecommons.org/licenses/by-nc-nd/4.0/"
  [
    © #author-names. Published by De Gruyter in cooperation with the University of Luxembourg Centre for Contemporary and Digital History. This is an Open Access article distributed under the terms of the #link(license-url)[Creative Commons Attribution License CC-BY-NC-ND]
  ]
}

/// Renders keywords as a row of badges (PubMata style).
/// Accepts either a comma-separated string or an array of strings.
#let keywords-badges(theme, keywords-val, above: none, below: none) = {
  let kws = if keywords-val == none {
    ()
  } else if type(keywords-val) == array {
    keywords-val.map(kw => if type(kw) == str { kw.trim() } else { str(kw) }).filter(kw => kw != "")
  } else if type(keywords-val) == str and keywords-val.trim() != "" {
    keywords-val.split(",").map(kw => kw.trim()).filter(kw => kw != "")
  } else {
    ()
  }
  if kws.len() == 0 {
    []
  } else {
    block(
      above: if above != none { above } else { theme.at("keyword-badges-above", default: 1.2em) },
      below: if below != none { below } else { theme.at("keyword-badges-below", default: 0.6em) },
    )[
      #for (i, kw) in kws.enumerate() {
        box(
          inset: (
            left: theme.at("keyword-badge-padding-x", default: 6pt),
            right: theme.at("keyword-badge-padding-x", default: 6pt),
            top: theme.at("keyword-badge-padding-y", default: 5.5pt),
            bottom: theme.at("keyword-badge-padding-y", default: 5.5pt),
          ),
          stroke: theme.at("keyword-badge-border-width", default: 0.5pt) + theme.at("keyword-badge-border-color", default: gray.darken(80%)),
          fill: white,
          radius: theme.at("keyword-badge-radius", default: 3pt),
        )[
          #set text(size: theme.at("keyword-badge-text-size", default: 9pt))
          #kw
        ]
        if i < kws.len() - 1 { h(6pt) }
      }
    ]
  }
}

#let leftCaption(it) = context {
  set text(size: 8pt)
  set align(left)
  set par(justify: true)
  text(weight: "bold")[#it.supplement #it.counter.display(it.numbering)]
  "."
  h(4pt)
  set text(fill: black.lighten(20%), style: "italic")
  it.body
}

#let fullwidth(it) = {
  place(top, dx: -30%, float: true, scope: "parent",
  box(width: 135%, it))
}

#let paragraph-number-left-offset = state("jdh-paragraph-number-left-offset", 0pt)
#let in-hermeneutics-block = state("jdh-in-hermeneutics-block", false)

#let smallTableStyle = (
  map-cells: cell => {
    if (cell.y == 0) {
      return (..cell, content: strong(text(cell.content, 5pt)))
    }
    (..cell, content: text(cell.content, 5pt))
  },
  auto-vlines: false,
  map-hlines: line => {
    if (line.y == 0 or line.y == 1) {
      line.stroke = gray + 1pt;
    } else {
      line.stroke = 0pt;
    }
    return line
  },
)

/// Hermeneutics blocks (methodological commentary) from `:::{hermeneutics}` in MyST.
/// Fill/padding come from `jdh-theme.hermeneutics` via `state("THEME")` (merged in `template`).
/// Right bleed intentionally over-extends; the page clips the fill at the physical edge.
#let hermeneutics-block(body) = context {
  let th = state("THEME").get()
  let theme = if th == none { jdh-theme } else { th }
  let hm-def = jdh-theme.at("hermeneutics")
  let hm = theme.at("hermeneutics", default: hm-def)
  let fill = hm.at("fill", default: hm-def.at("fill"))
  let inset = hm.at("inset", default: hm-def.at("inset"))
  let right-outset = hm.at("right-outset", default: hm-def.at("right-outset"))
  let left-inset = if type(inset) == dictionary {
    inset.at("left", default: 0pt)
  } else {
    inset
  }
  block(
    breakable: true,
    spacing: 1em,
    fill: fill,
    inset: inset,
    outset: (right: right-outset),
  )[
    #in-hermeneutics-block.update(true)
    #paragraph-number-left-offset.update(left-inset)
    #body
    #paragraph-number-left-offset.update(0pt)
    #in-hermeneutics-block.update(false)
  ]
}

#let template(
  frontmatter: (),
  heading-numbering: none,
  kind: none,
  paper-size: "us-letter",
  // The path to a bibliography file if you want to cite some external works.
  page-start: none,
  max-page: none,
  // Build options (e.g. qr_code, fingerprint). Resolved separately in the template.
  options: (),
  // Content parts from the build (e.g. abstract). Resolved separately in the template.
  parts: (),
  // The paper's content.
  body
) = {
  // Top-level dictionaries: fm from frontmatter only; options and parts as passed (per template.yml).
  let fm0 = pubmatter.load(frontmatter)
  let venue_value = if (type(frontmatter) == dictionary) { frontmatter.at("venue", default: none) } else { none }
  let github_value = if (type(frontmatter) == dictionary) { frontmatter.at("github", default: none) } else { none }
  let fm = fm0 + (
    open-access: true,
    license: (
      id: "CC-BY-NC-ND-4.0",
      name: "Creative Commons Attribution Non Commercial No Derivatives 4.0 International",
      url: "https://creativecommons.org/licenses/by-nc-nd/4.0/",
    ),
    venue: (if venue_value != none { venue_value } else { fm0.at("venue", default: none) }),
    github: github_value,
  )
  let options = if (type(options) == dictionary) { options } else { (:) }
  let parts = if (type(parts) == dictionary) { parts } else { (:) }
  let parts_abstract = parts.at("abstract", default: none)
  let nested_parts = fm.at("parts", default: ())
  let nested_parts_abstract = if (type(nested_parts) == dictionary) { nested_parts.at("abstract", default: none) } else { none }
  let abstract_content = if (parts_abstract != none) {
    parts_abstract
  } else if (nested_parts_abstract != none) {
    nested_parts_abstract
  }
  let dates;
  if ("date" in fm and type(fm.date) == datetime) {
    dates = ((title: "Published", date: fm.date),)
  } else {
    dates = date
  }

  // Set document metadata.
  set document(title: fm.title, author: fm.authors.map(author => author.name))
  // Font resolution: Typst looks up font names in --font-path dirs, then system fonts.
  // Bundled paths are listed in font-paths.txt; use scripts/compile-with-fonts.sh TEMPLATE_ROOT input.typ [output].
  let theme = jdh-theme
  let heading-theme = theme.heading
  let pnum-theme = theme.at("paragraph-number", default: (
    size: 9pt,
    weight: "regular",
    style: "normal",
    fill: gray.darken(20%),
    margin: 3em,
    width: 2em,
    baseline: 0.1em,
    inline-baseline: -0.75em,
  ))

  // --- Paragraph numbering helpers ---
  // Numbers each top-level block (paragraphs, headings) sequentially in
  // the left margin, matching the JDH Figma design. Code blocks step the
  // counter but suppress the displayed number. Based on the option-4
  // workaround from https://github.com/typst/typst/issues/5001.
  // Defined up here (before the show-heading rule) so the heading rule
  // can inject `p-display` *inside* its block to align the number with
  // the heading text rather than the spacing above it.
  let p-counter = counter("jdh-paragraph")
  let p-step = p-counter.step()
  // The `p-skip` state suppresses the show-par numbering for paragraphs
  // emitted inside a heading body (Typst auto-wraps heading text in a
  // paragraph, which would otherwise double-step the counter).
  let p-skip = state("jdh-p-skip", false)
  // Block-level number used by the heading rule (emitted at block scope
  // before the heading text). Headings rarely break across pages so a
  // simple `place()` at flow position is sufficient.
  //
  // The whole call is wrapped in `text(size: theme.body-size)` so any
  // `em` units in the theme (margin, width, baseline) are resolved
  // against the body font size rather than the surrounding context.
  // Otherwise headings (with their larger font) would push the number
  // further left than the paragraph version, causing the columns to
  // not line up.
  let p-display = context {
    let left-offset = paragraph-number-left-offset.get()
    text(size: theme.body-size, place(
      left,
      dx: -pnum-theme.margin - left-offset,
      dy: pnum-theme.at("baseline", default: 0pt),
      box(
        width: pnum-theme.width,
        align(right + top, text(
          size: pnum-theme.size,
          weight: pnum-theme.weight,
          style: pnum-theme.style,
          fill: pnum-theme.fill,
          p-counter.display("1"),
        )),
      ),
    ))
  }
  // Inline variant used by the paragraph rule. Wrapping `place()` in a
  // zero-size `box()` lets the place call live *inside* the paragraph
  // body, so its vertical anchor is the paragraph's first line rather
  // than the flow position before the paragraph. This keeps the number
  // with its paragraph across page breaks (otherwise the place lands at
  // the bottom of the previous page when a paragraph starts after a
  // page break). The outer `text(size: ...)` keeps em units resolved
  // against the body size so the inline column lines up exactly with
  // the heading column.
  let p-display-inline = context {
    let left-offset = paragraph-number-left-offset.get()
    text(size: theme.body-size, box(width: 0pt, height: 0pt, place(
      left,
      dx: -pnum-theme.margin - left-offset,
      dy: pnum-theme.at("inline-baseline", default: -0.75em),
      box(
        width: pnum-theme.width,
        align(right + top, text(
          size: pnum-theme.size,
          weight: pnum-theme.weight,
          style: pnum-theme.style,
          fill: pnum-theme.fill,
          p-counter.display("1"),
        )),
      ),
    )))
  }

  if (page-start != none) {counter(page).update(page-start)}
  state("THEME").update(theme)
  set page(
    paper: paper-size,
    margin: (left: 25%, right: theme.page-margin-right),
    header: none,
    footer: block(
      width: 100%,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
        context [
        #set text(font: theme.font, size: theme.body-size, fill: gray.darken(50%))
        #pubmatter.show-spaced-content((
          if("venue" in fm) {
            if type(fm.venue) == dictionary and "title" in fm.venue { emph(fm.venue.title) }
            else if type(fm.venue) == str { emph(fm.venue) }
          },
        ))
        #h(1fr)
        #counter(page).display() of #counter(page).final().first()
      ]
    ),
  )

  let logo = [
    #image(venueLogo, width: 100%)
  ]

  let fingerprint_path = options.at("fingerprint", default: none)
  let fingerprint = if (fingerprint_path != none and type(fingerprint_path) == str and fingerprint_path != "") {
    [#image(fingerprint_path, width: 100%)]
  } else {
    none
  }

  show link: it => [#text(fill: theme.link-color)[#it]]
  show ref: it => {
    if (it.element == none)  {
      // This is a citation showing 2024a or [1]
      show regex("([\d]{1,4}[a-z]?)"): it => text(fill: theme.ref-color, it)
      it
      return
    }
    // The rest of the references, like `Figure 1`
    set text(fill: theme.ref-color)
    it
  }

  // Set the body font.
  set text(font: theme.font, size: theme.body-size, weight: theme.body-weight, tracking: theme.body-tracking)
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings: numbering is disabled for this template.
  set heading(numbering: none)
  show heading: it => context {
    let loc = here()
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(size: heading-theme.h3.size, weight: heading-theme.h3.weight)
    set par(leading: heading-theme.h3.line_height)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement],[Acknowledgments], [Acknowledgements])
      // #set align(center)
      #set text(
        size: if is-ack { heading-theme.abstract.size } else { heading-theme.h1.size },
        weight: if is-ack { heading-theme.abstract.weight } else { heading-theme.h1.weight },
      )
      #set par(leading: if is-ack { heading-theme.abstract.line_height } else { heading-theme.h1.line_height })
      #show: smallcaps
      #show: block.with(above: 20pt, below: 13.75pt, sticky: true)
      // Paragraph number is placed *inside* the block so its `place()` is
      // anchored to the heading text's top, not to the above-spacing.
      #p-display
      #p-step
      // Skip paragraph numbering inside the heading body (Typst auto-
      // wraps the body in a paragraph that would otherwise double-step
      // the counter via the `show par` rule).
      #p-skip.update(true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #p-skip.update(false)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(size: heading-theme.h2.size, weight: heading-theme.h2.weight, style: "italic")
      #set par(leading: heading-theme.h2.line_height)
      #show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      #p-display
      #p-step
      #p-skip.update(true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #p-skip.update(false)
    ] else [
      // Third level headings are run-ins too, but different.
      #set text(size: heading-theme.h3.size, weight: heading-theme.h3.weight)
      #set par(leading: heading-theme.h3.line_height)
      #show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      #p-display
      #p-step
      #p-skip.update(true)
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body)_
      #p-skip.update(false)
    ]
  }
  if (logo != none) {
    place(
      top,
      dx: -33%,
      dy: -40pt,
      float: false,
      box(width: 70pt, logo),
    )
  }
  if (fingerprint != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(width: 27%, fingerprint),
    )
  }


  // Title and subtitle
  pubmatter.show-title-block(fm)

  // Render abstract section directly under authors when present:
  // title -> keyword badges -> abstract body (italic).
  if (abstract_content != none) {
    block(above: 1em, below: 0.6em)[
      #set text(font: theme.font, size: theme.body-size, weight: theme.body-weight, tracking: theme.body-tracking)
      #text(fill: theme.color, weight: "semibold", "Abstract")
      #parbreak()
      #keywords-badges(theme, fm.at("keywords", default: none))
      #parbreak()
      #set par(justify: true, leading: theme.body-leading)
      #text(style: "italic", abstract_content)
    ]
  } else {
    // Without abstract, keep keywords immediately after authors.
    keywords-badges(theme, fm.at("keywords", default: none))
  }

  let corresponding = fm.authors.filter((author) => "email" in author).at(0, default: none)
  let qr_code_path = options.at("qr_code", default: none)
  let margin = (
    (
      title: "Publication",
      content: [
        #set par(justify: true)
        #set text(size: 7pt)
        Digital Tools\
        #let pub-date = fm.at("date", default: none)
        #if type(pub-date) == datetime {
          "Published on " + pub-date.display("[month repr:short] [day], [year]")
        } else {
          "Unknown"
        }\

        #let doi-val = fm.at("doi", default: none)
        #if type(doi-val) == str and doi-val != "" {
          let doi-href = if doi-val.starts-with("https://doi.org/") { doi-val } else if doi-val.starts-with("http") { doi-val } else { "https://doi.org/" + doi-val }
          let doi-disp = if doi-val.starts-with("https://doi.org/") { "doi.org/" + doi-val.slice(18) } else if doi-val.starts-with("http") { doi-val } else { "doi.org/" + doi-val }
          link(doi-href, doi-disp)
        } else {
          "DOI unknown"
        }\

        #let venue-url = if type(fm.venue) == dictionary and "url" in fm.venue and fm.venue.url != "" { fm.venue.url } else { none }
        #let venue-title = if type(fm.venue) == dictionary and "title" in fm.venue { fm.venue.title } else if type(fm.venue) == str { fm.venue } else { "Venue" }
        #if venue-url != none {
          link(venue-url, venue-title)
        } else {
          "URL unknown"
        }
      ],
    ),
    (
      title: [License #h(1fr) #pubmatter.show-license-badge(fm)],
      content: [
        #set par(justify: true)
        #set text(size: 7pt)
        #show-jdh-copyright(fm)
      ]
    ),
    if corresponding != none {
      (
        title: "Correspondence to",
        content: [
          #corresponding.name\
          #link("mailto:" + corresponding.email)[#corresponding.email]
        ],
      )
    },
    (
      title: "Github Repository",
      content: [
        #if type(fm.github) == str and fm.github != "" {
          link(fm.github, fm.github)
        } else {
          "Unknown repository"
        }
      ],
    ),
    (
      title: "Partners",
      content: [
        #set par(justify: true)
        #set text(size: 7pt)
        This Open Access article was published by De Gruyter in cooperation with the University of Luxembourg Centre for Contemporary and Digital History.
      ]
    ),
    if (qr_code_path != none and type(qr_code_path) == str and qr_code_path != "") {
      (
        title: "Explore the full interactive article",
        content: [
          #image(qr_code_path, width: 1.2cm, height: 1.2cm)
        ]
      )
    }
  ).filter((m) => m != none)

  place(
    left + bottom,
    dx: -33%,
    dy: -10pt,
    box(width: 27%, {
      set text(font: theme.font)
      grid(columns: 1, gutter: 2em, ..margin.map(side => {
        text(size: 7pt, {
          if ("title" in side) {
            text(fill: theme.title-color, weight: "bold", side.title)
            [\ ]
          }
          set enum(indent: 0.1em, body-indent: 0.25em)
          set list(indent: 0.1em, body-indent: 0.25em)
          side.content
        })
      }))
    }),
  )

  show par: set par(spacing: theme.body-spacing, justify: true, leading: theme.body-leading)

  let hermeneutics-code-marker = (label, kind: "start", dy: 0pt) => context {
    let hm-def = jdh-theme.at("hermeneutics")
    let hm = theme.at("hermeneutics", default: hm-def)
    let marker-def = hm-def.at("code-marker")
    let marker = hm.at("code-marker", default: marker-def)
    let marker-width = marker.at("width", default: marker-def.at("width"))
    let marker-dx = marker.at("dx", default: marker-def.at("dx"))
    let marker-stroke = marker.at("stroke", default: marker.at("stroke-width", default: marker-def.at("stroke-width")) + marker.at("stroke-fill", default: marker-def.at("stroke-fill")))
    let marker-line = line(length: 100%, stroke: marker-stroke)
    let marker-label = {
      set text(
        font: theme.at("code", default: jdh-theme.code).at("font", default: "Fira Code"),
        size: marker.at("text-size", default: marker-def.at("text-size")),
        weight: marker.at("text-weight", default: marker-def.at("text-weight")),
        fill: marker.at("text-fill", default: marker-def.at("text-fill")),
      )
      set par(leading: marker.at("text-line-height", default: marker-def.at("text-line-height")))
      align(center, label)
    }
    place(
      left,
      dx: marker-dx,
      dy: dy,
      box(width: marker-width)[
        #if kind == "end" {
          stack(
            dir: ttb,
            spacing: marker.at("line-gap", default: marker-def.at("line-gap")),
            marker-label,
            marker-line,
          )
        } else {
          stack(
            dir: ttb,
            spacing: marker.at("line-gap", default: marker-def.at("line-gap")),
            marker-line,
            marker-label,
          )
        }
      ],
    )
  }

  show raw.where(block: true): (it) => {
      let code-theme = theme.at("code", default: jdh-theme.code)
      set text(
        font: code-theme.at("font", default: "Fira Code"),
        size: code-theme.at("size", default: 10pt),
        weight: code-theme.at("weight", default: 400),
      )
      set raw(theme: none)
      set par(leading: code-theme.at("line-height", default: 16pt))
      set align(left)
      layout(size => context {
        let code-lines-all = it.text.split("\n")
        let code-lines = if code-lines-all.len() > 0 and code-lines-all.at(code-lines-all.len() - 1) == "" {
          code-lines-all.slice(0, code-lines-all.len() - 1)
        } else {
          code-lines-all
        }
        let line-height = code-theme.at("line-height", default: 16pt)
        let max-lines = code-theme.at("max-lines", default: 15)
        let estimate-char = code-theme.at("wrap-estimate-char", default: "0")
        let wrap-scale = code-theme.at("wrap-width-scale", default: 1.0)
        let char-width = measure(text(
          font: code-theme.at("font", default: "Fira Code"),
          size: code-theme.at("size", default: 10pt),
          weight: code-theme.at("weight", default: 400),
          estimate-char,
        )).width
        let chars-per-line = calc.max(1, calc.floor((size.width * wrap-scale) / char-width))
        let estimated-line-count = {
          let n = 0
          for line in code-lines {
            let chars = line.clusters().len()
            n += calc.max(1, calc.ceil(chars / chars-per-line))
          }
          n
        }
        let hidden-lines = if estimated-line-count > max-lines { estimated-line-count - max-lines } else { 0 }
        let code-body = if hidden-lines > 0 {
          let fade-lines = code-theme.at("fade-lines", default: 2)
          let fade-height = fade-lines * line-height
          let hm-def = jdh-theme.at("hermeneutics")
          let hm = theme.at("hermeneutics", default: hm-def)
          let fade-fill = if in-hermeneutics-block.get() {
            hm.at("fill", default: hm-def.at("fill"))
          } else {
            white
          }
          block(height: max-lines * line-height)[
            #block(
              height: max-lines * line-height,
              clip: true,
            )[
              #it
            ]
            #place(
              bottom,
              scope: "parent",
              float: true,
              block(
                width: 100%,
                height: fade-height,
                fill: gradient.linear(fade-fill.transparentize(100%), fade-fill, angle: 90deg),
              )[
              #align(center + bottom)[
                #box(inset: (bottom: code-theme.at("more-text-bottom-inset", default: 1pt)))[
                  #text(
                    font: theme.font,
                    size: code-theme.at("more-text-size", default: theme.body-size),
                    weight: code-theme.at("more-text-weight", default: theme.body-weight),
                    fill: theme.color,
                  )[
                    #hidden-lines #if hidden-lines == 1 { "line more" } else { "lines more" }
                  ]
                  ]
                ]
              ],
            )
          ]
        } else {
          it
        }
        if in-hermeneutics-block.get() {
          let hm-def = jdh-theme.at("hermeneutics")
          let hm = theme.at("hermeneutics", default: hm-def)
          let marker-def = hm-def.at("code-marker")
          let marker = hm.at("code-marker", default: marker-def)
          [
            #p-skip.update(true)
            #hermeneutics-code-marker([HERMENEUTICS\ CODE EXCERPT], kind: "start", dy: marker.at("start-dy", default: marker-def.at("start-dy")))
            #code-body
            #hermeneutics-code-marker([END], kind: "end", dy: marker.at("end-dy", default: marker-def.at("end-dy")))
            #p-skip.update(false)
          ]
        } else {
          code-body
        }
      })
  }
  show figure.caption: leftCaption
  show figure.where(kind: "table"): set figure.caption(position: top)
  set figure(placement: auto)

  set bibliography(title: text(10pt, "References"), style: "ieee")
  show bibliography: (it) => {
    set text(7pt)
    set block(spacing: 0.9em)
    it
  }

  // --- Paragraph numbering show rules ---
  // (Counter and `p-display` are defined near the top of the function so
  // the heading show rule can reuse them.) Headings handle the number
  // injection themselves inside their block; here we cover paragraphs
  // (display before, step inside, with a recursion guard) and code
  // blocks (which intentionally do not affect paragraph numbering).
  show par: it => context {
    // Skip numbering for paragraphs inside headings (handled directly
    // by the heading show rule) and for our own recursive wrap.
    let first-child = it.body.at("children", default: ()).at(0, default: none)
    if p-skip.get() {
      it
    } else if first-child == p-display-inline or first-child == p-step {
      it
    } else {
      // Inject the number *inside* the paragraph body via a zero-size
      // box so its vertical anchor follows the paragraph's first line
      // across page breaks. (Emitting `place()` at block level before
      // the par leaves the number at the bottom of the previous page
      // when the paragraph itself starts on the next page.) The display
      // must run *before* `p-step` so it reads the pre-step counter
      // value; otherwise every paragraph would render `n+1`.
      par(p-display-inline + p-step + it.body)
    }
  }
  // Start counting from 1: the display reads the counter *before* its
  // accompanying step, so without this bump the first paragraph shows 0.
  p-counter.update(1)

  // Display the paper's contents.
  body
}
