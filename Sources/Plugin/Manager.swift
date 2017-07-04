import Config
import Parser
import PathKit
import Script

public final class Manager: Base {
  internal var tray: Trayable
  private let config: Config
  internal var path: Path
  internal var plugins = [PluginFile]()
  public var names: [String] { return plugins.map { $0.name } }
  private let trayable: Trayable.Type

  /**
    Read plugins from @path
  */
  public init(_ config: Config = Config(), trayer: Trayable.Type = Tray.self) {
    self.config = config
    self.path = config.path
    self.trayable = trayer
    self.tray = trayable.init(title: "BitBar", isVisible: false)
    super.init()
  }

  public func script(from item: Childable) -> Script? {
    return plugin(from: item)?.script
  }

  public func plugin(from item: Childable) -> Plugin? {
    for plugin in plugins where plugin.has(child: item) {
      return plugin
    }

    return nil
  }

  // Add plugin @name with @path to the list of plugins
  // Will fail with an error message if @name can't be parsed
  private func add(_ path: Path) throws {
    log.info("Add plugin from path: \(path)")
    let name = try path.fileName()
    let config = self.config.findPlugin(byName: name)
    guard config.isEnabled else {
      return log.info("Ignoring plugin at \(path) as specified in the config")
    }

    let klass = Classifier(path: path, args: config.args, env: config.env)
    let handler = try klass.plugin()

    let plugin = Plugin(
      path: path,
      config: config,
      handler: handler,
      trayer: trayable
    )
    handler.delegate = plugin
    plugins.append(
      plugin
    )
  }

  public func search(byName name: String) -> [Plugin] {
    return plugins.filter { $0.name == name }
    // TODO:
    // return plugins.filter { plugin in
    //   return NSPredicate(format: "name LIKE %@", name).evaluate(with: plugin)
    // }
  }

  public func findPlugin(byName name: String) -> Plugin? {
    return search(byName: name).get(index: 0)
  }

  public func set(path dir: String) throws {
    let path = Path(dir)
    guard path.exists else {
      throw ManagerError.pathDoesNotExist(dir)
    }

    log.info("Update plugin path to \(dir)")
    self.path = path
    refresh()
  }

  public func refresh() {
    plugins = []

    for path in files {
      if path.hasPrefix(".") { continue }
      do {
        try add(path)
      } catch {
        log.error("Could not add \(path) to list of plugins: \(error)")
      }
    }

    if plugins.isEmpty {
      log.info("Updating \(plugins.count) plugins")
      tray.show()
    } else {
      log.info("No plugins found in manager")
      tray.hide()
    }
  }

  private func set(error: String) {
    log.error(error)
    tray.set(error: error)
  }

  internal var files: [Path] {
    do {
      return try path.children()
    } catch {
      log.error("Could not load path \(path) due to: \(error)")
    }

    return []
  }
}
