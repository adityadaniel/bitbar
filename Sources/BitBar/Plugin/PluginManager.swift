import AppKit
import Files
import Config
import Async
import Parser
import SwiftyBeaver

class PluginManager: Parent, GUI {
  internal static let instance = PluginManager(config: App.config)
  internal let queue = PluginManager.newQueue(label: "PluginManager")
  internal weak var root: Parent?
  internal let log = SwiftyBeaver.self
  // TODO: Add default pref pane to tray
  private var tray: Tray?
  private let config: ConfigFile
  private var path: String?
  internal var pluginFiles = [PluginFile]()

  /**
    Read plugins from @path
  */
  init(config: ConfigFile) {
    self.config = config
    tray = Tray(title: "BitBar", isVisible: true)
    tray?.root = self
  }

  // Add plugin @name with @path to the list of plugins
  // Will fail with an error message if @name can't be parsed
  private func addPlugin(file: Files.File) {
    let name = file.path.split("/").last ?? "??"
    let config = self.config.findPlugin(byName: name)

    guard config.isEnabled else {
      return log.info("Ignoring plugin at \(file.path) as specified in the config")
    }

    pluginFiles.append(
      PluginFile(
        file: file,
        config: config,
        delegate: self
      )
    )
  }

  func plugins(byName name: String) -> [PluginFile] {
    return pluginFiles.filter { plugin in
      return NSPredicate(format: "name LIKE %@", name).evaluate(with: plugin)
    }
  }

  func refresh() {
    loadPlugins()
    if pluginFiles.isEmpty { tray?.show() } else { tray?.hide() }
  }

  func findPlugin(byName name: String) -> PluginFile? {
    return plugins(byName: name).get(index: 0)
  }

  var pluginsNames: [String] {
    return pluginFiles.map { $0.name }
  }

  func set(path: String) {
    self.path = path
    self.refresh()
  }

  private func loadPlugins() {
    guard let folder = pluginFolder else {
      return set(error: "Could not load plugin folder")
    }

    if folder.files.count == 0 {
      return set(error: "No files found in plugin folder \(path ?? "<?>")")
    }

    pluginFiles = []

    for file in folder.files {
      if !file.name.hasPrefix(".") {
        addPlugin(file: file)
      }
    }
  }

  private var pluginFolder: Folder? {
    guard let pluginPath = path else {
      return nil
    }

    do {
      return try Folder(path: pluginPath)
    } catch {
      log.error("Could not load plugins from \(pluginPath): \(error)")
    }

    return nil
  }

  private func set(error message: String) {
    /* TODO: Display error message to user */
    tray?.set(error: true)
    tray?.show()
    log.error(message)
  }
}
