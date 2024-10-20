test {
  inspect!(
    @lib.parse?("abcd").unwrap(),
    content="Seq(Seq(Seq(Seq(Empty, Char('a')), Char('b')), Char('c')), Char('d'))",
  )
  inspect!(
    @lib.parse?(["star", "a"]).unwrap(),
    content="Star(Seq(Empty, Char('a')))",
  )

  //a+b+
  inspect!(
    @lib.parse?(["seq", ["plus", "a"], ["plus", "b"]]),
    content="Ok(Seq(Plus(Seq(Empty, Char('a'))), Plus(Seq(Empty, Char('b')))))",
  )
}
