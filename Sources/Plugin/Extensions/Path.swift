import PathKit
import Foundation

extension Path {
  func fileName() throws -> String {
    if isDirectory { throw PathError.notAFile(self) }
    return url.lastPathComponent
  }
}
