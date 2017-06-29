import FootlessParser
import Toml

class Param<In, Out> {
  internal let key: String

  init(_ key: String) {
    self.key = key
  }

  internal func extract(_ toml: Toml) throws -> Out? {
    do {
      guard let value: In = try toml.value(key) else {
        return nil
      }

      return try transform(value)
    } catch {
      return nil
    }
  }

  internal func transform(_ value: In) throws -> Out {
    if let result = value as? Out {
      return result
    }

    throw ParamError.invalidTransform
  }
}
