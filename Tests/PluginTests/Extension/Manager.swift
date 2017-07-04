import PathKit
@testable import Plugin

extension Manager {
  @discardableResult func dump(_ file: Path, as name: String? = nil) throws -> Path {
    if file.isDirectory {
      throw ManagerError.mustBeAFile(path)
    }

    if let name = name {
      return try write(from: file, to: path + Path(name))
    } else {
      return try write(from: file, to: path + Path(try file.fileName()))
    }
  }

  private func write(from: Path, to: Path) throws -> Path {
    try from.copy(to)
    return to
  }
}
