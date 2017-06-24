import Foundation
import Cocoa
import SwiftyBeaver

class RefreshPluginHandler {
  private weak var manager: PluginManager?
  private let queries: [String: String]
  private let log = SwiftyBeaver.self

  init(_ queries: [String: String], manager: PluginManager) {
    self.queries = queries
    self.manager = manager
  }

  public func execute() {
    guard let name = queries["name"] else {
      return log.error("Name not specified for refreshPlugin")
    }

    guard let manager = manager else {
      return log.error("Plugin manager has been deallocated")
    }

    for plugin in manager.plugins(byName: name) {
      plugin.refresh()
    }
  }
}
