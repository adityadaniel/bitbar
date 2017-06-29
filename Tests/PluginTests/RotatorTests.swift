import Quick
import Nimble
import Parser
import Async

@testable import Plugin
public typealias Text = Parser.Text

public func cyclicSubset<T: Equatable>(of cycle: [T]) -> Predicate<[T]> {
  return Predicate { (actual: Expression<[T]>) throws -> PredicateResult in
    let msg = ExpectationMessage.expectedActualValueTo("be cyclic")
    if let list = try actual.evaluate() {
      if list.isEmpty { return PredicateResult(bool: false, message: msg) }
      for (index, value) in cycle.enumerated() {
        switch (value, list.get(index: index % list.count)) {
        case let (that, .some(this)) where that == this:
          continue
        default:
          return PredicateResult(status: .fail, message: msg)
        }
      }

      return PredicateResult(bool: true, message: msg)
    }

    return PredicateResult(status: .fail, message: msg)
  }
}

extension Text: Equatable {
  static let text1: Text = .normal("A", [])
  static let text2: Text = .normal("B", [])
  static let text3: Text = .normal("C", [])

  public static func == (lhs: Text, rhs: Text) -> Bool {
    switch (lhs, rhs) {
    case let (.normal(a1, b1), .normal(a2, b2)):
      return a1 == a2 && b1 == b2
    }
  }
}

class RotHost: Rotatable {
  var result = [Text]()
  var rotator: Rotator!

  init() {
    rotator = Rotator(every: 1, delegate: self)
  }

  func rotator(didRotate text: Text) {
    result.append(text)
  }

  func stop() {
    rotator.stop()
  }

  func start() {
    rotator.start()
  }

  func set(_ items: [Text]) {
    try? rotator.set(text: items)
  }

  func deallocate() {
    rotator = nil
  }
}

class RotatorTests: QuickSpec {
  override func spec() {
    Nimble.AsyncDefaults.Timeout = 6
//    Nimble.AsyncDefaults.PollInterval = 0.1

    let text: [Text] = [.text1, .text2, .text3]
    describe("non empty list") {
      var host: RotHost!
      beforeEach {
        host = RotHost()
      }

      it("should handle a list of items") {
        host.set(text)
        expect(host.result).toEventually(cyclicSubset(of: text))
      }

      it("should stop updating") {
        host.set(text)
        host.stop()
        expect(host.result).toEventually(equal([.text1]))
      }

      it("should be able to resume") {
        host.set(text)
        host.stop()
        host.start()
        expect(host.result).toEventually(cyclicSubset(of: text))
      }

      it("does not rotate if deallocated") {
        host.set(text)
        host.deallocate()
        expect(host.result).toEventually(beEmpty())
      }

      it("restarts when reaching the end") {
        host.set(text)
        expect(host.result).toEventually(cyclicSubset(of: text + text))
      }

      it("does not rotate with one item") {
        host.set([.text1])
        waitUntil(timeout: 10) { done in
          Async.main(after: 5) {
            expect(host.result).to(cyclicSubset(of: [.text1]))
            done()
          }
        }
      }
    }
  }
}
