import Cocoa

extension NSMenu: Childable {
  public func equals(_ item: Childable) -> Bool {
    guard let other = item as? NSMenu else {
      return false
    }

    return other == self
  }
}
