import Quick
import Nimble
import Config

@testable import Plugin
@testable import PathKit

extension Path {
  static let plugin1 = Path.resource(forFile: "all.10m.sh")!
  static let plugin2 = Path.resource(forFile: "all.20m.sh")!
}

class ManagerTests: QuickSpec {
  override func spec() {
    var manager: Manager!
    describe("files") {
      describe("empty folder") {
        beforeEach {
          manager = Manager(ConfigFile(home: .tmp))
        }

        afterEach {
          // try? config.cleanup()
        }

        it("should not have any files") {
          expect(manager.files).to(beEmpty())
        }

        it("empty after refresh") {
          manager.refresh()
          expect(manager.files).to(beEmpty())
        }

        it("should have non when set(path) is used") {
          let other: Path = .tmp
          try! manager.set(path: other.path)
          expect(manager.files).to(beEmpty())
        }
      }
    }

    describe("non empty folder") {
      var manager: Manager!
      var folder: Path!

      beforeEach {
        folder = Path.tmp
        manager = Manager(ConfigFile(home: folder))
        try? Path.plugin1.copy(folder + Path("plugin1.10s.sh"))
        try? Path.plugin1.copy(folder + Path("invalid"))
        manager.refresh()
      }

      afterEach {
       try? folder.delete()
      }

      it("loads all files") {
        expect(manager.files).to(haveCount(2))
      }

      describe("plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "plugin1.10s.sh")!
        }

        it("has a name") {
         expect(plugin.name).to(equal("plugin1.10s.sh"))
        }
      }
    }
  }
}
