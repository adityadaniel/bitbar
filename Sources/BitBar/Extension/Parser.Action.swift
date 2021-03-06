import Parser

extension Action {
  var isNop: Bool {
    switch self {
    case .nop:
      return true
    default:
      return false
    }
  }

  var isClickable: Bool? {
    if isNop { return nil }
    return true
  }
}
