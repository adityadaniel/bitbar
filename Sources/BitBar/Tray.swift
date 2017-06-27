import AppKit
import Cocoa
import BonMot
import Hue
import OcticonsSwift
import SwiftyBeaver

class Tray: Parent, GUI {
  internal let queue = Tray.newQueue(label: "Tray")
  public let log = SwiftyBeaver.self
  public weak var root: Parent?
  private var item: MenuBar?

  init(title: String, isVisible displayed: Bool = false, id: String? = nil, parent: Parent? = nil) {
    if App.isInTestMode() {
      item = TestBar()
      root = parent
    } else {
      perform {
        self.item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.item?.attributedTitle = self.style(title)
        self.item?.tag = id
        self.root = parent
        if !displayed { self.hide() }
      }
    }
  }

  public var attributedTitle: NSAttributedString? {
    get { return item?.attributedTitle }
    set {
      perform { [weak self] in
        self?.item?.attributedTitle = newValue
      }
    }
  }

  public var menu: NSMenu? {
    get { return item?.menu }
    set {
      perform { [weak self] in
        self?.item?.menu = newValue
      }
    }
  }

  /**
   Hides item from menu bar
  */
  public func hide() {
    perform { [weak self] in
      self?.item?.hide()
    }
  }

  /**
    Display item in menu bar
  */
  public func show() {
    perform { [weak self] in
      self?.item?.show()
    }
  }

  public func on(_ event: MenuEvent) {
    switch event {
    case .didSetError:
      set(error: true)
    case .didClickMenuItem:
      isHighlightMode = false
    default:
      break
    }
  }

  public func set(error: Bool) {
    if error {
      showErrorIcons()
      attributedTitle = nil
    } else { hideErrorIcons() }
  }

  public func set(title: Immutable) {
    hideErrorIcons()
    attributedTitle = style(title)
  }

  public func set(title: String) {
    set(title: title.immutable)
  }

  private func showErrorIcons() {
    perform { [weak self] in
      guard let this = self else { return }
      let fontSize = Int(FontType.bar.size)
      let size = CGSize(width: fontSize, height: fontSize)
      let icon = OcticonsID.bug

      this.image = NSImage(
        octiconsID: icon,
        iconColor: NSColor(hex: "#474747"),
        size: size
      )

      this.alternateImage = NSImage(
        octiconsID: icon,
        backgroundColor: .white,
        iconColor: .white,
        iconScale: 1.0,
        size: size
      )
    }
  }

  private func hideErrorIcons() {
    image = nil
    alternateImage = nil
  }

  func set(menus: [NSMenuItem]) {
    guard let menu = menu else { return }
    guard let aMenu = menu as? Title else { return }
    aMenu.set(menus: menus)
  }

  private var image: NSImage? {
    set {
      perform { [weak self] in
        self?.button?.image = newValue
      }
    }

    get { return button?.image }
  }

  private var isHighlightMode: Bool {
    set {
      perform { [weak self] in
        self?.button?.highlight(newValue)
      }
    }

    get { return false }
  }

  private var alternateImage: NSImage? {
    set {
      perform { [weak self] in
        self?.button?.alternateImage = newValue
      }
    }

    get { return button?.alternateImage }
  }

  private var button: NSButton? {
    if let button = item?.button {
      return button
    }

    return nil
  }

  private var tag: String? {
    get { return item?.tag }
    set {
      perform { [weak self] in
        self?.item?.tag = newValue
      }
    }
  }

  private func style(_ immutable: Immutable) -> Immutable {
    return immutable.styled(with: .font(FontType.bar.font))
  }

  private func style(_ string: String) -> Immutable {
    return string.styled(with: .font(FontType.bar.font))
  }

  deinit {
    if let bar = item as? NSStatusItem {
      NSStatusBar.system().removeStatusItem(bar)
    }
  }
}
