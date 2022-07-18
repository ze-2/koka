// Koka doesn't support mutable structs, so this implementation won't work for now
struct node {
  data: int
  next_node: maybe<node>
}

struct linked-list {
  head: maybe<node>
}

fun push(ll: linked-list, x: int) {
  match ll.head
    Nothing -> {
      var new := Node(x, ll.head)
      ll := ll(head = Just(new))
      match ll.head
        Nothing -> println("Error")
        Just(_z) -> println("Success")
    }
    Just(y) -> {
      var new := Node(x, y.next_node)
      y(next_node = new.next_node)
      println("Inserted a value")
    }
}


fun main() {
  var s := Linked-list(Nothing)
  s.push(3)
  s.push(4)
}