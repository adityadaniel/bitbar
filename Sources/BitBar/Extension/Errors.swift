import Parser
import Script
import PathKit
import Plugin

enum MetadataError: Error {
  case unreadableFile(String)
}

extension MenuError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .duplicate(params):
      let list = params.map(String.init(describing:))
      return "Duplicate params: \(list.join(","))"
    case let .duplicateActions(a1, a2):
      return "Duplicate actions: a1=\(a1), a2=\(a2)"
    case let .invalidSubMenuDepth(t1, t2, level):
      return "Invalid submenus t1=\(t1), t2=\(t2), level=\(level)"
    case let .invalidMenuDepth(head, tail, level):
      return "Invalid submenus head=\(head), tail=\(tail), level=\(level)"
    case let .noParamsForSeparator(params):
      let list = params.map(String.init(describing:))
      return "No params for separator: \(list.join(","))"
    case let .noSubMenusForSeparator(tails):
      let list = tails.map(String.init(describing:))
      return "No submenu for separator: \(list.join(","))"
    case let .param(key, error):
      return "Invalid param \(key): \(error)"
    case let .parseError(error):
      return "Parse error: \(error)"
    case let .argumentsSetButNotBash(args):
      return "Argument \(args.join(",")) has been set, but not bash='...'"
    case let .eventsSetButNotBash(events):
      let list = events.map(String.init(describing:))
      return "Events \(list.join(",")) has been set, but not bash='...'"
    case let .argumentsAndEventsAreSetButNotBash(args, events):
      let eventsList = events.map(String.init(describing:))
      return "Events \(eventsList.join(",")) and args \(args.join(",")) has been set, but not bash='...'"
    }
  }
  
  // TODO: Remove
  func format(error: String) -> String {
    if error.trimmed().isEmpty { return "" }
    return ":\n\t" + error.trimmed().replace("\n", "\n\t\t")
  }
}

extension ValueError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .int(value):
      return "Expected a number but got \(value.inspected())"
    case let .float(value):
      return "Expected a float but got \(value.inspected())"
    case let .image(value):
      return "Expected an image but got \(value.inspected())"
    case let .base64OrHref(value):
      return "Expected base 64 or an href but got \(value.inspected())"
    case let .font(value):
      return "Expected a font but got \(value.inspected())"
    case let .color(value):
      return "Expected a color but got \(value.inspected())"
    }
  }
}

extension Script.Failure: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .syntaxError(message, code):
      return pre(code) + "Invalid syntax used in script" + format(error: message)
    case let .uncaughtSignal(message, code):
      return pre(code) + "Uncaught signal" + format(error: message)
    case let .genericMixed(stdout, stderr, code):
      return pre(code)
        + "Both stderr and stdout set"
        + format(error: stdout)
        + format(error: stderr)
    case let .generic(message, code):
      return pre(code) + "Failed running script" + format(error: message)
    case let .pathNotFound(message, code):
      return pre(code) +
        "Script or subscript not found, verify the file path" +
        format(error: message)
    case let .notExecutable(message, code):
      return pre(code) +
        "Script is not executable, did you run 'chmod +x script.sh' on it?" +
        format(error: message)
    case let .manualTermination(message, code):
      return pre(code) + "The script was manually terminated" + format(error: message)
    case let .withZeroExitCode(message):
      // TODO: Remove this
      return pre(0) + "Successfull request" + format(error: message)
    case let .withStdout(message, code):
      return pre(code) + "Got stdout and stderr" + format(error: message)
    case let .withFallback(.exit, code, stdout, stderr):
      return pre(code) +
        "Fallback error message on normal termination"
        + format(error: stdout)
        + format(error: stderr)
    case let .withFallback(.uncaughtSignal, code, stdout, stderr):
      return pre(code) +
        "Fallback error message on uncaught signal"
        + format(error: stdout)
        + format(error: stderr)
    }
  }
  
  private func format(error: String?) -> String {
    guard let anError = error else { return "" }
    return format(error: anError)
  }
  
  func format(error: String) -> String {
    if error.trimmed().isEmpty { return "" }
    return ":\n\t" + error.trimmed().replace("\n", "\n\t\t")
  }
  
  private func pre(_ exitCode: Int) -> String {
    return "(\(exitCode)) "
  }
}

extension PluginError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .noOutput:
      return pre(-1) + format(error: "No output provided by plugin")
    case let .output(stderr):
      return String(describing: stderr)
    }
  }
  
  func format(error: String) -> String {
    if error.trimmed().isEmpty { return "" }
    return ":\n\t" + error.trimmed().replace("\n", "\n\t\t")
  }
  
  private func pre(_ exitCode: Int) -> String {
    return "(\(exitCode)) "
  }
}

extension ManagerError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .pathDoesNotExist(path):
      return "Plugin path \(path) does not exist"
    case let .mustBeAFile(path):
      return "Must be a file: \(path)"
    }
  }
}

extension PathError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .notAFile(path):
      return "\(path) is not a path"
    }
  }
}

extension ClassifierError: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .invalidParts(path):
      return "File \(path.name ?? "") has an invalid name"
    }
  }
}
