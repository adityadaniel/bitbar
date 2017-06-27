import Async
import Vapor
import SwiftyBeaver

extension Droplet {
  var log: SwiftyBeaver.Type {
    return SwiftyBeaver.self
  }

  func start() -> Droplet {
    Async.utility { [weak self] in
      return {
        do {
          try self?.run()
        } catch {
          self?.log.error("Could not start server: \(error)")
        }
      }()
    }

    return self
  }
}
