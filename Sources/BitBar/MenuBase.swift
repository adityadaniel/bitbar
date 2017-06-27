import AppKit
import Async
import SwiftyBeaver

class MenuBase: NSMenu, NSMenuDelegate, GUI, Parent {
  internal let log = SwiftyBeaver.self
  internal weak var root: Parent?
  internal let queue = MenuBase.newQueue(label: "MenuBase")

  init(root: Parent? = nil) {
    super.init(title: "")
    self.delegate = self
    self.root = root
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func menuWillOpen(_ menu: NSMenu) {
    perform { [weak self] in
      for item in (self?.items ?? []) {
        if let menu = item as? MenuItem {
          menu.onWillBecomeVisible()
        }
      }
    }
  }

  public func add(submenu: NSMenuItem, at index: Int) {
    if let menu = submenu as? MenuItem {
      menu.root = self
    }

    perform { [weak self] in
      self?.insertItem(submenu, at: index)
    }
  }

  public func remove(at index: Int) {
    perform { [weak self] in
      self?.removeItem(at: index)
    }
  }
}
