import Cocoa
import SwiftyBeaver
import Async
import AppKit
import Files

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

  public func ask(block: @escaping Block<URL>) {
    perform { [weak self] in
      guard let this = self else { return }

      guard this.panel.runModal() == NSFileHandlingPanelOKButton else {
        return this.log.info("User pressed close in plugin folder dialog")
      }

      guard this.panel.urls.count == 1 else {
        return this.log.error("Invalid number of urls \(this.panel.urls)")
      }

      block(this.panel.urls[0])
    }
  }
}
