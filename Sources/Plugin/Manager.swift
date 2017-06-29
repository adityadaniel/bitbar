import Config
import Parser
import PathKit

final class Manager: Base {
  private var tray: Tray = Tray(title: "BitBar", isVisible: false)
  private let config: ConfigFile
  private var path: Path
  private var plugins = [Plugin]() {
    didSet { synchronize() }
  }

  public var names: [String] { return plugins.map { $0.name } }

  /**
    Read plugins from @path
  */
  init(_ config: ConfigFile) {
    self.config = config
    self.path = config.path
    super.init()
  }

  // Add plugin @name with @path to the list of plugins
  // Will fail with an error message if @name can't be parsed
  private func add(_ path: Path) throws {
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
      handler: handler
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
    path = Path(dir)
    guard path.exists else {
      throw ManagerError.pathDoesNotExist(dir)
    }

    log.info("Update plugin path to \(dir)")
    refresh()
  }

  public func refresh() {
    plugins = []

    for path in files {
      if path.url.path.hasPrefix(".") { continue }
      do {
        try add(path)
      } catch {
        log.error("Could not add \(path) to list of plugins: \(error)")
      }
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

  private func synchronize() {
    if plugins.isPresent {
      log.info("No plugins found in manager")
      tray.hide()
    } else {
      log.info("Updating \(plugins.count) plugins")
      tray.show()
    }
  }
}
