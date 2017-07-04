import Vapor
import Foundation
import SwiftyBeaver
import Plugin
import HTTP
import Routing
import Async
import Plugin

public class Server {
  private let port: Int
  let drop: Droplet
  let log = SwiftyBeaver.self
  let manager: Manager

  init(port: Int, manager: Manager, block: (Server) -> Void) throws {
    self.port = port
    self.manager = manager
    var config = try Config(arguments: ["serve"])
    try config.set("server.port", port)
    drop = try Droplet(config)
    block(self)
    start()
  }

  func group(_ name: String, _ type: Plugin.Type, block: @escaping (Builder) -> Void) {
    drop.group(name, String.parameter) { group in
      block(Builder(manager, group))
    }
  }

  func group(_ name: String, block: @escaping (Builder) -> Void) {
    drop.group(name) { group in
      block(Builder(manager, group))
    }
  }

  func socket(_ name: String, block: @escaping (WebSocket) -> Void) {
    drop.socket(name) { _, ws in
      block(ws)
    }
  }

  func start() {
    Async.utility { [weak self] in
      return {
        do {
          try self?.drop.run()
        } catch {
          self?.log.error("Could not start server: \(error)")
        }
      }()
    }
  }

  public static func start(port: Int, manager: Manager) throws -> Server {
    return try Server(port: port, manager: manager) { server in
      server.group("plugins") { group in
        // PATCH /plugins/refresh
        group.patch("refresh") {
          manager.refresh()
        }

        // GET /plugins
        group.get {
          return manager.names
        }
      }

      // WS /log
      server.socket("log") { ws in
        ws.setup()
      }

      server.group("plugin", Plugin.self) { group in
        // GET /plugin/:plugin
        group.get { plugin in
          return plugin
        }

        // PATCH /plugin/:plugin/hide
        group.patch("hide") { plugin in
          plugin.hide()
        }

        // PATCH /plugin/:plugin/show
        group.patch("show") { plugin in
          plugin.show()
        }

        // PATCH /plugin/:plugin/refresh
        group.patch("refresh") { plugin in
          plugin.refresh()
        }

        // PATCH /plugin/:plugin/invoke/arg1/arg2
        group.patch("invoke", "*") { plugin, request in
          plugin.invoke(request.uri.path.split("invoke/").last!.split("/"))
        }
      }
    }
  }
}
