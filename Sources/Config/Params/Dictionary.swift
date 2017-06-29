import Toml
typealias Dict = [String: String]

final class DictParam: Param<Toml, Dict> {
  override internal func extract(_ top: Toml) throws -> Dict? {
    guard let toml = top.table(key) else { return nil }
    var output = [String: String]()
    for key in toml.keyNames {
      guard let value = toml.string(key.components) else {
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
}
