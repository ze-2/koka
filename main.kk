// https://koka-lang.github.io/koka/doc/book.html
// To compile: koka -O2 -o out.file in.file

// Everything has to be inside a function - just println() on a new line doesn't work

// fun keyword defines a function
// Implicit braces but I still write braces b/c it's easier to read
fun main() {
  // Self explanatory
  println("Hello, World!")

  // Declare mutable values
  // Mutable local variables cannot exceed its lexical scope
  var s := "hello"
  s := "hello1"

  // References
  val ref0 = ref(0) // Creates a reference to 0 in the heap
  println(!ref(0)) // Deferenced using !

  // Decalre immutable values
  val x = "bye"

  // println(count(encode(s, 3)))
  s.encode(3).count.println

  // Structs (just ctrl+f to jump)
  val brian = Person( 29, "Brian" )
  println(brian.age)
}

// Function variables - name:type
fun encode(s:string, shift:int) {

  // Local function - can only be accessed inside parent function
  fun encode-char(c) {
    // If statement?
    if (c < 'a' || c > 'z') then return c
    // Declaring a variable - use val
    // x.int = int(x) - converts to integer - dot notation
    val base = (c - 'a').int
    val rot  = (base + shift) % 26
    (rot.char + 'a')
  }
  /* map - applies the function to the variable
  In this case it applies encode-char to every character in s */
  // Final statement is the return value - but can use return keyword
  s.map(encode-char)
}

// Anonymous functions - fn
fun encode_anon(s: string, shift: int) {
  s.map(
    fn(c) {
      if c < 'a' || c > 'z' then return c
      val base = (c - 'a').int
      val rot  = (base + shift) % 26
      (rot.char + 'a')
    }
  )
}

fun caesar(s:string)
  // Equivalent to encode(s, 3) - dot notation
  s.encode(3)

fun print10() {
  // Same as for(1, 10, fn(i){ println(i) } )
  // Same as for(1, 10, println)
  for(1, 10) fn(i)
    println(i)
}

// Anon functions w/o functions can be shortened even further - leave out fn
fun print10hi() {
  // same as repeat( 10, fn(){println(hi)} )
  repeat(10) {
    println("hi")
  }
}

fun print11() {
  var i := 10
  // An expression within (parenthesis) is always evaluated before a function call
  // An expression between {braces} is suspended and may be never evaluated or more than once
  while { i >= 0 } {
    println(i)
    i := i - 1
  }
}

// with keyword - puts all statements that follow it into an anynomous function block and passes that as the last parameter
fun twice(f)
  f()
  f()

fun test-twice() {
  with twice
  with twice
  println("test")
}

pub fun test-with2() {
  // same as list(1, 10).foreach( fn(x){ println(x) } )
  with x <- list(1,10).foreach
  println(x)
}

// finally - takes as its first argument a function that is run when exiting the scope
fun test-finally()
  // finally(fn(){ println...}, fn(){ println("entering"); throw("oops") + 42 })
  with finally{ println("exiting..") }
  println("entering..")
  throw("oops") + 42

// Optional and named params
fun world() {
  // replace-all(string, pattern=pattern, repl=replacement_string)
  replace-all("hi there", "there", "world")
}

fun world2() {
  // Same as world(), but using named params
  "hi there".replace-all( repl="world", pattern="there" )
}

// TODO: what is this?
// Optional len param - by default return all elements following start position by picking the length of the input list at default
fun sublist( xs : list<a>, start : int, len : int = xs.length ) : list<a>
  if start <= 0 return xs.take(len)
  match xs
    Nil        -> Nil
    Cons(_,xx) -> xx.sublist(start - 1, len)


/* Koka automatically infers all the side effects that occur in a function. The absence of any effect is denoted as total (or <>) and corresponds to pure mathematical functions. If a function can raise an exception the effect is exn, and if a function may not terminate the effect is div (for divergence). The combination of exn and div is pure. Non- deterministic functions get the ndet effect. The ‘worst’ effect is io and means that a program can raise exceptions, not terminate, be non- deterministic, read and write to the heap, and do any input/output operations. A function can contain multiple effects. */
fun square1(x: int) : total int   { x*x }
fun square2(x: int) : console int { println( "a not so secret side-effect" ); x*x }
fun square3(x: int) : div int     { x * square3( x ) }
fun square4(x: int) : exn int     { throw( "oops" ); x*x }
// When the effect is total we leave it out
fun square5(x: int) : int         {x * x} /* the : int thing after the function is type annotation */
// Wildcard type - some inferred type
fun square6( x : int ) : _e int {
  println("I did not want to write down the \"console\" effect")
  x*x
}

// Data types

/* Structs are immutable
Same as:
type person
  Person{ age : int; name : string; realname : string = name } */
struct person
  age : int
  name : string
  realname : string = name

// Instead of mutating a field in a struct, we usually return a new struct where the fields are updated eg.
// Returns a fresh person but with age incremented
fun birthday( p : person ) : person
  // p(...) is syntatic sugar for calling the copy constructor of a person (auto-gen for each type)
  p(age = p.age + 1)

// Enum
type color
  Red
  Green
  Blue

// Constructors can have params - in this case, either infinity or the integer value that's passed in
type number
  Infinity
  Integer( i : int )
// Can create such a number by writing Integer(1) or Infinity

// Value types are (non-recursive) data types that are not heap allocated but passed on the stack as a value
// Any non-recursive inductive data type of a size up to 3 machine words (= 24 bytes on a 64-bit platform) is treated as a value type
// Can also force a type to be compiled as a value type by using the value keyword in front of a type or struct declaration:
value struct argb{ alpha: int; color-red: int; color-green: int; color-blue: int }

/*
An effect describes an abstract set of operations whose concrete implementation can be supplied by a handler
The effect declaration defines a new type together with operations */

// This defines an effect type raise together with an operation raise of type (msg : string) -> raise a
effect raise
  ctl raise( msg : string ) : a


// The with statement is really useful in combination with effect handlers.

effect fun emit(msg : string) : ()

fun hello() {
  emit("hello world!")
}

// pub = public - everything is private by default
pub fun hello-console1() {
  with handler {
    fun emit(msg) println(msg)
  }
  hello()
}

pub fun hello-console2() {
  // Can leave out handler keyword for effects that define just one operation
  with fun emit(msg) println(msg)
  hello()
}