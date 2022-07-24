// Not sure how to check types
// Not sure how to compare enums to check if it's correct (== doesn't work)

effect math {
  ctl div-by-zero(): a
  ctl not-found(): a
  ctl less-than-zero-sqrt(): a
  ctl less-than-zero-fact(): a
}

fun divide(x: float64, y: float64) : <math> float64
  if y == 0.0 then div-by-zero() else x / y

fun sqrt(x: float64) : <math> float64
  if x < 0.0 then
    less-than-zero-sqrt()
  else
    return (x ^ 0.5)

fun factorial(x: float64): <math, div> float64
  var i := 0.0
  var y := x
  while {i < x}
    i := i + 1.0
    y := y * i

  return y

fun multiply(x: float64, y: float64) : float64
  x * y

// Call one-param functions
fun math-factory-one(s: int) : <math> ((x: float64) -> <div, math|_e> float64)
  if s == 0 then {return factorial}
  if s == 1 then {return sqrt}
  return not-found()

// Call two-param functions
fun math-factory-two(s: int) : <math> ((x: float64, y: float64) -> <math|_e> float64)
  if s == 0 then {return divide}
  if s == 1 then {return multiply}
  return not-found()

fun main() {
  // Can't figure out how to resume
  /*
  with handler {
    ctl div-by-zero() {
      println("Cannot divide by zero")
      resume(())
    }

    ctl not-found() {
      println("Option not found")
      resume(())
    }

    ctl less-than-zero-sqrt() {
      println("Cannot square root numbers that are less than zero")
      resume(())
    }

    ctl less-than-zero-fact() {
      println("Cannot apply the factorial function to 0")
      resume(())
    }
  } */
  with handler
    ctl div-by-zero() println("Cannot divide by zero")
    ctl not-found() println("Option not found")
    ctl less-than-zero-sqrt() println("Cannot square root numbers that are less than zero")
    ctl less-than-zero-fact() println("Cannot apply the factorial function to 0")
  /* math-factory-one:
    0 for factorial - (int)
    1 for sqrt - (float64)

    math-factory-two:
    0 for division - (float64, float64)
    1 for multiply - (float64, float64)
    */

  var d := math-factory-two(0)
  println(d(12.0, 0.0))
  println(d(12.0, 2.0))
}