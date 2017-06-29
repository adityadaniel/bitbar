import SwiftyBeaver
import Script
import Foundation
import PathKit

typealias Env = [String: String]
typealias StreamPlugin = Stream

final class Stream: Base, Pluginable, Scriptable {
  private var script: Script!
  private let path: Path
  private let env: Env
  internal weak var delegate: Manageable?

  init(path: Path, args: [String], env: Env, delegate: Manageable?) {
    self.delegate = delegate
    self.path = path
    self.env = env
    super.init()
    self.script = newScript(args)
  }

  private func newScript(_ args: [String]) -> Script {
    // TODO: Add env
    return Script(path: path.url.path, args: args, delegate: self, autostart: true)
  }

  func invoke(_ args: [String]) {
    script = newScript(args)
  }

  func start() {
    script.start()
  }

  func stop() {
    script.stop()
  }

  func refresh() {
    script.restart()
  }

  func scriptDidReceive(success result: Script.Success) {
    switch (result, script.isRunning) {
    case let (.withZeroExitCode(.some(stdout)), true):
      delegate?.plugin(didReceiveOutput: stdout)
    case (.withZeroExitCode(.none), true):
      log.info("No output provided")
    case (.withZeroExitCode, false):
      delegate?.plugin(didReceiveError: "Streaming script is no longer running")
    }
  }

  func scriptDidReceive(failure: Script.Failure) {
    switch failure {
    case .manualTermination:
      delegate?.plugin(didReceiveError: "Streaming script is no longer running")
    default:
      delegate?.plugin(didReceiveError: String(describing: failure))
    }
  }

  func scriptDidReceive(piece: Script.Piece) {
    switch piece {
    case let .succeeded(stdout):
      delegate?.plugin(didReceiveOutput: stdout)
    case let .failed(stderr):
      log.error("Received a piece of failure: \(stderr.inspected)")
    }
  }
}
