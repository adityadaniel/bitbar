import Foundation
import Cocoa
import SwiftyBeaver
import Plugin

class RefreshPluginHandler {
  private weak var manager: Manager?
  private let queries: [String: String]
  private let log = SwiftyBeaver.self

  init(_ queries: [String: String], manager: Manager) {
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

    for plugin in manager.search(byName: name) {
      plugin.refresh()
    }
  }
}
