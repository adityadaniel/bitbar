import Quick
import Nimble
import PathKit
import Config

@testable import Plugin

class PluginTests: QuickSpec {
  override func spec() {
    describe("plugin") {
      var manager: Manager!
      var folder: Path!
      var plugin: PluginFile!

      beforeEach {
        folder = Path.tmp
        manager = Manager(ConfigFile(home: folder))
        try? Path.plugin1.copy(folder + Path("plugin1.10s.sh"))
        try? Path.plugin1.copy(folder + Path("invalid"))
        manager.refresh()
        plugin = manager.findPlugin(byName: "plugin1.10s.sh")!
      }

      afterEach {
       try? folder.delete()
      }

      it("has a name") {
       expect(plugin.name).to(equal("plugin1.10s.sh"))
      }


      describe("show") {
        it("is now visible") {
          plugin.show()
        }
      }

      describe("hide") {
        it("is now hiden") {
          plugin.hide()
        }
      }

      describe("refresh") {
        it("is now refreshed") {
          plugin.refresh()
        }
      }

      describe("invoke") {
        it("invokes with arguments") {
          plugin.invoke(["1", "2", "3"])
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

