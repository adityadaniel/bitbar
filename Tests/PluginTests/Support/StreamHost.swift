import PathKit
@testable import Plugin

class SteamHost: Manageable {
  var plugin: StreamPlugin!
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

  public init(path: Path = .stream, args: [String] = [], env: Env = Env()) {
    plugin = Stream(path: path, args: args, env: env, delegate: self)
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
