#import "@preview/cetz:0.3.4"
#import "@preview/cetz:0.3.4": matrix
#import "@preview/unify:0.7.1": qty, num, unit

#figure(
  caption: [a) The detector consists of 4 smaller detectors that have a small gap between them. b) Side view of the detector geometry. The two layers are a silicon chip (teal) and the four electron detectors (red). c) The detector gap creates pixels at either edge of the border that collect electrons from a larger area than the rest.],
  cetz.canvas({
    import cetz.draw as d
    d.scale(x: 100%, y: -100%) // Flip y coord
    let tred = color.transparentize(red, 60%)
    let lred = color.lighten(red, 30%)
    let tteal = color.transparentize(teal, 60%)
    let lteal = color.lighten(teal, 30%)

    let gap = 0.1
    let w = 4
    let sw = w / 2 - gap
    let t = 0.2
    let m = gap / 2

    d.content((-0.2, -0.2), [a)])
    d.rect((0, 0), (rel: (w, w)), stroke: lteal, fill: tteal)

    // Subdetectors
    d.rect((m, m), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((m, w / 2 + m), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((w / 2 + m, m), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((w / 2 + m, w / 2 + m), (rel: (sw, sw)), stroke: lred, fill: tred)

    d.set-origin((5, 0))
    d.content((-0.2, -0.2), [b)])

    let centering = 0.5
    d.set-origin((0, centering))
    d.rect((0, 0), (rel: (w, t)), stroke: lteal, fill: tteal)
    // subdetectors
    d.rect((m, t), (rel: (sw, t)), stroke: lred, fill: tred)
    d.rect((w / 2 + m, t), (rel: (sw, t)), stroke: lred, fill: tred)
    d.set-origin((0, -centering))

    d.set-origin((0, 2))
    d.content((-0.2, -0.2), [c)])
    let centering = 0.1
    let t = t * 4 // Simulate zooming 3x vertically
    d.set-origin((0, centering))
    d.line((0, 0), (w / 2, 0), (w / 2, t), (0, t), stroke: lteal, fill: tteal)
    d.line((w, 0), (w / 2, 0), (w / 2, t), (w, t), stroke: lteal, fill: tteal)
    // pixels
    for i in range(1, 3) {
      d.line((w / 7 * (i - 0.5), 0), (w / 7 * (i - 0.5), t), stroke: lteal, fill: tteal)
    }
    for i in range(5, 7) {
      d.line((w / 7 * (i + 0.5), 0), (w / 7 * (i + 0.5), t), stroke: lteal, fill: tteal)
    }
    // Missing pixels
    d.line((w / 7 * 2.5, 0), (w / 7 * 2.5, t), stroke: (paint: lteal, dash: "dashed"), fill: tteal)
    d.line((w / 7 * 4.5, 0), (w / 7 * 4.5, t), stroke: (paint: lteal, dash: "dashed"), fill: tteal)

    // subdetectors
    d.line((0, t), (w / 7 * 2.5, t), (w / 7 * 2.5, t * 2), (0, t * 2), stroke: lred, fill: tred)
    d.line((w, t), (w / 7 * 4.5, t), (w / 7 * 4.5, t * 2), (w, t * 2), stroke: lred, fill: tred)
    // pixels
    for i in range(1, 3) {
      d.line((w / 7 * (i - 0.5), t), (w / 7 * (i - 0.5), t * 2), stroke: lred, fill: tred)
    }
    for i in range(5, 7) {
      d.line((w / 7 * (i + 0.5), t), (w / 7 * (i + 0.5), t * 2), stroke: lred, fill: tred)
    }

    // Large pixel
    d.line((w / 7 * 3.5, -0.15), (w / 7 * 5.5, -0.15), mark: (symbol: "|"))
    d.content((w / 7 * 4.5, -0.4), $approx qty("1.1", "um")$)

    // Regular pixel above
    // d.line((w / 7 * 0.5, -0.15), (w / 7 * 1.5, -0.15), mark: (symbol: "|"))
    // d.content((w / 7 * 1, -0.4), qty("0.55", "um"))

    // Gap
    // d.line((w / 7 * 2.5, 2 * t + 0.05), (w / 7 * 4.5, 2 * t + 0.05), mark: (symbol: "|"))
    // d.content((w / 7 * 3.9, 2 * t + 0.36), $approx qty("1.1", "um")$)

    // Regular pixel below
    d.line((w / 7 * 4.5, 2 * t + 0.05), (w / 7 * 5.5, 2 * t + 0.05), mark: (symbol: "|"))
    d.content((w / 7 * 5.5, 2 * t + 0.36), qty("0.55", "um"))

    // d.line((w / 7 * 0.5, 2 * t + 0.05), (w / 7 * 1.5, 2 * t + 0.05), mark: (symbol: "|"))
    // d.content((w / 7 * 0.6, 2 * t + 0.36), qty("0.55", "um"))

    d.set-origin((0, -centering))
  }),
) <fig:detector-gap>

