import Quick
import Nimble
@testable import BitBar

class FilterTests: Helper {
  override func spec() {
    for n in (0...50) {
      describe("test \(n)") {
        describe("before") {
          it("should place bash before terminal and refresh") {
            let bash = Bash("X")
            let term = Terminal(false)
            let ref = Refresh(false)
            let trim = Trim(true)
            let menu = Menu("M", params: [ref, term, bash, trim].shuffle())
            expect(menu.sortedParams[0]).to(equal(bash))
            expect(menu.sortedParams).to(haveCount(4))
            expect(menu.sortedParams).to(contain(ref))
            expect(menu.sortedParams).to(contain(term))
          }

          it("should always place 'before all' in the begining") {
            let emoji = Emojize(true) /* Before all */
            let trim = Trim(true) /* Nop */
            let menu = Menu("M", params: [
              emoji, trim
            ].shuffle())
            expect(menu.sortedParams[0]).to(equal(emoji))
            expect(menu.sortedParams[1]).to(equal(trim))
            expect(menu.sortedParams).to(haveCount(2))
          }
        }

        describe("after") {
          it("should place ansi before trim") {
            let trim = Trim(false)
            let emoji = Emojize(false)
            let ansi = Ansi(true)
            let menu = Menu("M", params: [trim, ansi, emoji].shuffle())
            expect(menu.sortedParams[0]).to(equal(emoji))
            expect(menu.sortedParams[1]).to(equal(ansi))
            expect(menu.sortedParams[2]).to(equal(trim))
            expect(menu.sortedParams).to(haveCount(3))
          }

          it("should always place 'after all' in the end") {
            let length = Length(20) /* After all */
            let trim = Trim(true) /* Nop */
            let menu = Menu("M", params: [
              length, trim
            ].shuffle())
            expect(menu.sortedParams[0]).to(equal(trim))
            expect(menu.sortedParams[1]).to(equal(length))
            expect(menu.sortedParams).to(haveCount(2))
          }

          it("should place emoji before everything") {
            let emoji = Emojize(true) /* Before all */
            let ansi = Ansi(true) /* After Emojize */
            let trim = Trim(true) /* Nop */
            let term = Terminal(false) /* Nop */
            let ref = Refresh(false) /* Nop */
            let menu = Menu("M", params: [
              emoji, ansi, trim, term, ref
            ].shuffle())
            expect(menu.sortedParams[0]).to(equal(emoji))
            expect(menu.sortedParams[1]).to(equal(ansi))
            expect(menu.sortedParams).to(haveCount(5))
            expect(menu.sortedParams).to(contain(trim))
            expect(menu.sortedParams).to(contain(term))
            expect(menu.sortedParams).to(contain(ref))
          }

          it("should place length in the end") {
            let length = Length(10)
            let term = Terminal(false)
            let trim = Trim(false)
            let menu = Menu("M", params: [
              length, term, trim
            ].shuffle())
            expect(menu.sortedParams[0]).to(equal(term))
            expect(menu.sortedParams[1]).to(equal(trim))
            expect(menu.sortedParams[2]).to(equal(length))
            expect(menu.sortedParams).to(haveCount(3))
          }
        }
      }
    }
  }
}
