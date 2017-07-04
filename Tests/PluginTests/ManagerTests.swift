import Quick
import Nimble
import PathKit
import Async
import Config

@testable import Plugin
@testable import SharedTests

class ManagerTests: QuickSpec {
  override func spec() {
    var manager: Manager!
    var events: [Tray.Event]!

    describe("files") {
      describe("empty folder") {
        beforeEach {
          manager = Manager(Config(home: .tmp))
          events = [.title("BitBar"), .hide]
        }

        it("should not have any files") {
          expect(manager.files).toEventually(beEmpty())
          expect(manager.tray.events).toEventually(equal(events))
        }

        it("empty after refresh") {
          manager.refresh()
          expect(manager.tray.events).toEventually(equal(events << .show))
          expect(manager.files).toEventually(beEmpty())
        }

        it("should have non when set(path) is used") {
          let other: Path = .tmp
          try! manager.set(path: other.dir)
          expect(manager.files).toEventually(beEmpty())
          expect(manager.tray.events).toEventually(equal(events << .show))
        }
      }
    }

    describe("non empty folder") {
      var manager: Manager!
      var folder: Path!

      beforeEach {
        folder = Path.tmp
        manager = Manager(Config(home: folder))
        try! manager.dump(.streamError, as: "error.stream.sh")
        try! manager.dump(.interval, as: "plugin.3s.sh")
        try! manager.dump(.stream, as: "plugin.stream.sh")
        manager.refresh()
        events = [.title("BitBar"), .hide]
      }

      afterEach {
        try? folder.delete()
      }

      it("loads all files") {
        after(5) {
          expect(manager.files).to(haveCount(3))
          expect(manager.tray.events).to(equal(events << .hide))
        }
      }

      describe("stream plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "plugin.stream.sh")!
        }

        it("has a name") {
          expect(plugin.name).to(equal("plugin.stream.sh"))
//          expect(plugin).to(beAnInstanceOf(StreamPlugin.self))
        }
      }

      describe("interval plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "plugin.3s.sh")!
        }

        it("has a name") {
          expect(plugin.name).to(equal("plugin.3s.sh"))
//          expect(plugin).to(beAnInstanceOf(IntervalPlugin.self))
        }
      }

      describe("invalid plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "error.stream.sh")!
        }

        it("has a name") {
          expect(plugin.name).to(equal("error.stream.sh"))
//          expect(plugin).to(beAnInstanceOf(StreamPlugin.self))
        }
      }

      describe("file changes") {
        var folder: Path!

        beforeEach {
          folder = .tmp
          manager = Manager(Config(home: folder))
        }

        it("ignores dot files") {
          try! manager.dump(.stream, as: "example.stream.sh")
          try! manager.dump(.stream, as: ".plugin.stream.sh")
          events = [.title("BitBar"), .hide]
          manager.refresh()

          after(2) {
            expect(manager.plugins).to(haveCount(1))
            expect(manager.plugins[0].name).to(equal("example.stream.sh"))
          }
        }

        it("ignores invalid file names") {
          try! manager.dump(.stream, as: "stream.sh")
          try! manager.dump(.stream, as: "sh")
          try! manager.dump(.stream, as: "10m.sh")
          events = [.title("BitBar"), .hide]
          manager.refresh()

          after(3) {
            expect(manager.plugins).to(haveCount(0))
          }
        }

        it("handles empty folder") {
          manager.refresh()
          expect(manager.plugins).to(haveCount(0))
        }

        it("handles deleted files") {
          let plugin = try! manager.dump(.plugin)
          manager.refresh()
          try! plugin.delete()
          manager.refresh()
          expect(manager.plugins).to(beEmpty())
        }

        it("handles added files") {
          let plugin1 = try! manager.dump(.plugin)
          manager.refresh()
          expect(manager.plugins).to(haveCount(1))
          let plugin2 = try! manager.dump(.stream)
          manager.refresh()
          expect(manager.plugins).to(haveCount(2))
        }
      }
    }
  }
}
