import Parser

class Tray: Trayable {
  func has(child: Childable) -> Bool {
    return false
  }

  func set(error: Bool) {
    // TODO FIX
    events.append(.error(["bool error"]))
  }

  var events: [Event] = []

  typealias Tail = Parser.Menu.Tail
  typealias Text = Plugin.Text

  static let `default` = Tray(title: "…", isVisible: false)

  required public init(title: String, isVisible: Bool = true) {
    set(title: title)
    if !isVisible { hide() }
  }

  func set(_ tails: [Tail]) {
    events.append(.tail(tails))
  }

  public func set(error: String) {
    events.append(.error([error]))
  }

  public func set(errors: [String]) {
    events.append(.error(errors))
  }

  public func set(title: String) {
    events.append(.title(title))
  }

  public func set(title: Text) {
    switch title {
    case let .normal(string, _):
      events.append(.title(string))
    }
  }

  public func show() {
    events.append(.show)
  }

  public func hide() {
    events.append(.hide)
  }

  public func set(errors: [MenuError]) {
    events.append(.menuError(errors))
  }

  public enum Event: Equatable {
    case show
    case hide
    case title(String)
    case error([String])
    case menuError([MenuError])
    case tail([Tail])

    public static func == (lhs: Event, rhs: Event) -> Bool {
      switch (lhs, rhs) {
      case (.show, show):
        return true
      case (.hide, .hide):
        return true
      case let (.title(t1), .title(t2)):
        return t1 == t2
      case let (.tail(t1), .tail(t2)):
        return t1 == t2
      default:
        return false
      }
    }
  }

  enum Title: Equatable {
    case string(String)
    case text(Text)
    case error([String])

    public static func == (lhs: Title, rhs: Title) -> Bool {
      switch (lhs, rhs) {
      case let (.string(s1), .string(s2)):
        return s1 == s2
      case let (.text(t1), .text(t2)):
        return t1 == t2
      case let (.error(e1), .error(e2)):
        return e1 == e2
      default:
        return false
      }
    }
  }
}
