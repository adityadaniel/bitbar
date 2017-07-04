import PathKit
import Parser

class No {}

public extension Path {
  static let plugin1 = Path.resource(forFile: "all.10m.sh")!
  static let plugin = plugin1
  static let rotate = Path.resource(forFile: "rotate.interval.sh")!
  static let interval = Path.resource(forFile: "plugin.interval.sh")!
  static let stream = Path.resource(forFile: "plugin.stream.sh")!
  static let streamError = Path.resource(forFile: "error-stream.sh")!
  static let error = Path.resource(forFile: "error.sh")!
  static let plugin2 = Path.resource(forFile: "all.20m.sh")!
  static let example = Path.resource(forFile: "bitbarrc.example.toml")!
  static let test = Path.resource(forFile: "bitbarrc.test.toml")!
  static let invalid = Path.resource(forFile: "bitbarrc.invalid.toml")!

  static var tmp: Path {
    return try! .processUniqueTemporary()
  }

  public static func resource(forFile file: String) -> Path? {
    let filename = file as NSString
    let pathExtention = filename.pathExtension
    let pathPrefix = filename.deletingPathExtension
    let bundle =  Bundle(for: type(of: No()))
    if let path = bundle.path(forResource: pathPrefix, ofType: pathExtention) {
      return Path(path)
    }

    puts("[Error] Could not find \(file) in resources")
    return nil
  }
}
