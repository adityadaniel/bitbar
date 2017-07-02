import Foundation
import Config
import SwiftyBeaver
import Async
import PathKit
import Parser

internal typealias PluginFile = Plugin
public final class Plugin: Base, Rotatable, Manageable {
  typealias Head = Parser.Menu.Head
  typealias Text = Parser.Text
  typealias Tail = Parser.Menu.Tail

  internal var rot: Rotator!
  internal let tray: Trayable
  private let path: Path
  private var config: PluginConfig
  private var worker: AsyncBlock<Void, Void>?
  private let plug: Pluginable
  private var stdout: String?
  private var stderr: String?
  private var tails: [Tail] = []

  public var name: String { return (try? path.fileName()) ?? "===" }

  public init(path: Path, config: PluginConfig, handler: Pluginable, trayer: Trayable.Type) {
    self.path = path
    self.config = config
    self.plug = handler
    self.tray = trayer.init(title: "…", isVisible: true)
    super.init()
    self.rot = Rotator(every: 1, delegate: self)
    self.plug.delegate = self
  }

  public func invoke(_ args: [String]) {
    log.info("Invoke with args \(args.join(", "))")
    plug.invoke(args)
  }

  public func hide() {
    tray.hide()
    plug.stop()
    rot.stop()
    worker?.cancel()
    log.verbose("Hide plugin")
  }

  public func show() {
    tray.show()
    plug.start()
    rot.start()
    log.verbose("Show plugin")
  }

  public func refresh() {
    plug.restart()
    log.verbose("Refresh")
  }

  public func plugin(didReceiveError stderr: String) {
    guard stderr != self.stderr else {
      return log.info("Error has not changed")
    }

    self.stderr = stderr
    set(error: .output(stderr))
  }

  public func plugin(didReceiveOutput stdout: String) {
    guard stdout.isPresent else {
      return set(error: .noOutput)
    }

    guard stdout != self.stdout else {
      return log.info("Input has not changed")
    }

    self.stdout = stdout
    worker?.cancel()
    worker = Async.background { [weak self] in
      self?.set(head: reduce(stdout))
    }
  }

  internal func rotator(didRotate text: Text) {
    tray.set(title: text)
  }

  private func set(title: String) {
    log.info("Update title: \(title.inspected)")
    tray.set(title: title)
  }

  private func set(error: PluginError) {
    set(error: String(describing: error))
  }

  private func set(errors: [String]) {
    log.error("Got \(errors.count) errors: \(errors)")
    tray.set(errors: errors)
  }

  private func set(error: String) {
    log.error("Got error: \(error)")
    tray.set(error: error)
  }

  private func set(errors: [MenuError]) {
    for error in errors {
      log.error("Got menu error: \(error)")
    }

    tray.set(errors: errors)
  }

  private func set(head: Head) {
    switch head {
    case let .text(text, tails):
      do {
        try rot.set(text: text)
        if tails != self.tails {
          tray.set(tails)
        }
        self.tails = tails
      } catch {
        log.error("Rotator failed: \(error)")
      }
    case let .error(errors):
      set(errors: errors)
    }
  }

  deinit {
    plug.stop()
    rot.stop()
    worker = nil
  }
}
