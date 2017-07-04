import WebSockets
import SwiftyBeaver
import AppKit
import SwiftyTimer
import Foundation
import Async
import JSON

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
    Async.main {
      self.handle(dest: SocketLog(self, self.log))
    }
  }

  private func handle(dest: SocketLog) {
    Timer.every(10.seconds) { (timer: Timer) in
      if self.state == .open {
        try? self.ping()
      } else {
        timer.invalidate()
        self.log.removeDestination(dest)
      }
    }

    log.addDestination(dest)
  }
}
