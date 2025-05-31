#page(margin: (y: 4cm, x: 2cm))[
  #set par(first-line-indent: 0mm)
  #set text(font: ("Calibri", "Noto Sans"))
  #align(
    center,
    [
      #image("images/ntnu_logo_visjon.svg", width: 7cm)
    ],
  )

  #v(6mm)

  #align(center)[
    #text(20pt)[*Manual for processing of \ 3D electron diffraction data using PETS*]
  ]

  #align(center)[
    #text(14pt, gray)[Iver Karlsbakk Småge]
  ]

  #align(horizon)[
    #grid(columns: 3, rows: 2, gutter: 1em)[
      #image("/images/experiment_6/frame_1.png")
      #image("/images/experiment_6/frame_234.png")
    ][
      #image("/images/experiment_6/3d_dist.png")
      #image("/images/experiment_6/camel.png")
    ][
      #image("/images/experiment_6/normal_distribution.png")
      #image("/images/experiment_6/2px_shelx.png")
    ]
  ]

  #align(bottom + center)[
    #text(12pt)[
      Last updated #datetime.today().display("[day].[month].[year]")
    ]
  ]

]
