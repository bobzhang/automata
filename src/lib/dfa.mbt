type DFAId Int derive(Show)

let dfa_id : Ref[Int] = Ref::new(0)

pub fn reset_dfa_id() -> Unit {
  dfa_id.val = 0
}
// TODO: when method is private,it reports an error not found
// could it be reported as a hint
pub fn DFAState::new(~final : Bool = false) -> DFAState {
  dfa_id.val += 1
  { id: dfa_id.val, trainsitions: Map::new(), final }
}

pub struct DFAState {
  id : DFAId
  trainsitions : Map[Char, DFAState]
  final : Bool
}

pub fn connect_to(self : DFAState, state : DFAState, ~edge : Char) -> Unit {
  self.trainsitions[edge] = state
}

pub fn to_mermaid(self : DFAState) -> String {
  let sb = StringBuilder::new()
  loop @immut/list.Cons(self, Nil) {
    Nil => ()
    Cons(current, rest) => {
      let mut rest = rest   
      for trans in current.trainsitions {
        let (edge, state) = trans
        sb.write_string("  \{current.id._} --> \{state.id._} : \{edge} \n")
        rest = Cons(state, rest)
      }      
      continue rest
    }
  }
  #|```mermaid
  #|  stateDiagram-v2
  $|\{sb.to_string()}
  #|```
}

// struct DFA {
//   start : DFAState
//   states : Array[DFAState]
// }

// pub fn dfs_nfa ()
pub fn to_dfa(self : NFA) -> DFAState {
  let start_nfa = closure_of_set(@immut/sorted_set.singleton(self.start))
  let start_dfa = DFAState::new(final=start_nfa.contains(self.final))
  let initial_work = @immut/list.Cons((start_nfa, start_dfa), Nil)
  loop initial_work {
    Nil => ()
    Cons(current, rest) => {
      let edges = edges_of_closure(current.0)
      let mut rest = rest
      for e in edges {
        let next_nfa = step_of_closure(current.0, e)
        let next_dfa = DFAState::new(final=next_nfa.contains(self.final))
        current.1.trainsitions[e] = next_dfa
        rest = Cons((next_nfa, next_dfa), rest)
      }
      continue rest
    }
  }
  start_dfa
}
