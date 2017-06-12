import AppKit
import Async

class MenuBase: NSMenu, NSMenuDelegate, GUI {
  internal let queue = MenuBase.newQueue(label: "MenuBase")
  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func menuWillOpen(_ menu: NSMenu) {
    perform {
      for item in self.items {
        item.onWillBecomeVisible()
      }
    }
  }
}
