public protocol Manageable: class {
  func plugin(didReceiveOutput: String)
  func plugin(didReceiveError: String)
}
