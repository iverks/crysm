
#import "@preview/cetz:0.3.4"

#figure(
  caption: [How the geometrical distortion affects a row of reflections. a) A row of reflections on the real detector surface. b) How the reconstructed image looks after concatenating the four parts. Gap size exaggerated for illustrative purposes.],
  cetz.canvas({
    import cetz.draw as d
    d.scale(x: 100%, y: -100%) // Flip y coord
    d.stroke((thickness: .1pt))
    let tred = color.transparentize(red, 90%)
    let lred = color.lighten(red, 30%)
    let tteal = color.transparentize(teal, 90%)
    let lteal = color.lighten(teal, 30%)

    let gap = 0.3
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

    // Drawing
    let points = for i in range(0, 6) {
      ((w / 17 * (i + 2), w / 8 * (i + 1.5)),)
    }
    for pt in points {
      d.circle(pt, radius: 0.05, fill: black)
    }
    d.line(..points)

    d.set-origin((5, 0))
    d.content((-0.2, -0.2), [b)])

    // Subdetectors
    d.rect((2 * m, 2 * m), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((2 * m, w / 2), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((w / 2, 2 * m), (rel: (sw, sw)), stroke: lred, fill: tred)
    d.rect((w / 2, w / 2), (rel: (sw, sw)), stroke: lred, fill: tred)

    // If x > w/2: x -= m
    // else x += m
    // If y > w/2: y -= m
    // else y += m

    let points = for pt in points {
      (
        for dim in pt {
          if dim > w / 2 {
            (dim - m,)
          } else {
            (dim + m,)
          }
        },
      )
    }

    for pt in points {
      d.circle(pt, radius: 0.05, fill: black)
    }
    d.line(..points)
  }),
) <fig:detector-gap-geometry>

