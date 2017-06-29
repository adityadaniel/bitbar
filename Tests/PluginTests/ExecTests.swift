import Quick
import SwiftyBeaver
import Nimble

@testable import Plugin

enum TimeEvent: Equatable {
  case start
  case tick(Int)

  public static func == (lhs: TimeEvent, rhs: TimeEvent) -> Bool {
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

class Host: Timeable {
  var timer: StopWatch?
  var callback: ((Int) -> Void)?
  var count = 0
  var latest: Int = -1
  var events = [TimeEvent]()
  var onEvent: (TimeEvent, () -> Void)?
  var runs = 0
  var stopOnEvent: TimeEvent?

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

  func stopOn(_ event: TimeEvent) {
    stopOnEvent = event
  }

  func stopIf(_ event: TimeEvent) {
    if shouldStop(event) { stop() }
  }

  func shouldStop(_ event: TimeEvent) -> Bool {
    guard let sEvent = stopOnEvent else { return false }
    return sEvent == event
  }

  func callIf(_ event: TimeEvent) {
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

  func on(_ event: TimeEvent, block: @escaping () -> Void) {
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

class ExecTests: QuickSpec {
  override func spec() {
    let log = SwiftyBeaver.self
    log.addDestination(ConsoleDestination())
    Nimble.AsyncDefaults.Timeout = 10

    var host: Host!
    beforeEach {
      host = Host()
    }

    it("should schedule ticker") {
      host.stopOn(.tick(2))
      expect(host.count).toEventually(equal(3))
      expect(host.runs).toEventually(equal(1))
      expect(host.runs).toNotEventually(equal(2))
      expect(host.events).toEventually(equal([.start, .tick(0), .tick(1), .tick(2)]))
    }

    describe("stop") {
      it("should stop current timer") {
        host.on(.tick(2)) {
          host.stop()
        }
        expect(host.count).toEventually(equal(2))
        expect(host.count).toNotEventually(equal(3))
        expect(host.runs).toEventually(equal(1))
        expect(host.runs).toNotEventually(equal(2))
      }

      it("handles no call") {
        host.stop()
        expect(host.count).toNotEventually(equal(1))
      }

      it("handles multiply calls") {
        host.stop()
        host.stop()
        expect(host.count).toNotEventually(equal(1))
      }

      it("automaticly stops timer when deallocated") {
        host.on(.tick(1)) {
          host.deallocate()
        }
        expect(host.count).toEventually(equal(1))
        expect(host.count).toNotEventually(equal(2))
      }
    }

    describe("start") {
      it("ignores if its already running") {
        host.on(.tick(2)) {
          host.start()
        }
        expect(host.runs).toEventually(equal(1))
        expect(host.runs).toNotEventually(equal(2))
      }

      it("handles one") {
        host.stopOn(.tick(2))
        host.start()
        expect(host.count).toNotEventually(equal(1))
        expect(host.runs).toEventually(equal(1))
        expect(host.events).toEventually(equal([.start, .tick(0), .tick(1), .tick(2)]))
      }

      it("handles multiply calls") {
        host.stopOn(.tick(2))
        host.start()
        host.start()
        expect(host.count).toEventually(equal(1))
        expect(host.runs).toEventually(equal(1))
        expect(host.events).toEventually(equal([.start, .tick(0), .tick(1), .tick(2)]))
      }

      it("automaticly stops timer when deallocated") {
        host.on(.tick(1)) {
          host.deallocate()
        }
        expect(host.count).toEventually(equal(1))
        expect(host.count).toNotEventually(equal(2))
      }
    }

    describe("restart") {
      it("should be able to restart") {
        host.on(.tick(1)) {
          switch host.runs {
          case 1:
            host.restart()
          case 2:
            host.stop()
          default:
            break
          }
        }

        expect(host.events).toEventually(equal([
          .start, .tick(0), .tick(1), .start, .tick(0), .tick(1)
          ]))
        expect(host.runs).toEventually(equal(2))
        expect(host.runs).toNotEventually(equal(3))
      }

      it("handles no call") {
        host.stopOn(.tick(0))
        host.restart()
        expect(host.count).toEventually(equal(1))
        expect(host.events).toEventually(equal([.start, .tick(0)]))
        expect(host.runs).toEventually(equal(1))
        expect(host.runs).toNotEventually(equal(2))
      }

      it("handles multiply calls") {
        host.stopOn(.tick(2))
        host.restart()
        host.restart()
        expect(host.count).toEventually(equal(3))
        expect(host.events).to(equal([.start, .tick(0), .tick(1), .tick(2)]))
      }
    }
  }
}
