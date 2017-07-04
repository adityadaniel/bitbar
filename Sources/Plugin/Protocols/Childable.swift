import Cocoa

public protocol Childable {
  var items: [NSMenuItem] { get }
  func has(child: Childable) -> Bool
  func equals(_ item: Childable) -> Bool
}

public extension Childable {
  func has(child: Childable) -> Bool {
    if equals(child) { return true }

    for item in items {
      if item.has(child: child) {
        return true
      }
    }

    return false
  }
}
