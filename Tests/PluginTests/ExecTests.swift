import Quick
import SwiftyBeaver
import Nimble

@testable import Plugin

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
