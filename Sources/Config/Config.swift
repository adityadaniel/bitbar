import Toml
import Files
import Foundation

public class ConfigFile {
  static private let home = Folder.home
  static private let configFile = ".bitbarrc"
  static private let bundle = Bundle.main

  private let plugins: [Plugin]
  private let global: Toml

  public init() throws {
    let config = try ConfigFile.readBaseConfigAsToml()
    let tomlPlugins: [Toml] = config.array("plugin") ?? []
    guard let globalToml = config.table("global") else {
      throw ConfigError.globalSectionNotFound
    }

    plugins = tomlPlugins.map { plugin in
      return Plugin(global: globalToml, plugin: plugin)
    }
    global = globalToml
  }

  public var ignoreFiles: [String] {
    return get(key: "ignored-files", otherwise: [])
  }

  public var cliPort: Int {
    return get(key: "cli-port", otherwise: 9111)
  }

  public var cliEnabled: Bool {
    return get(key: "cli-enabled", otherwise: true)
  }

  public func findPlugin(byName name: String) -> Plugin? {
    for plugin in plugins where plugin.name == name {
      return plugin
    }

    return nil
  }

  private func get<T>(key: String, otherwise: T) -> T {
    do {
      return try global.value(key) ?? otherwise
    } catch {
      return otherwise
    }
  }

  static private func baseConfigFileUrl() throws -> URL {
    if let url = bundle.url(forResource: "bitbarrc", withExtension: "toml") {
      return url
    }

    throw ConfigError.noBaseConfigFound
  }

  static private func baseConfigFileData() throws -> Data {
    do {
      return try Data(contentsOf: try baseConfigFileUrl())
    } catch {
      throw ConfigError.unreadableBaseConfig(error)
    }
  }

  static private func createUserConfigFile() throws {
    let data = try baseConfigFileData()

    do {
      try home.createFileIfNeeded(
        withName: configFile,
        contents: data
      )
    } catch {
      throw ConfigError.couldNotInitConfig(error, configFile)
    }
  }

  static private func readBaseConfigAsToml() throws -> Toml {
    let data = try baseConfigFileData()
    guard let string = String(data: data, encoding: .utf8) else {
      throw ConfigError.notConvertable
    }

    return try Toml(withString: string)
  }

  static private func readUserConfigFile() throws -> Toml {
    let path = try userConfigPath()

    do {
      return try Toml(contentsOfFile: path)
    } catch TomlError.SyntaxError(let error) {
      throw ConfigError.couldNotParseUserConfig(error, path)
    } catch {
      throw ConfigError.unreadableUserConfig(error, path)
    }
  }

  static private func userConfigPath() throws -> String {
    do {
      return try home.file(named: configFile).path
    } catch {
      throw ConfigError.userConfigNotFound(error, configFile)
    }
  }
}
