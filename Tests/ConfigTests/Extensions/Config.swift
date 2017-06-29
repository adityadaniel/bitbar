import PathKit
@testable import Config

extension ConfigFile {
  static func using(template: Path) throws -> ConfigFile {
    let temp = try Path.uniqueTemporary()
    let config = ConfigFile(home: temp)
    try config.distribute(template)
    return config
  }
}
