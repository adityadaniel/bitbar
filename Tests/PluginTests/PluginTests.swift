import Quick
import Nimble
import Async
import PathKit
import Config

@testable import SharedTests
@testable import Plugin

class PluginTests: QuickSpec {
  override func spec() {
    describe("plugin") {
      var manager: Manager!
      var folder: Path!
      var plugin: PluginFile!
      var events: [Tray.Event]!

      beforeEach {
        folder = Path.tmp
        manager = Manager(Config(home: folder))
        try! manager.dump(.plugin, as: "plugin1.10s.sh")
        try! manager.dump(.plugin, as: "invalid")
        manager.refresh()
        plugin = manager.findPlugin(byName: "plugin1.10s.sh")!
        events = [
          .title("…"),
          .title("Hello")
        ]
      }

      afterEach {
        try? folder.delete()
      }

      it("has a name") {
        expect(plugin.name).to(equal("plugin1.10s.sh"))
      }

      describe("show") {
        it("visible by default") {
          after(3) {
            expect(plugin.tray.events).to(equal(events))
          }
        }
      }

      describe("hide") {
        it("is now hiden") {
          after(1) {
            plugin.hide()
          }

          after(3) {
            expect(plugin.tray.events).to(equal(events << .hide))
          }
        }
      }

      describe("refresh") {
        it("is now refreshed") {
          after(1) {
            plugin.refresh()
          }

          after(3) {
            expect(plugin.tray.events).to(equal(events))
          }
        }
      }

      describe("invoke") {
        it("invokes with arguments") {
          after(1) {
            plugin.invoke(["1"])
          }

          after(3) {
            expect(plugin.tray.events).to(equal(events << .title("1")))
          }
        }
      }

      describe("rotate") {
        beforeEach {
          let name = "rotate.10s.sh"
          manager = Manager(Config(home: .tmp))
          try! manager.dump(.rotate, as: name)
          manager.refresh()
          plugin = manager.findPlugin(byName: name)!
          events = [.title("…")]
        }

        it("it rotates between multiply arguments") {
          after(3) {
            expect(plugin.tray.events).to(
              beCyclicSubset(
                of: [.title("A"), .title("B")],
                from: 1
              )
            )
          }
        }

        it("it stops rotating on hide") {
          plugin.hide()
          after(3) {
            expect(plugin.tray.events).to(equal(events << .hide))
          }
        }

        it("it does nothing on show") {
          plugin.show()
          after(3) {
            expect(plugin.tray.events).to(beginWith(events << .show))

            expect(plugin.tray.events).to(
              beCyclicSubset(
                of: [.title("A"), .title("B")],
                from: 2
              )
            )
          }
        }

        it("it restarts loop in refresh") {
          after(1) {
            plugin.refresh()
          }

          after(3) {
            expect(plugin.tray.events).to(beginWith(events))
            expect(plugin.tray.events).to(
              beCyclicSubset(
                of: [.title("A"), .title("B")],
                from: 1
              )
            )
          }
        }
      }

      describe("error") {
        beforeEach {
          let name = "error.10s.sh"
          folder = Path.tmp
          try? Path.error.copy(folder + Path(name))
          manager = Manager(Config(home: folder))
          manager.refresh()
          plugin = manager.findPlugin(byName: name)!
          events = [.title("…")]
        }

        xit("should fail") {
          after(3) {
            expect(plugin.tray.events).to(equal(events << .error(["output(\"generic(Optional(\"\n\"))\")"])))
          }
        }
      }

      describe("didReceiveError") {
        it("handles error") {
          plugin.plugin(didReceiveError: "an error")
        }

        it("handles blank inout") {
          plugin.plugin(didReceiveError: "")
        }
      }

      describe("didReceiveOutput") {
        it("handles blank input") {
          plugin.plugin(didReceiveOutput: "")
        }

        it("handles success") {
          plugin.plugin(didReceiveOutput: "a message")
        }
      }
    }
  }
}
