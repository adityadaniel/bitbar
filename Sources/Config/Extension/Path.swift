import PathKit

extension Path {
  public static let shipped = Path.resource(forFile: "bitbarrc.base.toml")!
  public static let blank = Path.resource(forFile: "bitbarrc.blank.toml")!

  public static func resource(forFile file: String) -> Path? {
    let filename = file as NSString
    let pathExtention = filename.pathExtension
    let pathPrefix = filename.deletingPathExtension
    let bundle =  Bundle(for: DistConfig.self)
    if let path = bundle.path(forResource: pathPrefix, ofType: pathExtention) {
      return Path(path)
    }

    puts("[Error] Could not find \(pathPrefix).\(pathExtention) <=> \(file) in resources")
    return nil
  }
}
