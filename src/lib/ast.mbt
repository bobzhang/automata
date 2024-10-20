pub enum Regex {
  Seq(Regex, Regex)
  Alt(Regex, Regex)
  Star(Regex) // e*
  Plus(Regex) // e+
  Opt(Regex) // e?
  Char(Char)
  Empty // matches empty string
} derive(Show, ToJson)

pub fn regex_to_nfa(regex : Regex) -> NFA {
  match regex {
    Seq(r1, r2) => {
      let nfa1 = regex_to_nfa(r1)
      let nfa2 = regex_to_nfa(r2)
      nfa1.final.connect_to(nfa2.start)
      NFA::new(
        start=nfa1.start,
        states=[..nfa1.states, ..nfa2.states],
        final=nfa2.final,
      )
    }
    Alt(r1, r2) => {
      let nfa1 = regex_to_nfa(r1)
      let nfa2 = regex_to_nfa(r2)
      let start = State::new()
      start.connect_to(nfa1.start)
      start.connect_to(nfa2.start)
      let final = State::new()
      nfa1.final.connect_to(final)
      nfa2.final.connect_to(final)
      NFA::new(
        ~start,
        states=[..nfa1.states, ..nfa2.states, start, final],
        ~final,
      )
    }
    Opt(r) => {
      let nfa = regex_to_nfa(r)
      nfa.start.connect_to(nfa.final)
      NFA::new(start=nfa.start, states=nfa.states, final=nfa.final)
    }
    Char(c) => {
      let start = State::new()
      let final = State::new()
      start.connect_to(final, edge=c)
      NFA::new(~start, states=[start, final], ~final)
    }
    Empty => {
      let start = State::new()
      NFA::new(~start, states=[start], final=start)
    }
    Star(r) => {
      let start = State::new()
      let nfa = regex_to_nfa(r)
      start.connect_to(nfa.start)
      nfa.final.connect_to(start)
      NFA::new(~start, states=[..nfa.states, start], final=start)
    }
    Plus(r) => regex_to_nfa(Seq(r, Star(r)))
  }
}
