import JSON
import Plugin

extension Plugin: JSONRepresentable {
  public func makeJSON() throws -> JSON {
    return try JSON(node: ["name": name])
  }
}
