effect math-ops {
  div-eff(): a // No parameters - if I added parameters (b) wouldn't work
}

fun divide(x: float64, y: float64) {
  x / y
}

fun math-factory(s: int) {
  if s == 1 then div-eff()        // (b)
  // can't return divide(<random float>, <random float>) b/c factory
}

fun main() {
  // Doesn't work because where would x and y come from? Can't add params to the effect
  with handler div-eff() divide(x, y)
}