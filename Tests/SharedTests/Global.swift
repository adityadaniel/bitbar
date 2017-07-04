import Nimble
import Async

public let after = { (time: Double, block: @escaping () -> Void) in
  waitUntil(timeout: time + 20) { done in
    Async.main(after: time) {
      block()
      done()
    }
  }
}
