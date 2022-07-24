effect math {
  ctl div-by-zero(): ()
  ctl less-than-zero-sqrt(): ()
  ctl less-than-zero-fact(): ()
}

type math-ops
  FactOp
  SqrtOp
  DivOp
  MultOp


fun divide(x: float64, y: float64) : <math> float64
  if y == 0.0 then div-by-zero()
  x / y

fun sqrt(x: float64) : <math> float64
  if x < 0.0 then less-than-zero-sqrt()
  return (x ^ 0.5)

fun factorial(x: float64): <math, div> float64
  if x < 0.0 then less-than-zero-fact()
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

fun print-vals-one(action: (x : float64) -> <div,math|_e> float64, a: float64) {
  val res : maybe<float64> = with handler {
    ctl div-by-zero() {
      println("Cannot divide by zero")
      Nothing
    }

    ctl less-than-zero-sqrt() {
      println("Cannot square root numbers that are less than zero")
      Nothing
    }

    ctl less-than-zero-fact() {
      println("Cannot apply the factorial function numbers less than 0")
      Nothing
    }
  } in {
    Just(action(a))
  }

  match res {
    Just(x) -> println(x)
    Nothing -> print("")
  }
}


fun print-vals-two(action: (x : float64, y: float64) -> <div,math|_e> float64, a: float64, b: float64) {
  val res : maybe<float64> = with handler {
    ctl div-by-zero() {
      println("Cannot divide by zero")
      Nothing
    }

    ctl less-than-zero-sqrt() {
      println("Cannot square root numbers that are less than zero")
      Nothing
    }

    ctl less-than-zero-fact() {
      println("Cannot apply the factorial function numbers less than 0")
      Nothing
    }
  } in {
    Just(action(a, b))
  }

  match res {
    Just(x) -> println(x)
    Nothing -> print("")
  }
}

fun main() {
  with handler {
    ctl div-by-zero() {
      println("Cannot divide by zero")
    }

    ctl less-than-zero-sqrt() {
      println("Cannot square root numbers that are less than zero")
    }

    ctl less-than-zero-fact() {
      println("Cannot apply the factorial function numbers less than 0")
    }
  }
  /* math-factory-one(FactOp)
    math-factory-one(SqrtOp)
    math-factory-two(DivOp)
    math-factory-two(MultOp) */
  var s := math-factory-one(SqrtOp)
  print-vals-one(s, -1.0)
  print-vals-one(s, 4.0)

  var f := math-factory-one(FactOp)
  print-vals-one(f, -1.0)
  print-vals-one(f, 4.0)

  var d := math-factory-two(DivOp)
  print-vals-two(d, 4.2, 0.0)
  print-vals-two(d, 0.0, 4.0)

  var m := math-factory-two(MultOp)
  print-vals-two(m, 4.0, 8.0)
}