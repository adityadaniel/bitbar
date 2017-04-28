import SwiftCheck
@testable import BitBarParser

extension Menu.Head: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .text(text, tails) where tails.isEmpty:
      return String(describing: text)
    case let .text(text, tails):
      return String(describing: text) + "---\n" + tails.map { $0.toString(0) }.joined()
    case let .error(messages) where messages.isEmpty:
      /* FIXME: Invalid state */
      preconditionFailure("Error without values in not a valid state")
    case let .error(messages):
      return "Error (\(messages.count)" + "\n---\n" + messages.joined(separator: " ")
    }
  }

  static func ==== (raw: Raw.Head, lhs: Menu.Head) -> Property {
    switch raw.reduce() {
    case let .text(text, tails):
      return text ==== raw ^&&^ raw.menus ==== tails
    case let .error(messages):
      return messages.count ==== 0
    }
  }
}


