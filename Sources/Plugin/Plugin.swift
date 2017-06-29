import Foundation
import Config
import SwiftyBeaver
import Async
import PathKit
import Parser

internal typealias PluginFile = Plugin
internal final class Plugin: Base, Rotatable, Manageable {
  typealias Head = Parser.Menu.Head
  typealias Text = Parser.Text

  internal var rot: Rotator!
  private let tray: Tray = Tray(title: "…")
  private let path: Path
  private var config: Config.Plugin
  private var worker: AsyncBlock<Void, Void>?
  private let plug: Pluginable

  public var name: String { return (try? path.fileName()) ?? "===" }

  public init(path: Path, config: Config.Plugin, handler: Pluginable) {
    self.path = path
    self.config = config
    self.plug = handler
    super.init()
    self.rot = Rotator(every: Int(config.cycleInterval), delegate: self)
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
    plug.refresh()
    log.verbose("Refresh")
  }

  internal func plugin(didReceiveError error: String) {
    set(error: .output(error))
  }

  internal func plugin(didReceiveOutput data: String) {
    guard data.isPresent else {
      return set(error: .noOutput)
    }

    worker?.cancel()
    worker = Async.background {
      self.set(head: reduce(data))
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

  private func set(head: Head) {
    Async.main {
      switch head {
      case let .text(text, tails):
        do {
          try self.rot.set(text: text)
          self.tray.set(tails)
        } catch {
          self.log.error("Rotator failed: \(error)")
        }
      case let .error(messages):
        self.set(errors: messages.map(String.init(describing:)))
      }
    }
  }

  deinit {
    plug.stop()
    rot.stop()
    worker = nil
  }
}
