import PathKit

enum PluginError: Error {
  case noOutput
  case output(String)
}

enum ManagerError: Error {
  case pathDoesNotExist(String)
}

enum RotatorError: Error {
  case noOwner, emptySet
}

enum PathError: Error {
  case notAFile(Path)
}

enum ClassifierError: Error {
  case invalidParts(Path)
}
