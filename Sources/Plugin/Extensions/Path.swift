import PathKit
import Foundation

public extension Path {
  init(_ url: URL) {
    self.init(url.path)
  }

  public func fileName() throws -> String {
    if isDirectory { throw PathError.notAFile(self) }
    return url.lastPathComponent
  }

  public var name: String? {
    return try? fileName()
  }

  public var dir: String {
    return url.path
  }
}
