import SwiftCheck
@testable import BitBarParser

extension Text.Param: Arbable {
  typealias Param = Text.Param
  static let font_t = string.map(Param.font)
  static let size_t = float.suchThat { $0 > 0 }.map(Param.size)
  static let length_t = natural.map(Param.length)
  static let emojize_t = Gen.pure(Param.emojize)
  static let trim_t = Gen.pure(Param.trim)
  static let ansi_t = Gen.pure(Param.ansi)
  static let color_t = Color.arbitrary.map(Param.color)
  static let params = [font_t, size_t, length_t, emojize_t, trim_t, ansi_t, color_t]

  public static var arbitrary: Gen<Param> {
    return params.one()
  }

  public static func ==== (lhs: Text.Param, rhs: Text.Param) -> Property {
    switch (lhs, rhs) {
    case let (.font(f1), .font(f2)):
      return f1 ==== f2
    case let (.size(s1), .size(s2)):
      return s1 ==== s2
    case let (.length(l1), .length(l2)):
      return l1 ==== l2
    case (.emojize, .emojize):
      return true <?> "emojize"
    case (.trim, .trim):
      return true <?> "trim"
    case (.ansi, .ansi):
      return true <?> "ansi"
    case let (.color(c1), .color(c2)):
      return c1 ==== c2
    default:
      return false <?> "Text.Param: \(lhs) != \(rhs)"
    }
  }

  public var output: String {
    switch self {
    case .emojize:
      return "emojize=true"
    case .ansi:
      return "ansi=true"
    case .trim:
      return "trim=true"
    case let .font(name):
      return "font=\(name.quoted())"
    case let .size(value):
      return "size=\(value)"
    case let .length(value):
      return "length=\(value)"
    case let .color(color):
      return color.output
    }
  }
}

func ==== (params: [Raw.Param], action: Menu.Action) -> Property {
  switch action {
  case .nop:
    return params.all { param in
      switch param {
      case .bash:
        return false <?> "nop != bash"
      case .refresh:
        return false <?> "nop != refresh"
      case .href:
        return false <?> "nop != href"
      default:
        return true <?> "nop == null"
      }
    }
  case let .href(u1, refresh, terminal):
    return params.some { param in
      switch param {
      case let .href(u2):
        return u1 ==== u2
      case .refresh(refresh):
         return true <?> "href == refresh"
      case .terminal(terminal):
         return true <?> "href == terminal"
      case .bash:
        return false <?> "href != bash"
      case .refresh:
        return false <?> "href != refresh"
      default:
        return false <?> "nop == null"
      }
    }
  case .refresh:
    return params.some { param in
      switch param {
      case .href:
        return false <?> "href != refresh"
      case .bash:
        return false <?> "href != bash"
      case .refresh:
        return true <?> "href == refresh"
      default:
        return false <?>  "ok"
      }
    }
  case let .script(path, args, terminal, refresh):
    return params.reduce(args + [path, "refresh", "terminal"]) { acc, param in
      switch param {
      case .href:
        return acc
      case let .bash(path):
        return acc.filter { $0 != path }
      case .refresh(refresh):
        return acc.initial()
      case .terminal(terminal):
        return acc.initial()
      case let .argument(_, value):
        return acc.filter { $0 != value }
      default:
        return acc
      }
    }.count ==== (args + [path]).count

  }
}

func ==== (raw: Raw.Param, image: Image) -> Property {
  switch raw {
  case let .image(other):
    return other ==== image
  default:
    return false <?> "\(raw) is not an image)"
  }
}
