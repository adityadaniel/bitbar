enum NoMatch: Error {
  case stop([Int])
  case message(String)
}
