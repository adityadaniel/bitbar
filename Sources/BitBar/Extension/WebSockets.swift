import WebSockets
import SwiftyBeaver
import SwiftTimer
import Foundation
import Async
import JSON

extension Int {
  var seconds: Int {
    return self
  }
}

extension SwiftTimer {
  static func every(_ seconds: Int, block: @escaping () -> Void) -> SwiftTimer {
    let timer = repeaticTimer(interval: .seconds(seconds)) { _ in block() }
    timer.start()
    return timer
  }

  static func new(every seconds: Int, block: @escaping () -> Void) -> SwiftTimer {
    return repeaticTimer(interval: .seconds(seconds)) { _ in block() }
  }

  func invalidate() { }
}

extension WebSocket {
  private var log: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }

  func send(fatal message: String) {
    send(msg: message, level: "info")
  }

  func send(msg message: String, level: String) {
    guard let json = try? JSON(node: ["message": message, "level": level]) else {
      return log.error("Could not convert error message \(message) to JSON")
    }

    guard (try? send(String(describing: json))) != nil else {
      return log.error("Could not send message '\(message)' over websocket")
    }
  }

  func setup() {
    self.handle(dest: SocketLog(self, self.log))
  }

  private func handle(dest: SocketLog) {
    let timer = SwiftTimer.every(10.seconds) { [weak self] in
      if self?.state == .open {
        try? self?.ping()
      }
    }

    onClose = { [weak self] _, _, _, _ in
      self?.log.removeDestination(dest)
      timer.invalidate()
    }

    log.addDestination(dest)
  }
}
