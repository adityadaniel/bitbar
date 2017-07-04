import AppKit

@testable import BitBar

extension Title: Menuable {
  func onWillBecomeVisible() {}
  var isClickable: Bool {
    return isEnabled
  }

  var isEnabled: Bool {
    return true
  }

  var banner: Mutable {
    return Mutable(string: "") /* TODO: Remove */
  }

  var image: NSImage? { return nil }
  var isSeparator: Bool { return false }
  var isChecked: Bool { return false  }
  var isAlternate: Bool { return false }
  var keyEquivalent: String { return "" }
  func onDidClick() {}
}
