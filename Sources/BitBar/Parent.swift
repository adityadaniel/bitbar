import SwiftyBeaver

protocol Parent: class, GUI {
  var log: SwiftyBeaver.Type { get }
  weak var root: Parent? { get set }
  func on(_ event: MenuEvent)
  func broadcast(_ event: MenuEvent)
}

extension Parent {
  func broadcast(_ event: MenuEvent) {
    // guard let root = root else { return log.warning("No root found")
    // }

    // log.verbose("Broadcasting event: \(event)")
    // root.broadcast(event)
    // perform { [weak root] in root.on(event) }
  }

  func on(_ event: MenuEvent) {
    log.verbose(" Unhandled event: \(event)")
  }
}
