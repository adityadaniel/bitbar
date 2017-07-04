import PathKit

public enum PluginError: Error {
  case noOutput
  case output(String)
}

public enum ManagerError: Error {
  case pathDoesNotExist(String)
  case mustBeAFile(Path)
}

public enum RotatorError: Error {
  case noOwner, emptySet
}

public enum PathError: Error {
  case notAFile(Path)
}

public enum ClassifierError: Error {
  case invalidParts(Path)
}
