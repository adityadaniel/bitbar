protocol Pluginable: class {
  weak var delegate: Manageable? { get set }
  func refresh()
  func start()
  func stop()
  func invoke(_: [String])
}
