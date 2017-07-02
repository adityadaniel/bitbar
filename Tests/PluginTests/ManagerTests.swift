import Quick
import Nimble
import Async
import Config

@testable import Plugin
@testable import PathKit

extension Path {
  static let plugin1 = Path.resource(forFile: "all.10m.sh")!
  static let rotate = Path.resource(forFile: "rotate.interval.sh")!
  static let interval = Path.resource(forFile: "plugin.interval.sh")!
  static let stream = Path.resource(forFile: "plugin.stream.sh")!
  static let streamError = Path.resource(forFile: "error-stream.sh")!
  static let error = Path.resource(forFile: "error.sh")!
  static let plugin2 = Path.resource(forFile: "all.20m.sh")!
}

extension Trayable {
  var events: [Tray.Event] {
    guard let tray = self as? Tray else { return [] }
    return tray.events
  }
}

func << <T>(lhs: [T], rhs: T) -> [T] {
  return lhs + [rhs]
}

class ManagerTests: QuickSpec {
  override func spec() {
    let after = { (time: Double, block: @escaping () -> Void) in
      waitUntil(timeout: time + 20) { done in
        Async.main(after: time) {
          block()
          done()
        }
      }
    }
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
          try! manager.set(path: other.path)
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
        try? Path.stream.copy(folder + Path("plugin.stream.sh"))
        try? Path.interval.copy(folder + Path("plugin.3s.sh"))
        try? Path.streamError.copy(folder + Path("error.stream.sh"))
        events = [.title("BitBar"), .hide]
        manager.refresh()
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
        }
      }

      describe("interval plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "plugin.3s.sh")!
        }

        it("has a name") {
          expect(plugin.name).to(equal("plugin.3s.sh"))
        }
      }

      describe("invalid plugin") {
        var plugin: PluginFile!

        beforeEach {
          plugin = manager.findPlugin(byName: "error.stream.sh")!
        }

        it("has a name") {
          expect(plugin.name).to(equal("error.stream.sh"))
        }
      }
    }
  }
}
