import PathKit
@testable import Plugin

class IntervalHost: Manageable {
  var plugin: IntervalPlugin!
  var events = [Event]()

  enum Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
      switch (lhs, rhs) {
      case let (.stdout(a), stdout(b)):
        return a == b
      case let (.stderr(a), stderr(b)):
        return a == b
      default:
        return false
      }
    }

    case stdout(String)
    case stderr(String)
  }

  public init(path: Path = .interval, frequency: Int = 10, args: [String] = [], env: Env = Env()) {
    plugin = Interval(path: path, frequency: frequency, args: args, env: env, delegate: self)
  }

  func plugin(didReceiveOutput: String) {
    events.append(.stdout(didReceiveOutput))
  }

  func plugin(didReceiveError: String) {
    events.append(.stderr(didReceiveError))
  }

  func stop() {
    plugin.stop()
  }

  func start() {
    plugin.start()
  }

  func invoke(_ args: [String]) {
    plugin.invoke(args)
  }

  func restart() {
    plugin.restart()
  }

  func deallocate() {
    plugin = nil
  }
}
