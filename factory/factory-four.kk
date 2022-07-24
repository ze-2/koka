effect math {
  ctl div-by-zero(): string
  ctl less-than-zero-sqrt(): float64
  ctl less-than-zero-fact(): float64
}

type math-ops
  FactOp
  SqrtOp
  DivOp
  MultOp


fun divide(x: float64, y: float64) : <math> float64
  if y == 0.0 then div-by-zero() else x / y

fun sqrt(x: float64) : <math> float64
  if x < 0.0 then
    less-than-zero-sqrt()
  else
    return (x ^ 0.5)

fun factorial(x: float64): <math, div> float64
  if x < 0.0 then
    less-than-zero-fact()
  else
    if x == 0.0 then return 1.0
    var i := 0.0
    var y := 1.0
    while {i <= x - 1.0}
      i := i + 1.0
      y := y * i

    return y

fun multiply(x: float64, y: float64) : float64
  x * y

// Call one-parameter functions
fun math-factory-one(op: math-ops) : <math, exn> ((x: float64) -> <div, math|_e> float64)
  match op
    FactOp -> factorial
    SqrtOp -> sqrt


// Call two-parameter functions
fun math-factory-two(op: math-ops) : <math, exn> ((x: float64, y: float64) -> <math|_e> float64)
  match op
    DivOp -> divide
    MultOp -> multiply


fun main() {
  with handler {
    ctl div-by-zero() {
      println("Cannot divide by zero")
      resume(0.0)
    }

    ctl less-than-zero-sqrt() {
      println("Cannot square root numbers that are less than zero")
      resume(0.0)
    }

    ctl less-than-zero-fact() {
      println("Cannot apply the factorial function numbers less than 0")
      resume(0.0)
    }
  }

  /* math-factory-one(FactOp)
    math-factory-one(SqrtOp)
    math-factory-two(DivOp)
    math-factory-two(MultOp) */

  var d := math-factory-two(DivOp)
  println(d(12.0, 0.0))
  println(d(12.0, 2.0))
}