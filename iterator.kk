effect yield<a>
  ctl yield(x: a) : ()

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
  match lst
    MyCons(head, tail) -> {
      if x > 0 then tail.get-elem(x - 1)
      elif x == 0 then Just(head)
      else Nothing
    }
    MyNil -> Nothing

fun push(ll: my-list<a>, x: a): my-list<a>
  MyCons(x, ll)

fun iterate(lst: my-list<a>): yield<a> ()
  match lst {
    MyNil -> ()
    MyCons(head, tail) ->
      yield(head)
      tail.iterate
  }

fun print-vals(lst: my-list<int>): <console, exn> ()
  with ctl yield(i) {
    println(i: int)
    resume(())
  }
  iterate(lst)

fun foreach(f: a -> e (), iter: () -> yield<a> ()): e ()
  with ctl yield(x) {
    f(x)
    resume(())
  }
  iter()

fun my-filter(pred: int -> bool, iter: () -> yield<int> ()): yield<int> ()
  with override ctl yield(x) {
    if pred(x) then yield(x)
    resume(())
  }
  iter()

fun filter-ints(lst: my-list<int>) {
  with foreach(fn(x: int) println(x))
  with my-filter(fn(x) x > 2)
  lst.iterate
}

fun main() {
  var s := MyCons(1, MyCons(2, MyCons(3, MyNil)))
  filter-ints(s)
}
