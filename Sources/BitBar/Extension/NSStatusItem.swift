import AppKit

extension NSStatusItem: MenuBar {
  func show() {
    if #available(OSX 10.12, *) {
      isVisible = true
    }
  }

  func hide() {
    if #available(OSX 10.12, *) {
      isVisible = false
    }
  }
}