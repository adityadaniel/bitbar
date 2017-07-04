import Cocoa
import SwiftyBeaver
import AppKit

class PathSelector: GUI {
  private let log = SwiftyBeaver.self
  internal let queue = PathSelector.newQueue(label: "PathSelector")
  private let title = "Use as Plugins Directory"
  private let panel = NSOpenPanel()
  /**
    @url First folder being displayed in the file selector
  */
  convenience init(withURL url: URL? = nil) {
    self.init()

    panel.directoryURL = url
    panel.prompt = title
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
  }

  public func ask(block: @escaping (URL) -> Void) {
    perform {
      guard self.panel.runModal() == NSFileHandlingPanelOKButton else {
        return self.log.info("User pressed close in plugin folder dialog")
      }

      guard self.panel.urls.count == 1 else {
        return self.log.error("Invalid number of urls \(self.panel.urls)")
      }

      block(self.panel.urls[0])
    }
  }
}
