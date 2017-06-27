import Toml

public struct Plugin {
  private let global: Toml
  private let plugin: Toml

  public init(global: Toml, plugin: Toml) {
    self.global = global
    self.plugin = plugin
  }

  public var name: String {
    return get(key: "name", otherwise: "no-name")
  }

  public var cycleInterval: String {
    return get(key: "cycle-interval", otherwise: "50s")
  }

  public var refreshOnWakeup: Bool {
    return get(key: "refresh-on-wakeup", otherwise: true)
  }

  public var startOnBoot: Bool {
    return get(key: "start-on-boot", otherwise: false)
  }

  public var fontFamily: String? {
    return get(key: "font-family", otherwise: nil)
  }

  private func get<T>(key: String, otherwise: T) -> T {
    do {
      if let value: T = try plugin.value(key) { return value }
      if let value: T = try global.value(key) { return value }
    } catch {
      return otherwise
    }

    return otherwise
  }
}
