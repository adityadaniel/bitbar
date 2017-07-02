import Parser

extension Text {
  static let text1: Text = .normal("A", [])
  static let text2: Text = .normal("B", [])
  static let text3: Text = .normal("C", [])
}

class Tray: Trayable {
  var events: [Event] = []

  typealias Tail = Parser.Menu.Tail
  typealias Text = Plugin.Text

  static let `default` = Tray(title: "…", isVisible: false)

  required init(title: String, isVisible: Bool = true) {
    set(title: title)
    if !isVisible { hide() }
  }

  func set(_ tails: [Tail]) {
    events.append(.tail(tails))
  }

  func set(error: String) {
    events.append(.error([error]))
  }

  func set(errors: [String]) {
    events.append(.error(errors))
  }

  func set(title: String) {
    events.append(.title(title))
  }

  func set(title: Text) {
    switch title {
    case let .normal(string, _):
      events.append(.title(string))
    }
  }

  func show() {
    events.append(.show)
  }

  func hide() {
    events.append(.hide)
  }

  func set(errors: [MenuError]) {
    events.append(.menuError(errors))
  }

  enum Event: Equatable {
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
