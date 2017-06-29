import PathKit

extension Path {
  static var tmp: Path {
    return try! .processUniqueTemporary()
  }
}
