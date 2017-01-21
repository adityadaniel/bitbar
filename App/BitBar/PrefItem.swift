import Cocoa
import AppKit
import EmitterKit

final class PrefItem: ItemBase {
  weak var delegate: TrayDelegate?

  convenience init(delegate: TrayDelegate?) {
    self.init("Preferences")
    self.delegate = delegate

    separator()
    addSub("Refresh All", key: "r") {
      self.delegate?.preferenceDidRefreshAll()
    }

    separator()

    addSub("Change Plugin Folder…") {
      // TODO: Move this logic into its own class
      let openPanel = NSOpenPanel()
      openPanel.allowsMultipleSelection = false
      openPanel.prompt = "Use as Plugins Directory"

      if let url = App.pluginURL {
        openPanel.directoryURL = url
      }

      openPanel.canChooseDirectories = true
      openPanel.canCreateDirectories = false
      openPanel.canChooseFiles = false
      if openPanel.runModal() == NSModalResponseOK {
        App.update(pluginPath: openPanel.url?.path)
        self.delegate?.preferenceDidChangePluginFolder()
      }
    }

    addSub("Open Plugin Folder…") {
      if let path = App.pluginPath {
        App.open(path: path)
      }
    }

    addSub("Get Plugins…") {
      App.open(url: App.website)
    }

    separator()

    addSub("Open at Login", checked: App.autostart) { (menu: ItemBase) in
      App.update(autostart: menu.state == NSOnState)
    }

    separator()

    addSub("Check for Updates…") {
      // TODO: Implement this
    }

    addSub("Quit", key: "q") {
      self.delegate?.preferenceDidQuit()
    }
  }
}
