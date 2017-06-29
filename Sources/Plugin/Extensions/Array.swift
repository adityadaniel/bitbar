import Foundation

extension Array where Element == String {
  func join(_ sep: String) -> String {
    return joined(separator: sep)
  }
}

extension Array {
  var isPresent: Bool {
    return !isEmpty
  }
}
