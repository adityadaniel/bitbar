import Quick
import Nimble

@testable import Plugin

class StreamTests: QuickSpec {
  override func spec() {
    var plugin: StreamPlugin!

    beforeEach {
      plugin = Stream(path: .plugin1, args: [], env: [:], delegate: nil)
    }

    describe("start") {
      it("starts") {
        plugin.start()
      }
    }

    describe("stop") {
      it("stops") {
        plugin.stop()
      }
    }

    describe("invoke") {
      it("invokes") {
        plugin.invoke(["A", "B"])
      }
    }

    describe("refresh") {
      it("refreshes") {
        plugin.refresh()
      }
    }
  }
}
