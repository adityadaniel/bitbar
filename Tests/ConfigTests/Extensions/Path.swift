import PathKit

extension Path {
  static let example = Path.resource(forFile: "bitbarrc.example.toml")!
  static let test = Path.resource(forFile: "bitbarrc.test.toml")!
  static let invalid = Path.resource(forFile: "bitbarrc.invalid.toml")!
}
