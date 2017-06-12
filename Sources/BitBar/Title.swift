import Parser
import BonMot
import SwiftyBeaver
import Async
protocol GUI {
  var queue: DispatchQueue { get }
  func perform(block: @escaping () -> Void)
}

extension GUI {
  static func newQueue(label: String) -> DispatchQueue {
    return DispatchQueue(label: label, target: .main)
  }
  
  internal func perform(block: @escaping () -> Void) {
    Async.custom(queue: queue) { block() }
  }
}

final class Title: MenuBase, Parent, GUI {
  internal let queue = Title.newQueue(label: "Title")
  internal let log = SwiftyBeaver.self
  internal weak var root: Parent?
  private let ago = Pref.UpdatedTimeAgo()
  private let runInTerminal = Pref.RunInTerminal()
  private var numberOfPrefs = 0
  internal var hasLoaded: Bool = false

  init(prefs: [NSMenuItem], delegate: Parent) {
    super.init()
    root = delegate
    perform {
      self.add(sub: NSMenuItem.separator())
      self.add(sub: self.ago)
      self.add(sub: self.runInTerminal)
      self.add(sub: Pref.Preferences(prefs: prefs))
      self.numberOfPrefs = self.numberOfItems
    }
    self.delegate = self
  }

  init(x: Int) {
    super.init()
  }

  // Only keep pref menus
  func set(menus: [NSMenuItem]) {
    perform {
      self.reset()

      for menu in menus {
        self.add(sub: menu)
      }

      self.ago.reset()
      self.hasLoaded = true
    }
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func add(sub: NSMenuItem) {
    sub.root = self
    insertItem(sub, at: numberOfItems - numberOfPrefs)
  }

  private func reset() {
    guard numberOfPrefs < numberOfItems else { return }
    for _ in numberOfPrefs..<numberOfItems {
      removeItem(at: 0)
    }
  }
}
