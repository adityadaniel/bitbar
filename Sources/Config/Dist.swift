import PathKit
import Toml

class DistConfig {
  typealias Path = PathKit.Path
  private let home: Path
  private let name: Path

  private let blank = Path.blank
  private let shipped = Path.shipped

  init(home: Path = .home, name: Path = Path(".bitbarrc")) {
    self.name = name
    self.home = home
  }

  public var path: Path {
    return home
  }

  @discardableResult public func override(with src: Path) throws -> Toml {
    try src.copy(dest)
    return try toml()
  }

  @discardableResult public func initialize(with src: Path) throws -> Toml {
    if !dest.exists { return try override(with: src) }
    throw DistConfigError.destExist(src)
  }

  @discardableResult public func distribute(config src: Path) throws -> Toml {
    if !dest.exists { return try override(with: src) }
    return try toml()
  }

  public func cleanup() throws {
    if dest.isDirectory { throw ConfigError.dirAsConfig }
    try dest.delete()
  }

  public var hasConfig: Bool {
    return dest.exists
  }

  public func has(config: Path) -> Bool {
    switch (try? dest.read(), try? config.read()) {
    case let (.some(c1), .some(c2)):
      return c1 == c2
    default:
      return false
    }
  }

  public func toml() throws -> Toml {
    return try Toml(withString: try dest.read())
  }

  private var dest: Path {
    return home + name
  }
}
