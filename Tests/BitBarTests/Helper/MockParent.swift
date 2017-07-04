@testable import BitBar
import SwiftyBeaver
import Foundation

extension MenuEvent {
  var log: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }
}

class MockParent: Hashable, GUI {
  let queue: DispatchQueue = MockParent.newQueue(label: "MockParent")

  var hashValue: Int {
    return Int(bitPattern: ObjectIdentifier(self))
  }

  var log: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }

  static func == (lhs: MockParent, rhs: MockParent) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}
