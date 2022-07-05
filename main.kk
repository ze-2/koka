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
  hello-console1()
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
// Type annotations are used to indicate the datatypes of variables and input/outputs of functions and methods
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

// With the effect type declared we can use raise

// Such an effect type means that we can only evaluate the function in a context where raise is handled
fun safe-divide( x : int, y : int ) : raise int
  if y==0 then raise("div-by-zero") else x / y

// We can handle the effect by giving a concrete definition for the raise operation
fun raise-const() : int {
  with handler {
    ctl raise(msg) 42
  }
  8 + safe-divide(1,0)
}

fun raise-const1() : int {
  with ctl raise(msg) 42
  8 + safe-divide(1,0)
}

/* Calling this evaluates to 42, not 50
When a raise is called (in safe-divide), it will yield to its innermost handler, unwind the stack, and only then evaluate the operation definition – in this case just directly returning 42 from the point where the handler is defined
This is why it's a control operation - it changes the regular linear control-flow and yields (an action that occurs in a computer program during multithreading, of forcing a processor to relinquish control of the current running thread, and sending it to the end of the running queue, of the same scheduling priority) right back to its innermost handler from the original call site */

// The with statement is really useful in combination with effect handlers.
// The handler expression is a function that expects a function argument over which the handler is scoped

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

// We can also resume back to the call site using resume
// The resume function is implicitly bound by a ctl operation and resumes back to the call-site with the given result.
effect ask<a> {
  ctl ask() : a
}

// This function can ask for numbers but it is unaware of how these are provided
fun add-twice() : ask<int> int
  ask() + ask()

// We can handle this by always resuming with a constant
fun ask-const() : int
  with ctl ask() resume(21)
  add-twice() // Evaluates to 42

// Or by returning random values
// fun ask-random() : random int
//   with ctl ask() resume(random-int())
//   add-twice()
// ask-random() handles ask<int> effect itself, but now has a random effect

// we do not need to call resume and can also directly return into our handler scope (eg. only asking once)
fun ask-once() : int
  var count := 0
  with ctl ask()
    count := count + 1
    if count <= 1 then resume(42) else 0
  add-twice()
// Evaluates to 0 because the second call to ask doesn't resume and returns 0 directly

// ctl is one of the most general ways to define operations
// Almost all operations in practice turn out to be tail-resumptive: they resume exactly once with their final result value
// To make this more convenient we can declare fun operations that do this by construction eg.

// Basically fun is tail-resumptive
fun ask-const2() : int
  with fun ask() 21
  add-twice()

/* Value operations (always tail-resumptive with a single value)

// Function that pretty prints
fun pretty( d : doc ) : string

// However it has a hard-coded maximum display width of 40
fun pretty-internal( line : string ) : string
  line.truncate(40)

// To abstract over the width we can define it as a val operation
effect val width : int

// Allows us to refer to the width operation as if it were a regular value
// So the check for the width in the pretty printer can be written as
fun pretty-internal( line : string ) : width string
  line.truncate(width)

// When using the pretty printer we can bind width as a regular effect handler
fun pretty-thin(d : doc) : string
  with val width = 40
  pretty(d)

// And the type of pretty becomes
fun pretty( d : doc ) : width string */

// Abstracting
fun ehello() : emit ()
  emit("hello")
  emit("world")

// We can define a handler that prints emitted messages directly to the console
fun ehello-console() : console ()
  with fun emit(msg) println(msg)
  ehello()

// But we can also abstract the handler for emitting to the console into a separate function
fun emit-console(action)
  with fun emit(msg) println(msg)
  action()

// We can also write it as but we prefer the first (params)
val emit-console2 = handler
  fun emit(msg) println(msg)

// Now ehello-console() can be written as
fun ehello-console2() : console ()
  with emit-console
  ehello()

// Emit collector
fun emit-collect( action : () -> <emit|e> () ) : e string
  var lines := []
  with handler
    return(x)     lines.reverse.join("\n")
    fun emit(msg) lines := Cons(msg,lines)
  action()

// Return changes the final result of the action of a handler
fun raise-maybe( action : () -> <raise|e> a ) : e maybe<a>
  with handler
    return(x)      Just(x)   // normal return: wrap in Just
    ctl raise(msg) Nothing   // exception: return Nothing directly
  action()

fun div42()
  (raise-maybe{ safe-divide(1,0) }).default(42)

fun ehello-commit() : string
  with emit-collect
  ehello()

// Generic catch
fun catch( hnd : (string) -> e a, action : () -> <raise|e> a ) : e a
  with ctl raise(msg) hnd(msg)
  action()

fun catch-example()
  with catch( fn(msg){ println("error: " ++ msg); 42 } )
  safe-divide(1,0)

// State effect
effect state<a>
  fun get() : a
  fun set( x : a ) : ()

fun sumdown( sum : int = 0 ) : <state<int>,div> int
  val i = get()
  if i <= 0 then sum else
    set( i - 1 )
    sumdown( sum + i )

// Return generic state
fun state( init : a, action : () -> <state<a>,div|e> b ) : <div|e> b
  var st := init
  with handler
    fun get()  st
    fun set(i) st := i
  action()

// Return final state
fun pstate( init : a, action : () -> <state<a>,div|e> b ) : <div|e> (b,a)
  var st := init
  with handler
    return(x)  (x,st)       // pair with the final state
    fun get()  st
    fun set(i) st := i
  action()

// Combining handlers

// Calls raise if there's an odd number
fun no-odds() : <raise,state<int>> int
  val i = get()
  if i.is-odd then raise("no odds") else
    set(i / 2)
    i

// To handle the effects
fun state-raise(init) : div (maybe<int>,int)
  with pstate(init)
  with raise-maybe
  no-odds()

// However if they're in the opposite order you get a form of transactional state where we either get an exception (and no final state), or we get a pair of the result with the final state
fun raise-state2(init) : div maybe<(int,int)>
  with raise-maybe
  with pstate(init)
  no-odds()

// We can mask effects not be handled by their innermost effect handler
fun mask-emit()
  with fun emit(msg) println("outer:" ++ msg)
  with fun emit(msg) println("inner:" ++ msg)
  emit("hi")
  mask<emit>
    emit("there")
/* mask-emit() prints:
inner: hi
outer: there
The second call to emit is masked - therefore it skips the innermost handler and is handled subsequently by the outer handler
*/
/*
// Overriding handlers

// This func is bad b/c it exposes that action is evaluated under at least 2 emit handlers
fun emit-quoted1( action : () -> <emit,emit|e> a ) : <emit|e> a
  with fun emit(msg) emit("\"" ++ msg ++ "\"")
  action()

// override keeps the type nice
fun emit-quoted2( action : () -> <emit|e> a ) : <emit|e> a
  with override fun emit(msg) emit("\"" ++ msg ++ "\"" )
  action()

// // Resuming more than once - can be used to implement backtracking or probalistic programming models
// effect ctl choice() : bool V

// fun xor() : choice bool
//   val p = choice()
//   val q = choice()
//   if p then !q else q

// // We can resume multiple times, once with False and once with True to return all outcomes TODO
// // Changes handler type to list<a> - need a return clause to wrap action in a single list
// fun choice-all(action : () -> <choice|e> a) : e list<a>
//   with handler
//     return(x)    [x]
//     ctl choice() resume(False) ++ resume(True)
//   action()

// This uses both choice and state
fun surprising() : <choice,state<int>> bool
  val p = choice()
  val i = get()
  set(i+1)
  if i>0 && p then xor() else False

fun state-choice() : div (list<bool>,int)
  pstate(0)
    choice-all(surprising)

fun choice-state() : div list<(bool,int)>
  choice-all
    pstate(0,surprising)

// finally and initially


// file operations
type fhandle
fun fopen( path : string )   : <exn,filesys> fhandle
fun hreadline( h : fhandle ) : <exn,filesys> string
fun hclose( h : fhandle )    : <exn,filesys> ()

// to read from a file
effect fun fread() : string

fun with-file( path : string, action : () -> <fread,exn,filesys|e> a ) : <exn,filesys|e> a
  val h = fopen(path)
  with handler
    return(x)   { hclose(h); x }
    fun fread() hreadline(h)
  action()
// However it will fail to close the file handle if an exceptional effect inside action() is used

// finally function handles these situations, and takes as its first argument a function that is always executed when either returning normally, or when unwinding for a non-resuming operation
fun with-file( path : string, action : () -> <fread,exn,filesys|e> a ) : <exn,filesys|e> a
  val h = fopen(path)
  with finally
    hclose(h)
  with fun fread()
    hreadline(h)
  action()

// Another way to work with multiple resumptions is to use the initially function. This function takes 2 arguments: the first argument is a function that is called the first time initially is evaluated, and subsequently every time a particular resumption is resumed more than once.
*/
// Commented b/c my brain is kinda fried and it keeps bringing up errors, will deal with after a rest