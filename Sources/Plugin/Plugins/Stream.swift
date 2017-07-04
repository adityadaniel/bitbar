import SwiftyBeaver
import Script
import Foundation
import PathKit

typealias Env = [String: String]
typealias StreamPlugin = Stream

final class Stream: Base, Pluginable, Scriptable {
  public var script: Script!
  private let path: Path
  private let env: Env
  private let args: [String]
  internal weak var delegate: Manageable?

  init(path: Path, args: [String], env: Env, delegate: Manageable?) {
    self.delegate = delegate
    self.args = args
    self.path = path
    self.env = env
    super.init()
    self.script = newScript()
  }

  private func newScript(_ args: [String]? = nil) -> Script {
    return Script(
      path: path.url.path,
      args: args ?? self.args,
      env: env,
      delegate: self,
      autostart: true
    )
  }

  func invoke(_ args: [String]) {
    script = newScript(args)
  }

  func start() {
    script = newScript()
  }

  func stop() {
    script.stop()
  }

  func restart() {
    stop()
    start()
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
      delegate?.plugin(didReceiveError: stderr)
    }
  }
}
