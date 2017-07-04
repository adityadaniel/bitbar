import Vapor
import Plugin

class Builder {
  let manager: Manager
  let builder: RouteBuilder
  let res = Response(status: .ok, headers: ["Content-Type": "text/plain"])

  init(_ manager: Manager, _ builder: RouteBuilder) {
    self.manager = manager
    self.builder = builder
  }

  func getPlugin(from request: Request) throws -> Plugin {
    let name = try request.parameters.next(String.self)
    guard let plugin = manager.findPlugin(byName: name) else {
      throw Abort.notFound
    }

    return plugin
  }

  func get(_ param: String, block: @escaping (Plugin) throws -> Void) {
    builder.get(param) { request in
      try block(try self.getPlugin(from: request))
      return self.res
    }
  }

  func get(block: @escaping (Plugin) throws -> Void) {
    builder.get { request in
      try block(try self.getPlugin(from: request))
      return self.res
    }
  }

  func get(block: @escaping (Plugin) throws -> [String]) {
    builder.get { request in
      return try JSON(node: try block(try self.getPlugin(from: request)))
    }
  }

  func get<T: ResponseRepresentable>(block: @escaping () throws -> T) {
    builder.get { _ in
      return try block()
    }
  }

  func get<T: JSONRepresentable>(block: @escaping (Plugin) throws -> T) {
    builder.get { request in
      return try block(try self.getPlugin(from: request)).makeJSON()
    }
  }

  func get(block: @escaping () throws -> [String]) {
    builder.get { _ in
      return try JSON(node: try block())
    }
  }

  func patch(_ param: String, block: @escaping (Plugin) throws -> Void) {
    builder.patch(param) { request in
      try block(try self.getPlugin(from: request))
      return self.res
    }
  }

  func patch(_ param: String, _ more: String, block: @escaping (Plugin, Request) throws -> Void) {
    builder.patch(param, more) { request in
      try block(try self.getPlugin(from: request), request)
      return self.res
    }
  }

  func patch(_ param: String, block: @escaping () throws -> Void) {
    builder.patch(param) { _ in
      try block()
      return self.res
    }
  }

  func post(_ param: String, block: @escaping (Plugin) throws -> Void) {
    builder.post(param) { request in
      try block(try self.getPlugin(from: request))
      return self.res
    }
  }
}
