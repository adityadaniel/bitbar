import Toml
import FootlessParser

public struct Plugin {
  private let global: Toml
  private let plugin: Toml?

  public init(global: Toml, plugin: Toml? = nil) {
    self.global = global
    self.plugin = plugin
  }

  public var name: String? {
    return get(.name)
  }

  public var cycleInterval: Double {
    return get(.cycleInterval, 10.0)
  }

  public var isEnabled: Bool {
    return get(.enabled, true)
  }

  public var fontFamily: String? {
    return get(.fontFamily)
  }

  public var fontSize: Int? {
    return get(.fontSize)
  }

  public var args: [String] {
    return get(.args, [])
  }

  public var env: [String: String] {
    switch (plugin?.get(.env), global.get(.env)) {
    case let (.some(pEnv), .some(gEnv)):
      return gEnv + pEnv
    case let (.none, .some(gEnv)):
      return gEnv
    case let (.some(pEnv), .none):
      return pEnv
    default:
      return [:]
    }
  }

  private func get<In, Out>(_ param: Param<In, Out>, _ otherwise: Out) -> Out {
    return get(param) ?? otherwise
  }

  private func get<In, Out>(_ param: Param<In, Out>) -> Out? {
    return plugin?.get(param) ?? global.get(param)
  }
}
