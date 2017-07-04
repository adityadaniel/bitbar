@testable import Plugin

class Host: Timeable {
  enum Event: Equatable {
    case start
    case tick(Int)

    public static func == (lhs: Event, rhs: Event) -> Bool {
      switch (lhs, rhs) {
      case (.start, .start):
        return true
      case let (.tick(a), .tick(b)):
        return a == b
      default:
        return false
      }
    }
  }

  var timer: StopWatch?
  var callback: ((Int) -> Void)?
  var count = 0
  var latest: Int = -1
  var events = [Event]()
  var onEvent: (Event, () -> Void)?
  var runs = 0
  var stopOnEvent: Event?

  init() {
    timer = StopWatch(every: 1, delegate: self)
  }

  func timer(didTick timer: StopWatch) {
    if timer.id != latest {
      count = 0
      events.append(.start)
      callIf(.start)
      stopIf(.start)
      runs += 1
    }
    events.append(.tick(count))
    callIf(.tick(count))
    stopIf(.tick(count))
    latest = timer.id
    callback?(count)
    count += 1
  }

  func stopOn(_ event: Event) {
    stopOnEvent = event
  }

  func stopIf(_ event: Event) {
    if shouldStop(event) { stop() }
  }

  func shouldStop(_ event: Event) -> Bool {
    guard let sEvent = stopOnEvent else { return false }
    return sEvent == event
  }

  func callIf(_ event: Event) {
    switch (onEvent) {
    case let (.some(other, callback)) where other == event:
      callback()
    default:
      break
    }
  }

  func onTick(block: @escaping (Int) -> Void) {
    self.callback = block
  }

  func on(_ event: Event, block: @escaping () -> Void) {
    onEvent = (event, block)
  }

  func stop() {
    timer?.stop()
  }

  func start() {
    timer?.start()
  }

  func restart() {
    count = 0
    timer?.restart()
  }

  func deallocate() {
    timer = nil
  }
}
