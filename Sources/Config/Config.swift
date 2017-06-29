import Toml
import PathKit
import Foundation

public class ConfigFile {
  public typealias Path = PathKit.Path
  private let dist: DistConfig
  private var plugins = [Plugin]()
  private var global: Toml = Toml()

  public init(home: Path = .home) {
    dist = DistConfig(home: home)
  }

  public var path: Path {
    return dist.path
  }

  public func distribute(_ template: Path = .blank) throws {
    let config = try dist.override(with: template)
    let items: [Toml] = config.array("plugin") ?? []
    guard let global = config.table("global") else {
      throw ConfigError.globalSectionNotFound
    }
    self.plugins = items.map { plugin in
      return Plugin(global: global, plugin: plugin)
    }
    self.global = global
  }

  public func useDefault() {
    global = Toml()
  }

  public var cliEnabled: Bool {
    return get(.cliEnabled, true)
  }

  public var ignoreFiles: [String] {
    return get(.ignoreFiles, [])
  }

  public var cliPort: Int {
    return get(.cliPort, 9111)
  }

  public var refreshOnWake: Bool {
    return get(.refreshOnWake, true)
  }

  public func cleanup() throws {
    try dist.cleanup()
  }

  public func findPlugin(byName name: String) -> Plugin {
    for plugin in plugins where plugin.name == name {
      return plugin
    }

    return Plugin(global: global)
  }

  private func get<In, Out>(_ param: Param<In, Out>) -> Out? {
    return global.get(param)
  }

  private func get<In, Out>(_ param: Param<In, Out>, _ otherwise: Out) -> Out {
    return get(param) ?? otherwise
  }
}
