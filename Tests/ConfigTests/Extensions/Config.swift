import PathKit
@testable import Config

extension Config {
  static func using(template: Path) throws -> Config {
    let temp = try Path.uniqueTemporary()
    let config = Config(home: temp)
    try config.distribute(template)
    return config
  }
}
