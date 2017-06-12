import AppKit
import Async

class MenuBase: NSMenu, NSMenuDelegate {
  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func menuWillOpen(_ menu: NSMenu) {
    Async.main {
      for item in self.items {
        item.onWillBecomeVisible()
      }
    }
  }
}
