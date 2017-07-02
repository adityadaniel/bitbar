public protocol Pluginable: class {
  weak var delegate: Manageable? { get set }
  func restart()
  func start()
  func stop()
  func invoke(_: [String])
}
