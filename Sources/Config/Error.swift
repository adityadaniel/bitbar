import PathKit

enum DistConfigError: Error {
  case destExist(Path)
}

enum ConfigError: Error {
  case noBaseConfigFound
  case unreadableBaseConfig(Error)
  case couldNotInitConfig(Error, String)
  case couldNotParseUserConfig(String, String)
  case userConfigNotFound(Error, String)
  case unreadableUserConfig(Error, String)
  case notConvertable
  case globalSectionNotFound
  case dirAsConfig
}

enum ParamError: Error {
  case invalidTransform
}
