import Quick
import Nimble
@testable import Plugin

class UnitItemTests: QuickSpec {
  override func spec() {
    describe("seconds") {
      it("handles value") {
        expect { try Unit.parser("10s") }.to(equal(10))
      }

      it("fails on invalid input") {
        expect { try Unit.parser("1xs") }.to(throwError())
      }
    }
  }
}
