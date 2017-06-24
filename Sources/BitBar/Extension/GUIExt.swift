import Foundation

extension GUI {
  static func newQueue(label: String) -> DispatchQueue {
    return DispatchQueue(label: label, qos: .background, target: .main)
  }

  internal func perform(block: @escaping () -> Void) {
    if App.isInTestMode() { return block() }
    queue.async(execute: block)
  }
}
