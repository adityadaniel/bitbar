import Toml

extension Toml {
  public var dict: [String: String] {
    var output = [String: String]()
    for key in keyNames {
      guard let value = string(key.components) else {
        continue
      }

      if value.isEmpty {
        continue
      }

      let path = key.components.joined(separator: ".")

      output[path] = value
    }

    return output
  }

  func get<In, Out>(_ param: Param<In, Out>) -> Out? {
    do {
      return try param.extract(self)
    } catch {
      return nil
    }
  }
}
