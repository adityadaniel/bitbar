import AppKit

extension NSMenuItem {
  var isSeparator: Bool {
    guard let menu = self as? MenuItem else {
      return isSeparatorItem
    }

    if let attr = menu.attributedTitle {
      return attr.string.trimmed() == "-"
    }

    return menu.title.trimmed() == "-"
  }

  func onWillBecomeVisible() {}
}
