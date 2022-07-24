effect math {
  ctl div-by-zero(): a
  ctl less-than-zero-sqrt(): a
  ctl less-than-zero-fact(): a
}

fun divide(x: float64, y: float64 ) : <math|_e> float64
  if y == 0.0 then div-by-zero() else x / y

fun sqrt(x: float64) : <math|_e> float64
  if x < 0.0 then
    less-than-zero-sqrt()
  else
    return (x ^ 0.5)

fun sqrt(x: int) : <math|_e> float64
  if x < 0 then
    less-than-zero-sqrt()
  else
    return (float64(x) ^ 0.5)

// fun factorial(x: int): <math|_e> int
//   if x < 0 then less-than-zero-fact()
//   if x < 2
//     then 1
//   else
//     return x * factorial(x - 1)

// fun gcd(x: int, y: int): <math|_e> int
//   if x == 0 then return x
//   if y == 0 then return y
//   if x == y then return x
//   if x > y then return gcd(x - y, y)
//   return gcd(x, y - x)


fun factorial(x: float64): _e float64
  if x < 0.0 then less-than-zero-fact()
  if x < 2.0
    then 1.0
  else
    return x * factorial(x - 1.0)

fun multiply(x: float64, y: float64) : float64
  x * y

// Find a way to resolve 'return type does not match an earlier return type' bug and 'function returns values of different types'
fun math-factory(s : string) : <div, math|_e> float64
  if s == "1" then return divide(1.1, 0.0)
  if s == "2" then return sqrt(-4)
  if s == "3" then return factorial(-1.0)
  if s == "4" then return multiply(12.0, 18.0)

fun main() {
  with handler
    ctl div-by-zero() println("div-by-zero")
    ctl less-than-zero-sqrt() println("can't square root numbers less than zero")
    ctl less-than-zero-fact() println("can't find the factorial of numbers less than zero")

  /* 1 for division
  2 for sqrt
  3 for factorial
  4 for gcd */
  math-factory("1")
}