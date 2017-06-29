protocol Managable {
  func plugin(didReceiveOutput: String)
  func plugin(didReceiveError: String)
}
