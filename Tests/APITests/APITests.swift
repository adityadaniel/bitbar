import Quick
import Just
import Async
import Vapor
import Config
import Nimble
import PathKit

@testable import API
@testable import SharedTests
@testable import Plugin

class APITests: QuickSpec {
  override func spec() {
    var droplet: Server!
    var manager: Manager!
    var port: Int!
    var folder: Path!

    func get<T>(_ path: String) -> T? {
      return Just.get("http://127.0.0.1:\(port!)/\(path)").json as? T
    }

    func patch(_ path: String) -> HTTPResult {
      return Just.patch("http://127.0.0.1:\(port!)/\(path)")
    }

    beforeSuite {
      folder = .tmp
      port =  Int(arc4random_uniform(90)) + 9000
      try? Path.stream.copy(folder + Path("plugin.stream.sh"))
      manager = Manager(Config(home: folder), trayer: Tray.self)
      manager.refresh()
      droplet = try? Server.start(port: port, manager: manager)
    }

    afterSuite {
      try? folder.delete()
    }

    it("has plugins") {
      expect(get("plugins")).to(equal(["plugin.stream.sh"]))
    }

    it("has a plugin") {
      expect(get("plugin/plugin.stream.sh")).to(equal(["name": "plugin.stream.sh"]))
    }

    describe("plugin") {
      var plugin: PluginFile!
      var tray: Tray!

      beforeEach {
        plugin = manager.findPlugin(byName: "plugin.stream.sh")!
        tray = plugin.tray as! Tray
        tray.events = []
      }

      it("hides plugin") {
        expect(patch("plugin/plugin.stream.sh/hide")).to(respond(with: .nothing))
        expect(tray.events).to(equal([.hide]))
      }

      it("displays plugin") {
        expect(patch("plugin/plugin.stream.sh/show")).to(respond(with: .nothing))
        expect(tray.events).to(equal([.show]))
      }

      it("refreshes plugin") {
        after(3) {
          expect(patch("plugin/plugin.stream.sh/refresh")).to(respond(with: .nothing))
        }

        after(5) {
          expect(tray.events).to(equal([
            .title("A"), .title("B"),
            .title("A"), .title("B")
            ]))
        }
      }

      it("invokes plugin") {
        after(3) {
          expect(patch("plugin/plugin.stream.sh/invoke/X/Y")).to(respond(with: .nothing))
        }

        after(6) {
          expect(tray.events).to(equal([
            .title("X"), .title("Y")
            ]))
        }
      }
    }
  }
}
