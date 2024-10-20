struct Id {
  id : Int
  description : String?
} derive(Eq, Compare, Default, ToJson)

pub enum Edge {
  Epsilon
  Char(Char)
} derive(Default, ToJson)

impl Show for Edge with output(self, logger) {
  match self {
    Edge::Epsilon => logger.write_string("ε")
    Edge::Char(c) => logger.write_object(c)
  }
}

pub fn to_string(self : Edge) -> String {
  Show::to_string(self)
}

impl Show for Id with output(self, logger) {
  logger.write_object(self.id)
  match self.description {
    Some(desc) => logger.write_string(": " + desc)
    None => ()
  }
}

pub fn to_string(self : Id) -> String {
  Show::to_string(self)
}

let id : Ref[Int] = { val: 0 }

pub fn reset_id() -> Unit {
  id.val = 0
}

fn gen_id(~name? : String) -> Id {
  id.val += 1
  { id: id.val, description: name }
}

pub struct State {
  id : Id
  transitions : Array[(Edge, State)]
}

pub impl Show for State with output(self, logger) {
  logger.write_object(self.id)
}

pub impl ToJson for State with to_json(self) {
  {
    "id": self.id.to_json(),
    "transitions": self.transitions.length().to_json(),
  }
}

impl Hash for State with hash_combine(self, hasher) {
  hasher.combine(self.id.id)
}

// TODO: in general, impl woud be pub??
pub impl Eq for State with op_equal(self, other) { self.id == other.id }

pub impl Compare for State with compare(self, other) { self.id.compare(other.id) }

fn compare(self : State, other : State) -> Int {
  Compare::compare(self, other)
}

fn op_equal(self : State, other : State) -> Bool {
  Eq::op_equal(self, other)
}

pub fn closure(self : State) -> Set[State] {
  let result = Set::of([self])
  for curr_states = Set::of([self]) {
    let fresh_added = Set::new()
    for st in curr_states {
      for trans in st.transitions {
        match trans.0 {
          Epsilon =>
            if result.contains(trans.1).not() {
              fresh_added.insert(trans.1)
              result.insert(trans.1)
            }
          Char(_) => ()
        }
      }
    }
    if fresh_added.is_empty() {
      break
    } else {
      continue fresh_added
    }
  }
  result
}

//TODO how to  // { "path": "immut/sorted_set", "alias": "immset"}     
pub fn closure_of_set(
  states : @immut/sorted_set.T[State]
) -> @immut/sorted_set.T[State] {
  let mut result = states
  for curr_states = states {
    let mut fresh_added = @immut/sorted_set.new()
    for st in curr_states {
      for trans in st.transitions {
        match trans.0 {
          Epsilon =>
            if result.contains(trans.1).not() {
              fresh_added = fresh_added.add(trans.1)
              result = result.add(trans.1)
              // result.insert(trans.1)
            }
          Char(_) => ()
        }
      }
    }
    if fresh_added.is_empty() {
      break
    } else {
      continue fresh_added
    }
  }
  result
}

/// edges of closure modulo epsilon
pub fn edges_of_closure(
  states : @immut/sorted_set.T[State]
) -> @immut/sorted_set.T[Char] {
  let mut edges = @immut/sorted_set.new()
  for state in states {
    for trans in state.transitions {
      match trans.0 {
        Epsilon => ()
        Char(c) => edges = edges.add(c)
      }
    }
  }
  edges
}

pub fn step_of_closure(
  states : @immut/sorted_set.T[State],
  edge : Char
) -> @immut/sorted_set.T[State] {
  let mut result = @immut/sorted_set.new()
  for state in states {
    for trans in state.transitions {
      match trans.0 {
        Epsilon => ()
        Char(c) => if c == edge {
          result = result.add(trans.1)
        }
      }
    }
  }
  closure_of_set(result)
}


pub struct NFA {
  start : State
  states : Array[State]
  final : State
}

pub fn NFA::new(~start : State, ~states : Array[State], ~final : State) -> NFA {
  NFA::{ start, states, final }
}

pub fn State::new(~name? : String) -> State {
  let id = gen_id(~name?)
  State::{ id, transitions: [] }
}

pub fn connect_to(self : State, other : State, ~edge? : Char) -> Unit {
  let edge = match edge {
    Some(c) => Edge::Char(c)
    None => Edge::Epsilon
  }
  self.transitions.push((edge, other))
}

pub fn to_mermaid(self : NFA) -> String {
  let sb = StringBuilder::new()
  let indent = "  "
  for state in self.states {
    if state.id.description != None {
      sb.write_string(indent)
      sb.write_object(state.id)
      sb.write_string("\n")
    }
    // sb.write_string(indent)
    // sb.write_object(state.id)
    // sb.write_string("\n")
  }
  for state in self.states {
    for trans in state.transitions {
      sb.write_string(indent)
      sb.write_object(state.id.id) // only id needed
      sb.write_string(" --> ")
      sb.write_object(trans.1.id.id)
      sb.write_string(" : ")
      sb.write_object(trans.0)
      sb.write_string("\n")
    }
  }
  // TODO allow " in $|
  let content = sb.to_string().trim_end("\n")
  #|```mermaid
  #|  stateDiagram-v2
  $|\{content}
  #|```
}
