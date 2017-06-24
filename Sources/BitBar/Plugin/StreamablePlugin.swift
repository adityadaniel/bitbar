import Files
import Script
import SwiftyBeaver

class StreamablePlugin: Plugin, Scriptable {
  internal let queue = StreamablePlugin.newQueue(label: "StreamablePlugin")
  internal let log = SwiftyBeaver.self
  private let scriptName: String
  private var script: Script
  internal let file: Files.File
  internal weak var manager: Managable?
  internal weak var root: Parent?

  public var description: String {
    return "Streamable(name: \(scriptName), file: \(file.name))"
  }

  init(name: String, file: Files.File, manager: Managable) {
    self.scriptName = name
    self.manager = manager
    self.file = file
    self.script = Script(path: file.path)
    self.root = manager
    self.script.delegate = self
    self.script.start()
  }

  func invoke(_ args: [String]) {
    script = Script(path: path, args: args, delegate: self, autostart: true)
  }

  /**
    Run @path once every @interval seconds
  */
  func start() {
    script.start()
  }

  /**
    Stop timer and script
  */
  func stop() {
    script.stop()
  }

  /**
    Restart the script
  */
  func refresh() {
    script.restart()
  }

  /**
    In this case, terminate() and hide() do the same thing
  */
  func terminate() {
    script.stop()
  }

  /**
    Succeeded running @path
    Sending data to parent plugin class
  */
  func scriptDidReceive(success result: Script.Success) {
    switch (result, script.isRunning) {
    case let (.withZeroExitCode(.some(stdout)), true):
      manager?.plugin(didReceiveOutput: stdout)
    case (.withZeroExitCode(.none), true):
      log.info("No output provided")
    case (.withZeroExitCode, false):
      manager?.plugin(didReceiveError: "Streaming script is no longer running")
    }
  }

  /**
    Failed running @path
    Sending error to parent plugin class
  */
  func scriptDidReceive(failure: Script.Failure) {
    switch failure {
    case .manualTermination:
      manager?.plugin(didReceiveError: "Streaming script is no longer running")
    default:
      manager?.plugin(didReceiveError: String(describing: failure))
    }
  }

  func scriptDidReceive(piece: Script.Piece) {
    switch piece {
    case let .succeeded(stdout):
      manager?.plugin(didReceiveOutput: stdout)
    case let .failed(stderr):
      log.error("Received a piece of failure: \(stderr.inspected)")
    }
  }

  var type: String { return "Streamable" }
  var meta: [String: String] {
    return [:]
  }
}
