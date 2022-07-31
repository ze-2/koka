effect yield
  ctl yield(x: int) : bool

type my-list<a>
  MyNil
  MyCons(head: a, tail: my-list<a>)

fun show-list(lst: my-list<a>, show-elem: a -> string): string
  match lst {
    MyNil -> "MyNil"
    MyCons(head, tail) -> "MyCons(" ++ head.show-elem ++ ", " ++ tail.show-list(show-elem) ++ ")"
  }

fun show(lst: my-list<int>): string
  lst.show-list(show)

fun get-elem(lst: my-list<a>, x: int): maybe<a>
  // go through elements and minus 1 until x == 0 which is where the element you want to access will be, then return that element
  match lst
    MyCons(head, tail) -> {
      if x > 0 then tail.get-elem(x - 1)
      elif x == 0 then Just(head)
      else Nothing
    }
    MyNil -> Nothing

fun push(ll: my-list<a>, x: a): my-list<a>
  MyCons(x, ll)

fun iterate(lst: my-list<int>) : <exn,yield> ()
  match lst
    MyCons(head, tail) -> {
      yield(head)
      // Until we reach MyNil
      iterate(tail)
    }
    MyNil -> ()

fun print-vals(lst: my-list<int>): <console, exn> ()
  with ctl yield(i) {
    println(i)
    resume(True)
  }
  iterate(lst)

fun main() {
  var s := MyCons(3, MyNil)
  s := s.push(4)
  s := s.push(5)
  match s.get-elem(2)
    Just(x) -> println(x)
    Nothing -> println("Nothing")

  print-vals(s)
}