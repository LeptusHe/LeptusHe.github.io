#import "@preview/codelst:1.0.0": sourcecode
#import "@preview/physica:0.7.5": *
#import "@preview/showybox:1.1.0": showybox
#import "@preview/splash:0.3.0": *

#import "./math/math-inc.typ": *

// important text
#let im = (content) => {
  let color = tol-muted.green

  set text(fill: color)
  [#content]
}