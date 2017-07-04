import AppKit
import BonMot
import Async
import SwiftyBeaver
import OcticonsSwift
import ReSwift

class MenuItem: NSMenuItem, GUI, StoreSubscriber {
  internal let queue = MenuItem.newQueue(label: "MenuItem")
  public var isManualClickable: Bool?
  public let log = SwiftyBeaver.self

  convenience init() {
    self.init(title: "…")
  }

  init(
    immutable: Immutable,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool? = nil,
    shortcut: String = ""
  ) {
    super.init(
      title: "",
      action: #selector(__onDidClick) as Selector?,
      keyEquivalent: shortcut
    )

    target = self
    set(title: immutable)

    if !submenus.isEmpty {
      submenu = MenuBase()
    }

    for sub in submenus {
      add(submenu: sub)
    }

    self.isChecked = isChecked
    self.isManualClickable = isClickable

    if isAlternate {
      perform { [weak self] in
        self?.isAlternate = true
        self?.keyEquivalentModifierMask = .option
      }
    }

    mainStore.subscribe(self)
  }

  func onWillBecomeVisible() {
  }

  func onWillBecomeInvisible() {
  }

  convenience init(error: String, submenus: [NSMenuItem] = []) {
    /* TODO: Dont pass an empty string */
    self.init(title: "", submenus: submenus)
    set(error: error)
  }

  convenience init(
    image: NSImage,
    submenus: [NSMenuItem] = [],
    isAlternate: Bool = false,
    isChecked: Bool = false,
    isClickable: Bool? = nil,
    shortcut: String = ""
  ) {
    self.init(
      immutable: "".immutable,
      submenus: submenus,
      isAlternate: isAlternate,
      isChecked: isChecked,
      isClickable: isClickable,
      shortcut: shortcut
    )

    self.icon = image
  }

 convenience init(
   title: String,
   submenus: [NSMenuItem] = [],
   isAlternate: Bool = false,
   isChecked: Bool = false,
   isClickable: Bool? = nil,
   shortcut: String = ""
 ) {
    self.init(
     immutable: title.immutable,
     submenus: submenus,
     isAlternate: isAlternate,
     isChecked: isChecked,
     isClickable: isClickable,
     shortcut: shortcut
    )
  }

  required init(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var isClickable: Bool {
    return validateMenuItem(self)
  }

  public func set(error: String) {
    set(error: error.immutable)
  }

  public func set(title: String) {
    set(title: title.immutable)
  }

  @nonobjc public func set(error: Immutable) {
    set(title: error)
    mainStore.dispatch(.didSetError(self))
  }

  @nonobjc public func set(title: Immutable) {
    perform { [weak self] in
      self?.attributedTitle = self?.style(title)
    }
  }

  @nonobjc public func set(error: Bool) {
    if error {
      showErrorIcons()
    } else {
      hideErrorIcons()
    }

    if let aParent = parent, let bParent = aParent as? MenuItem {
      bParent.set(error: error)
    }
  }

  public func onDidClick() {
    /* NOP */
  }

  func newState(state: AppState) {
    /* NOP */
  }

  public var isChecked: Bool {
    get { return NSOnState == state }
    set {
      perform { [weak self] in
        self?.state = newValue ? NSOnState : NSOffState
      }
    }
  }

  @objc public func __onDidClick() {
    log.verbose("Clicked on item in dropdown menu")
    perform { [weak self] in
      self?.onDidClick()
    }
  }

  override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    if let state = isManualClickable {
      return state
    }

    if hasSubmenu {
      return true
    }

   if isSeparator {
     return false
   }

    return !keyEquivalent.isEmpty
  }

  override public var debugDescription: String {
    return String(describing: [
      "title": title,
      "isChecked": isChecked,
      "isAlternate": isAlternate,
      "isEnabled": isEnabled,
      "hasSubmenu": hasSubmenu,
      "keyEquivalent": keyEquivalent
    ])
  }

  private func showErrorIcons() {
    perform { [weak self] in
      let fontSize = Int(FontType.item.size)
      let size = CGSize(width: fontSize, height: fontSize)

      self?.icon = NSImage(
        octiconsID: OcticonsID.bug,
        iconColor: .black,
        size: size
      )

      self?.updateSubmenu()
    }
  }

  private func hideErrorIcons() {
    icon = nil
    updateSubmenu()
  }

  private var icon: NSImage? {
    set {
      perform { [weak self] in
        self?.image = newValue
      }
    }
    get { return image }
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.item.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.item.font))
  }

  private func add(submenu item: NSMenuItem) {
    submenu?.addItem(item)
  }

  private func updateSubmenu() {
    perform { [weak self] in
      self?.submenu?.update()
    }
  }

  deinit {
    mainStore.unsubscribe(self)
  }
}
