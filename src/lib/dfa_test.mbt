test ( it : @test.T) {
  let a = @lib.DFAState::new()
  let b = @lib.DFAState::new()
  let c = @lib.DFAState::new()

  a.connect_to(b,edge='c')  
  b.connect_to(c,edge='d')
  it.write(a.to_mermaid())
  it.snapshot!(filename="dfa_test.md")
}