#import "@preview/cetz:0.3.0"
#import "@preview/codly:1.3.0": *
#import "@preview/physica:0.9.3": *
#import "@preview/subpar:0.2.0": grid
#import "figure-numbering.typ": figure_numbering
#import "@preview/abbr:0.2.3": make as init-acronyms, list as print-index, a as acr, config
#import "_frames.typ": *
#show: frame-style(styles.boxy)

#set document(title: "Reduction of cRED data for structure solution")
#set page(margin: 1.25in)
#set par(spacing: 1.2em, leading: 0.55em, first-line-indent: 0.0em, justify: false)
#set text(font: "New Computer Modern")
#show raw: set text(font: ("MesloLGS NF", "Consolas"))
#show heading: set block(above: 1.4em, below: 1em)
#set heading(numbering: "1.1.1")
#set figure(numbering: figure_numbering)
// #show figure.where(kind: image): set figure(placement: auto)
#set footnote(numbering: "*")

#show page: p => {
  counter(footnote).update(0)
  p
}

#show: codly-init.with()
#codly(display-name: false)
#set math.equation(
  numbering: num => {
    let section_num = counter(heading).get().at(0)
    numbering("(1.1)", section_num, num)
  },
)

#show ref: it => {
  let el = it.element
  if el == none {
    return it
  }
  if el.func() != math.equation {
    return it
  }
  let loc = el.location()
  let eq_counter = counter(math.equation).at(loc)
  let eq_number = eq_counter.at(0)
  let h_counter = counter(heading).at(loc)
  let h_number = h_counter.at(0)
  let supplement = if it.supplement == auto {
    "Equation"
  } else {
    it.supplement
  }
  link(it.target)[#supplement #h_number.#eq_number]
}

#show figure.where(kind: table): set figure.caption(position: top)

#set table(
  stroke: (
    x,
    y,
  ) => (
    left: if x == 0 { 1pt } else { 0pt },
    right: 1pt,
    top: if y == 0 {
      1.2pt
    } else if y == 1 {
      1pt
    } else {
      0pt
    },
    bottom: 1.2pt,
  ),
  // for double line, enable row gutter for first row
  // row-gutter: (2.2pt, auto),
  fill: (x, y) => if calc.odd(y) { rgb("808080").transparentize(90%) } else { none },
)


#show raw.where(block: true): set block(fill: luma(240))
#show raw.where(block: true): set text(size: 6pt)
#show raw.where(block: false): highlight.with(
  fill: luma(220),
  radius: 2pt,
  top-edge: 9pt, // "ascender",
  bottom-edge: -3pt,
  extent: 2pt,
)


#show heading: it => {
  if (it.numbering == none) {
    block(it.body)
  } else if (it.level == 1) {
    counter(math.equation).update(0)
    // Reset numbering counters
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(figure.where(kind: "frame")).update(0)
    block(counter(heading).display() + " " + it.body)
  } else if (it.level > 2) {
    block(it.body) // Disable numbering of headers further than two levels deep
  } else {
    block(counter(heading).display() + " " + it.body)
  }
}

#config(style: x => x)

#init-acronyms(
  ("3D ED", "3D Electron Diffraction"),
  ("CCTBX", "Computational Crystallography Toolbox (software)"),
  ("cRED", "Continuous Rotation Electron Diffraction"),
  ("CTEM", "Conventional TEM"),
  ("ED", "Electron Diffraction"),
  ("FEG", "Field Emission Gun"),
  ("GUI", "Graphical User Interface"),
  ("MOR", "Mordenite"),
  ("PETS", "Process Electron Tilt Series (software)"),
  ("PED", "Precession Electron Diffraction"),
  ("PXRD", "Powder X-Ray Diffraction"),
  ("REDp", "Rotation Electron Diffraction Processing (software)"),
  ("SCXRD", "Single Crystal X-Ray Diffraction"),
  ("STEM", "Scanning Transmission Electron Microscope"),
  ("TEM", "Transmission Electron Microscope"),
  ("XDS", "Xray Diffraction Software (software)"),
  ("XRD", "X-Ray Diffraction"),
  ("ZSM-5", "Zeolite Socony Mobil-5"),
)

// Title page
#include "title.typ"
#counter(page).update(1)
#set page(numbering: "i", number-align: bottom + left)

// Contents
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  set text(size: 11pt)
  strong(it)
  v(0.5pt, weak: false)
}

#outline(indent: auto)
#pagebreak(weak: true)

// #{
//   set table(fill: none)
//   show table.cell.where(x: 0): strong // Make left column bold
//   print-index(title: "Abbreviations", columns: 1)
// }
// #pagebreak(weak: true)

#counter(page).update(1)
#set page(numbering: "1", number-align: bottom + left)

#include "introduction.typ"
#pagebreak(weak: true)
#include "installation.typ"
#pagebreak(weak: true)
#include "tutorial.typ"
#pagebreak(weak: true)

#show bibliography: set heading(outlined: false)
#bibliography("pets_bibliography.bib", style: "iso-690-numeric")
#pagebreak(weak: true)
