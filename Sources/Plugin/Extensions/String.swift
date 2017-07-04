import Foundation
import Cent

extension String {
  func truncated(_ length: Int, trailing: String = "…") -> String {
    if characters.count > length {
      return self[0..<length] + trailing
    } else {
      return self
    }
  }

  func replace(_ a: String, _ b: String) -> String {
    return replacingOccurrences(of: a, with: b)
  }

  func remove(_ what: String) -> String {
    return replace(what, "")
  }

  func split(_ by: String) -> [String] {
    return components(separatedBy: by)
  }

  var isBlank: Bool {
    return trimmed.isEmpty
  }

  var isPresent: Bool {
    return !isBlank
  }

  var inspected: String {
    return "\"" + replace("\n", "↵").truncated(100) + "\""
  }

  var trimmed: String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
