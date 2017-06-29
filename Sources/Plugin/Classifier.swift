import PathKit

class Classifier {
  weak var delegate: Manageable?
  private let path: Path
  private let args: [String]
  private let env: Env

  init(path: Path, args: [String], env: Env) {
    self.env = env
    self.args = args
    self.path = path
  }

  func plugin() throws -> Pluginable {
    switch try name() {
    case "stream":
      return stream()
    case let type:
      return interval(try Unit.parser(type))
    }
  }

  private func name() throws -> String {
    let parts = try path.fileName().split(".")
    guard parts.count == 3 else {
      throw ClassifierError.invalidParts(path)
    }
    return parts[1]
  }

  private func interval(_ frequency: Double) -> Pluginable {
    return Interval(
      path: path,
      frequency: Int(frequency),
      args: args,
      env: env,
      delegate: delegate
    )
  }

  private func stream() -> Pluginable {
    return Stream(
      path: path,
      args: args,
      env: env,
      delegate: delegate
    )
  }
}
