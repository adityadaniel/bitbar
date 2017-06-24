import AppKit
import Async
import SwiftyBeaver

class MenuBase: NSMenu, NSMenuDelegate, GUI, Parent {
  internal let log = SwiftyBeaver.self
  internal weak var root: Parent?
  internal let queue = MenuBase.newQueue(label: "MenuBase")
  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func menuWillOpen(_ menu: NSMenu) {
    perform { [weak self] in
      for item in (self?.items ?? []) {
        item.onWillBecomeVisible()
      }
    }
  }

  public func add(submenu: NSMenuItem, at index: Int) {
    perform { [weak self] in
      submenu.root = self
      self?.insertItem(submenu, at: index)
    }
  }

  public func remove(at index: Int) {
    perform { [weak self] in
      self?.removeItem(at: index)
    }
  }
}
