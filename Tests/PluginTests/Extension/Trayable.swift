@testable import Plugin

extension Trayable {
  var events: [Tray.Event] {
    guard let tray = self as? Tray else { return [] }
    return tray.events
  }
}
