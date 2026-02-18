// Use local pubmatter (development). For the published package, use: #import "@preview/pubmatter:0.2.2"
#import "./pubmatter.typ"

#let venueLogo = "logo-text.svg";

#let jdh-theme = (
    color: black,
    font: "Libertinus Serif",
    title-color: black,
    title-font: "Fira Sans",
    link-color: black,
    ref-color: black,
    body-size: 10pt,
    body-weight: 300,
    body-leading: 1em,
    body-tracking: 0em,
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
#let keywords-badges(keywords-val) = {
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
    block(above: 0.6em, below: 0.6em)[
      #for (i, kw) in kws.enumerate() {
        box(inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 5pt), stroke: 0.5pt + gray.darken(80%), fill: white, radius: 3pt)[#set text(size: 8pt); #kw]
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

#let template(
  frontmatter: (),
  heading-numbering: "1.1.1",
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
  let options = if (type(options) == dictionary) { options } else { () }
  let parts = if (type(parts) == dictionary) { parts } else { () }
  let parts_abstract = parts.at("abstract", default: none)
  let abstract_content = if (parts_abstract != none) { parts_abstract } else { fm.at("abstract", default: none) }
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

  if (page-start != none) {counter(page).update(page-start)}
  state("THEME").update(theme)
  set page(
    paper: paper-size,
    margin: (left: 25%),
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
          if("date" in fm and fm.date != none) {fm.date.display("[month repr:long] [day], [year]")}
        ))
        #h(1fr)
        #counter(page).display()
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

  // Configure headings.
  set heading(numbering: heading-numbering)
  show heading: it => context {
    let loc = here()
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement],[Acknowledgments], [Acknowledgements])
      // #set align(center)
      #set text(if is-ack { 10pt } else { 12pt })
      #show: smallcaps
      #show: block.with(above: 20pt, below: 13.75pt, sticky: true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
    ] else [
      // Third level headings are run-ins too, but different.
      #show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body)_
    ]
  }
  if (logo != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(
        width: 27%,
        {
          logo
          if fingerprint != none {
            v(1em)
            fingerprint
          }
        },
      ),
    )
  }


  // Title and subtitle
  pubmatter.show-title-block(fm)

  // Keywords as badges (PubMata style), immediately after authors
  keywords-badges(fm.at("keywords", default: none))

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

  if (abstract_content != none) {
    pubmatter.show-abstract-block(fm + (abstract: abstract_content))
  }

  show par: set par(spacing: 1.4em, justify: true, leading: theme.body-leading)

  show raw.where(block: true): (it) => {
      set text(size: 6pt)
      set align(left)
      block(sticky: true, fill: luma(240), width: 100%, inset: 10pt, radius: 1pt, it)
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

  // Display the paper's contents.
  body
}
