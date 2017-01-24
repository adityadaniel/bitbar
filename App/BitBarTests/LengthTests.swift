import Quick
import Nimble
@testable import BitBar

class LengthTests: Helper {
  override func spec() {
    context("base case") {
      it("handels base case") {
        let menu = Menu("hello")
        let length = Length(1)
        length.applyTo(menu: menu)
        expect(menu.title).to(equal("h…"))
      }
    }

    context("parser") {
      let parser = Pro.getLength()

      it("handles positive value") {
        self.match(parser, "length=10") {
          expect($0.getValue()).to(equal(10))
        }
      }

      it("handles leading zeros") {
        self.match(parser, "length=05") {
          expect($0.getValue()).to(equal(5))
        }
      }

      context("invalid values") {
        it("fails on negative values") {
          self.failure(parser, "length=-2")
        }

        it("fails on no value") {
          self.failure(parser, "length=")
        }

        it("fails on floats") {
          self.failure(parser, "length=10.0")
        }
      }
  }
  }
}
