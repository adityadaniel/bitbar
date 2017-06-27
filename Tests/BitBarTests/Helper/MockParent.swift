@testable import BitBar
import SwiftyBeaver
import Foundation

class MockParent: Parent, Hashable, GUI {
  let queue: DispatchQueue = MockParent.newQueue(label: "MockParent")
  var root: Parent?
  var hashValue: Int {
    return Int(bitPattern: ObjectIdentifier(self))
  }
  var log: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }

  static func == (lhs: MockParent, rhs: MockParent) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  func on(_ event: MenuEvent) {
    let menu = menuRefs[self]!
    if eventRefs[menu.id] == nil {
      eventRefs[menu.id] = []
    }
    eventRefs[menu.id]! += [event]
  }
}
