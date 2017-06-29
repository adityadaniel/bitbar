import SwiftyTimer
import PathKit
import SwiftyBeaver
import Script

class Interval: Base, Pluginable, Scriptable, Timeable {
  private var script: Script!
  private var timer: StopWatch!
  private let path: Path
  internal weak var delegate: Manageable?

  init(path: Path, frequency: Int, args: [String], env: Env, delegate: Manageable?) {
    self.delegate = delegate
    self.path = path
    // TODO: Add env
    super.init()
    self.timer = StopWatch(every: frequency, delegate: self)
    self.script = newScript(args)
  }

  private func newScript(_ args: [String]) -> Script {
    // TODO: Add env
    return Script(path: path.url.path, args: args, delegate: self)
  }

  /**
    Run @path once every @interval seconds
  */
  func start() {
    timer.start()
    script.start()
  }

  /**
    Stop timer and script
  */
  func stop() {
    timer.stop()
    script.stop()
  }

  /**
    Restart the script
  */
  func refresh() {
    stop()
    start()
  }

  func scriptDidReceive(success result: Script.Success) {
    switch result {
    case let .withZeroExitCode(.some(stdout)):
      log.verbose("Script did receive stdout: \(stdout.inspected)")
      delegate?.plugin(didReceiveOutput: stdout)
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
      log.error("Script did receive error: \(error)")
      delegate?.plugin(didReceiveError: String(describing: error))
    }
  }

  func invoke(_ args: [String]) {
    script = newScript(args)
  }

  func scriptDidReceive(piece: Script.Piece) {
    // log.verbose("ExecutablePlugin received piece of output (ignoring)")
  }

  internal func timer(didTick: StopWatch) {
    script.restart()
  }
}
