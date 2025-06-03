#import "@preview/fletcher:0.5.6" as fletcher: diagram, node, edge

#{
  let reciprocal_sections = true
  let dull_teal = teal.desaturate(10%)
  let step-fill = color.lighten(gray, 60%)
  let step-stroke = color.lighten(gray, 10%)

  let end-style = (fill: color.lighten(dull_teal, 60%), stroke: color.lighten(dull_teal, 10%))

  let repeat-style = (stroke: color.lighten(red, 10%))
  let repeat-shift = (..repeat-style, shift: 10pt)

  figure(
    diagram(
      spacing: 1.8em,
      node-fill: step-fill,
      node-stroke: step-stroke,
      edge-stroke: 0.08em,

      node((0, 0), [Set input file + parameters (#ref(<section:pets-params>))], name: <params>),
      edge("-|>"),
      node(
        (0, 1),
        [Peak search (#ref(<section:peak-search>))\ #text(fill: red, [Round 2: Use saved centers])],
        name: <peak_search>,
      ),
      edge("-|>"),
      node((0, 2), [Tilt axis (#ref(<section:tilt-axis>))], name: <tilt_axis>),
      edge("-|>"),
      node((0, 3), [Peak analysis (#ref(<section:peak-analysis>))], name: <peak_analysis>),
      edge("-|>"),
      node(
        (0, 4),
        [Find unit cell, orientation matrix\ and global distortions (#ref(<section:unit-cell>))],
        name: <unit_cell>,
      ),
      edge("-|>"),
      node((0, 5), [Process frames for integration (#ref(<section:process-frames>))], name: <process_frames>),
      edge("-|>"),
      node((0, 6), [Optimize reflection profile (#ref(<section:optimize-profile>))], name: <optimize_reflection>),
      edge("-|>"),
      node(
        (0, 7),
        [Optimize frame geometry: (#ref(<section:frame-geometry>))\ -uniform intensity method\ -$alpha$, $beta$, $omega$, center],
        name: <optimize_frame>,
      ),

      edge(<optimize_frame>, ((-1, 0), "|-", <optimize_frame>), ((-1, 0), "|-", <peak_search>), <peak_search>, "-|>"),

      if (reciprocal_sections) {
        edge(<unit_cell>, "-|>", auto)
      },
      if (reciprocal_sections) {
        node(
          (1, 4),
          [Reciprocal-space sections (#ref(<section:reciprocal-space>))\ determine the symmetry],
          name: <reciprocal_space>,
          ..end-style,
        )
      },
      edge(<process_frames>, "-|>", auto, ..repeat-style),
      node((1, 5), [Finalize integration (#ref(<section:finalize-integration>))], name: <finalize_integration>),
      edge("-|>", ..repeat-style),
      node(
        (1, 6),
        [Optimize frame geometry: (#ref(<section:frame-geometry>))\ -integrated intensity method\ -$alpha$, $beta$, $omega$, center],
        name: <optimize_frame_2>,
      ),
      edge("-|>", ..repeat-style),
      node((1, 7), [Process frames for integration (#ref(<section:process-frames>))], name: <process_frames_2>),
      edge("-|>", ..repeat-style),
      node(
        (1, 8),
        [Finalize integration (#ref(<section:finalize-integration>))\ *final .hkl files*\ (kinematical + dynamical)],
        name: <finalize_integration_2>,
      ),

      edge(<peak_search>, "-|>", <tilt_axis>, ..repeat-shift),
      edge(<tilt_axis>, "-|>", <peak_analysis>, ..repeat-shift),
      edge(<peak_analysis>, "-|>", <unit_cell>, ..repeat-shift),
      edge(<unit_cell>, "-|>", <process_frames>, ..repeat-shift),

      edge((0.9, 0), "-|>", (1.1, 0), label: "round 1", label-anchor: "north-west", label-pos: 1.1),
      edge(
        (0.9, 0.3),
        "-|>",
        (1.1, 0.3),
        ..repeat-style,
        label: text("round 2", fill: repeat-style.stroke),
        label-anchor: "north-west",
        label-pos: 1.1,
      ),
    ),
    caption: [Adapted from section C of the PETS manual #cite(<pets_manual>).],
  )
} <fig:pets-flowchart>
