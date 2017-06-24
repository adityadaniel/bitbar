import SwiftTimer
import SwiftyBeaver
import DateToolsSwift
import Script
import Files

class ExecutablePlugin: Plugin, Scriptable, GUI {
  internal let queue = ExecutablePlugin.newQueue(label: "ExecutablePlugin")
  internal let log = SwiftyBeaver.self
  private let scriptName: String
  private var script: Script
  internal let file: Files.File
  private var timer: SwiftTimer?
  private var interval: Int
  internal weak var manager: Managable?
  internal weak var root: Parent?

  public var description: String {
    return "Exectable(name: \(scriptName), file: \(file.path), interval: \(interval))"
  }

  init(name: String, interval: Double, file: Files.File, manager: Managable) {
    self.scriptName = name
    self.interval = Int(interval)
    self.manager = manager
    self.file = file
    self.script = Script(path: file.path)
    self.root = manager
    self.newTimer()
    self.script.delegate = self

    perform { [weak self] in
      self?.script.start()
    }
  }

  /**
    Run @path once every @interval seconds
  */
  func start() {
    perform { [weak self] in
      self?.script.start()
      self?.timer?.start()
    }
  }

  /**
    Stop timer and script
  */
  func stop() {
    perform { [weak self] in
      self?.timer?.invalidate()
      self?.script.stop()
    }
  }

  /**
    Restart the script
  */
  func refresh() {
    perform { [weak self] in
      self?.newTimer()
      self?.script.restart()
    }
  }

  /**
    In this case, terminate() and hide() do the same thing
  */
  func terminate() {
    stop()
  }

  /**
    Succeeded running @path
    Sending data to parent plugin class
  */
  func scriptDidReceive(success result: Script.Success) {
    switch result {
    case let .withZeroExitCode(.some(stdout)):
      perform { [weak self] in
        self?.manager?.plugin(didReceiveOutput: stdout)
      }
    case .withZeroExitCode(.none):
      log.info("No output provided")
    }
  }

  /**
    Failed running @path
    Sending error to parent plugin class
  */
  func scriptDidReceive(failure error: Script.Failure) {
    switch error {
    case let .manualTermination(.some(stderr), exitCode):
      log.info("Script was manually terminated. Output: \(stderr), exit code: \(exitCode)")
    case let .manualTermination(.none, exitCode):
      log.info("Script was manually terminated with exit code \(exitCode)")
    default:
      perform { [weak self] in
        self?.manager?.plugin(didReceiveError: String(describing: error))
      }
    }
  }

  func invoke(_ args: [String]) {
    perform { [weak self] in
      guard let this = self else { return }
      this.script = Script(path: this.path, args: args, delegate: this, autostart: true)
      this.newTimer()
    }
  }

  /**
    Called once every @interval seconds by @timer
    Terminates any ongoing script
  */
  private func scheduleDidTick() {
    perform { [weak self] in
      self?.script.restart()
    }
  }

  private func newTimer() {
    self.timer?.invalidate()
    self.timer = SwiftTimer.new(every: interval.seconds) { [weak self] in
      self?.scheduleDidTick()
    }

    perform { [weak self] in
      // self?.timer?.start(modes: .defaultRunLoopMode, .eventTrackingRunLoopMode)
      self?.timer?.start()
    }
  }

  func scriptDidReceive(piece: Script.Piece) {
    log.verbose("ExecutablePlugin received piece of output (ignoring)")
  }

  var type: String { return "Interval" }
  var meta: [String: String] {
    let date = Date()
    return [
      "Run": "Every " + date.shortTimeAgo(since: date - Int(interval))
    ]
  }
}
