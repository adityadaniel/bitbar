import AppKit
import Cocoa
import BonMot
import Hue
import OcticonsSwift
import Async
import SwiftyBeaver

class Tray: Parent, GUI {
  internal let queue = Tray.newQueue(label: "Tray")
  public let log = SwiftyBeaver.self
  public weak var root: Parent?
  private static let center = NSStatusBar.system()
  private static let length = NSVariableStatusItemLength
  private var item: MenuBar?
  static internal var item: MenuBar {
    return Tray.center.statusItem(withLength: length)
  }

  init(title: String, isVisible displayed: Bool = false, id: String? = nil, parent: Parent? = nil) {
     if App.isInTestMode() {
       self.item = TestBar()
     } else {
       perform {
         self.item = Tray.item
         self.set(title: title)
         self.root = parent
         self.tag = id
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

  private var image: NSImage? {
    set {
      perform { [weak self] in
        self?.button?.image = newValue
      }
    }

    get { return button?.image }
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
      Tray.center.removeStatusItem(bar)
    }
  }
}
