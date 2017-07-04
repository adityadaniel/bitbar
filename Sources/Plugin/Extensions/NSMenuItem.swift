import Cocoa

extension NSMenuItem: Childable {
  public var items: [NSMenuItem] {
    return submenu?.items ?? []
  }

  public func equals(_ item: Childable) -> Bool {
    guard let other = item as? NSMenuItem else {
      return false
    }

    return other == self
  }
}
