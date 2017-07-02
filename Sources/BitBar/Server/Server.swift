import Vapor
import Foundation
import SwiftyBeaver
import Plugin
import Async
import Plugin

private func ok(_ msg: String) throws -> JSON {
  return try JSON(node: ["message": msg])
}

// TODO: Move
extension Plugin: Parameterizable, JSONRepresentable {
 public func makeJSON() throws -> JSON {
   return try JSON(node: []) /* TODO <- */
 }

 public static var uniqueSlug: String {
   return "plugin"
 }

 public static func make(for name: String) throws -> Plugin {
   if let plugin = manager.findPlugin(byName: name) {
     return plugin
   }

   throw Abort.notFound
 }
}

func startServer() throws -> Droplet {
  var config = try Config()
  try config.set("server.port", App.port)
  let drop = try Droplet(config)
  let log = SwiftyBeaver.self
  log.addDestination(ConsoleDestination())

  drop.group("plugins") { group in
    // PATCH /plugins/refresh
    group.patch("refresh") { _ in
      manager.refresh()
      return try ok("Plugin(s) has beeen refreshed")
    }

    // GET /plugins
    group.get { _ in
      return try JSON(node: manager.names)
    }
  }

  // WS /log
  drop.socket("log") { _, ws in
    ws.setup()
  }

 drop.group("plugin", Plugin.parameter) { plugin in
   // GET /plugin/:plugin
   plugin.get { req in
     return try req.parameters.next(Plugin.self).makeJSON()
   }

   // PATCH /plugin/:plugin/hide
   plugin.patch("hide") { req in
     try req.parameters.next(Plugin.self).hide()
     return try ok("Plugin is now hidden")
   }

   // PATCH /plugin/:plugin/show
   plugin.patch("show") { req in
     try req.parameters.next(Plugin.self).show()
     return try ok("Plugin is now visible")
   }

   // PATCH /plugin/:plugin/refresh
   plugin.patch("refresh") { req in
     try req.parameters.next(Plugin.self).refresh()
     return try ok("Plugin is now refreshed")
   }

   // PATCH /plugin/:plugin/invoke/arg1/arg2
   plugin.patch("invoke", "*") { req in
     let plugin = try req.parameters.next(Plugin.self)
     let args = req.uri.path.split("invoke/").last!.split("/")
     plugin.invoke(args)
     return try ok("Plugin has been invoked with passed args")
   }
 }

  return drop.start()
}
