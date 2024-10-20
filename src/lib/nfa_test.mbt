test (it : @test.T) {
  @lib.reset_id()
  let s1 = @lib.State::new(name="S1")
  let s2 = @lib.State::new(name="S2")
  let s3 = @lib.State::new(name="S3")
  s1.connect_to(s2, edge='a')
  s2.connect_to(s3, edge='b')
  s1.connect_to(s3)
  let nfa = @lib.NFA::new(start=s1, states=[s1, s2, s3], final=s3)
  it.writeln(nfa.to_mermaid())
  it.writeln("initial closure:")
  let closure = @lib.closure_of_set(@immut/sorted_set.singleton(s1))
  it.writeln(closure)
  it.writeln("edges of initial closure:")
  let edges = @lib.edges_of_closure(closure)
  it.writeln(edges)
  it.writeln("step of closure with 'a':")
  let next_closure = @lib.step_of_closure(closure, 'a')
  it.writeln(next_closure)
  let edges = @lib.edges_of_closure(next_closure)
  it.writeln("new edges")
  it.writeln(edges)
  // it.writeln(edges)
  let dfa = nfa.to_dfa()
  // it.writeln("")
  it.writeln(dfa.to_mermaid())
  it.snapshot!(filename="nfa.md")
  // @json.inspect!(@lib.closure(s1))
}

test (it : @test.T) {
  @lib.reset_id()
  let a : Json = ["or", "ab", "cd"]
  let regex = @lib.parse!(a)
  let nfa = @lib.regex_to_nfa(regex)
  it.write(nfa.to_mermaid())
  it.snapshot!(filename="nfa_or.md")
}

test (it : @test.T) {
  @lib.reset_id()
  let a : Json = ["seq", "ab", ["star", "cd"]]
  let regex = @lib.parse!(a)
  let nfa = @lib.regex_to_nfa(regex)
  it.write(nfa.to_mermaid())
  it.snapshot!(filename="nfa_seq.md")
}

test {
  @lib.reset_id()
  let s1 = @lib.State::new(name="S1")
  let s2 = @lib.State::new(name="S2")
  let s3 = @lib.State::new(name="S3")
  s1.connect_to(s2)
  s2.connect_to(s3, edge='b')
  @json.inspect!(
    s2.closure(),
    content=[{ "id": { "id": 2, "description": "S2" }, "transitions": 1 }],
  )
  @json.inspect!(
    s1.closure(),
    content=[
      { "id": { "id": 1, "description": "S1" }, "transitions": 1 },
      { "id": { "id": 2, "description": "S2" }, "transitions": 1 },
    ],
  )
}

test {
  @lib.reset_id()
  let a = @lib.State::new(name="A")
  let b = @lib.State::new(name="B")
  let c = @lib.State::new(name="C")
  let d = @lib.State::new(name="D")
  let e = @lib.State::new(name="E")
  let _f = @lib.State::new(name="F")
  a.connect_to(b)
  b.connect_to(c)
  c.connect_to(d)
  d.connect_to(e)
  @json.inspect!(
    a.closure(),
    content=[
      { "id": { "id": 1, "description": "A" }, "transitions": 1 },
      { "id": { "id": 2, "description": "B" }, "transitions": 1 },
      { "id": { "id": 3, "description": "C" }, "transitions": 1 },
      { "id": { "id": 4, "description": "D" }, "transitions": 1 },
      { "id": { "id": 5, "description": "E" }, "transitions": 0 },
    ],
  )
  @json.inspect!(
    b.closure(),
    content=[
      { "id": { "id": 2, "description": "B" }, "transitions": 1 },
      { "id": { "id": 3, "description": "C" }, "transitions": 1 },
      { "id": { "id": 4, "description": "D" }, "transitions": 1 },
      { "id": { "id": 5, "description": "E" }, "transitions": 0 },
    ],
  )
}
