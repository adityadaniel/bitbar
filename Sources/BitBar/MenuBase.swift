import AppKit
import Async
import SwiftyBeaver

class MenuBase: NSMenu, NSMenuDelegate, GUI {
  internal let log = SwiftyBeaver.self
  internal let queue = MenuBase.newQueue(label: "MenuBase")

  init() {
    super.init(title: "")
    self.delegate = self
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func menuWillOpen(_ menu: NSMenu) {
    for item in items {
      if let menu = item as? MenuItem {
        menu.onWillBecomeVisible()
      }
    }
  }

  public func menuDidClose(_ menu: NSMenu) {
    for item in items {
      if let menu = item as? MenuItem {
        menu.onWillBecomeInvisible()
      }
    }
  }

  public func add(submenu: NSMenuItem, at index: Int) {
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
