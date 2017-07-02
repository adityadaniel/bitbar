import Foundation
import Dollar

extension String {
  func truncated(_ length: Int, trailing: String = "…") -> String {
    if characters.count > length {
      return self[0..<length] + trailing
    } else {
      return self
    }
  }

  /**
    Remove surrounding whitespace
  */
  func trimmed() -> String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /**
    Remove all occurrences of @what in @self
  */
  func remove(_ what: String) -> String {
    return replace(what, "")
  }

  func inspected() -> String {
    return "\"" + replace("\n", "↵") + "\""
  }

  func mutable() -> Mutable {
    return Mutable(string: self)
  }

  func split(_ by: String) -> [String] {
    return components(separatedBy: by)
  }

  var immutable: Immutable {
    return Immutable(string: self)
  }
}
