// JDH title block: title and boxed author cards, built on published pubmatter.
// These were local changes to pubmatter; they live here so the template
// depends only on the published package.
#import "@preview/pubmatter:0.2.2"

#let normalize-orcid(orcid) = {
  if (type(orcid) != str) { return none }
  if (orcid.starts-with("https://orcid.org/")) {
    return orcid.slice(18)
  }
  orcid
}

#let resolve-affiliation-name(affiliation, fm) = {
  if (type(affiliation) == str and affiliation != "") {
    return affiliation
  }
  if (type(affiliation) == dictionary) {
    if ("name" in affiliation) { return affiliation.name }
    if ("institution" in affiliation) { return affiliation.institution }
    if ("index" in affiliation and type(fm) == dictionary and "affiliations" in fm) {
      let hit = fm.affiliations.filter(item => item.index == affiliation.index).at(0, default: none)
      if (hit != none and "name" in hit) { return hit.name }
      if (hit != none and "institution" in hit) { return hit.institution }
    }
  }
  if (type(fm) == dictionary and "affiliations" in fm) {
    let hit = fm.affiliations.filter(item => item.index == affiliation).at(0, default: none)
    if (hit != none and "name" in hit) { return hit.name }
    if (hit != none and "institution" in hit) { return hit.institution }
  }
  none
}

#let author-affiliations-text(author, fm) = {
  if ("affiliations" not in author) { return none }
  let items = if (type(author.affiliations) == array) { author.affiliations } else { (author.affiliations,) }
  let names = items.map(item => resolve-affiliation-name(item, fm)).filter(item => item != none and item != "")
  if (names.len() == 0) { return none }
  names.join("; ")
}

/// Authors as a grid of cards: name, affiliations, then ORCID / GitHub / email.
/// Sizes and gaps come from the theme (`author-box-*`).
#let show-authors-boxed(
  size: 10pt,
  weight: "semibold",
  show-orcid: true,
  show-email: true,
  show-github: true,
  fm,
) = {
  let authors = if (type(fm) == dictionary and "authors" in fm) { fm.authors } else if (type(fm) == array) { fm } else { () }
  if authors.len() == 0 { return none }
  let columns = if (authors.len() == 1) { (1fr,) } else if (authors.len() <= 4) { (1fr, 1fr) } else { (1fr, 1fr, 1fr) }

  return box(inset: (top: 10pt, bottom: 5pt), width: 100%, {
    pubmatter.with-theme((theme) => {
      let author-size = theme.at("author-box-size", default: size)
      let author-meta-size = theme.at("author-box-meta-size", default: author-size - 1pt)
      grid(columns: columns, gutter: (8pt, 8pt), ..authors.map(author => {
        box(
          inset: (x: 8pt, y: 7pt),
          width: 100%,
          {
            set text(font: theme.font)
            set par(spacing: 0pt)
            let gap-after-name = theme.at("author-box-gap-after-name", default: 0.2em)
            let gap-after-affiliation = theme.at("author-box-gap-after-affiliation", default: gap-after-name)
            let affiliation-line = author-affiliations-text(author, fm)
            let identifiers = (
              if (show-orcid and "orcid" in author and normalize-orcid(author.orcid) != none) {
                [#pubmatter.orcid-link(orcid: author.orcid)#h(3pt)#normalize-orcid(author.orcid)]
              },
              if (show-github and "github" in author) {
                [#pubmatter.github-link(github: author.github)#h(3pt)#author.github]
              },
              if (show-email and "email" in author) {
                [#pubmatter.email-link(email: author.email)#h(3pt)#author.email]
              },
            )
            let identifiers-line = if (identifiers.filter(item => item != none).len() > 0) {
              text(size: author-meta-size, fill: gray.darken(20%), pubmatter.show-spaced-content(identifiers))
            } else {
              none
            }
            // Build the rows + per-row gutters explicitly so spacing is fully
            // under our control, unaffected by paragraph/block defaults.
            let rows = (text(size: author-size, weight: weight, author.name),)
            let gutters = ()
            if (affiliation-line != none) {
              gutters = gutters + (gap-after-name,)
              rows = rows + (text(size: author-meta-size, fill: gray.darken(45%), affiliation-line),)
            }
            if (identifiers-line != none) {
              let g = if affiliation-line != none { gap-after-affiliation } else { gap-after-name }
              gutters = gutters + (g,)
              rows = rows + (identifiers-line,)
            }
            grid(columns: (1fr,), row-gutter: gutters, ..rows)
          },
        )
      }))
    })
  })
}

/// Boxed author cards for up to `max-box-authors` authors; pubmatter's list otherwise.
#let show-author-block(max-box-authors: 6, fm) = {
  let authors = if (type(fm) == dictionary and "authors" in fm) { fm.authors } else { () }
  if (authors.len() > 0 and authors.len() <= max-box-authors) {
    show-authors-boxed(fm)
  } else {
    pubmatter.show-authors(fm)
    pubmatter.show-affiliations(fm)
  }
}

/// Title and subtitle; font, size and leading come from the theme
/// (`title-font`, `title-size`, `title-leading`).
#let show-title(fm) = {
  pubmatter.with-theme(theme => {
    let title-font = if ("title-font" in theme and theme.title-font != "") { theme.title-font } else { theme.font }
    let title-size = if ("title-size" in theme) { theme.title-size } else { 17pt }
    let title-leading = if ("title-leading" in theme) { theme.title-leading } else { 1.05em }
    set text(font: title-font)
    set par(leading: title-leading, spacing: 0em)
    let title = if (type(fm) == dictionary and "title" in fm) {fm.title} else if (type(fm) == str or type(fm) == content) { fm } else { none }
    let subtitle = if (type(fm) == dictionary and "subtitle" in fm) {fm.subtitle} else { none }
    if (title != none) {
      box(inset: (bottom: 2pt), width: 100%, text(title-size, font: title-font, weight: "bold", fill: theme.color, title))
    }
    if (subtitle != none) {
      parbreak()
      box(width: 100%, text(12pt, fill: gray.darken(30%), subtitle))
    }
  })
}

/// Title block: title, then authors.
#let show-title-block(fm) = {
  pubmatter.with-theme(theme => {
    show-title(fm)
    show-author-block(fm)
  })
}
