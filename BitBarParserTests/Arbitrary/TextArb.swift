import SwiftCheck
@testable import BitBarParser

extension Text: Arbitrary {
  public static var arbitrary: Gen<Text> {
    return Gen.compose { gen in
      return Text(
        title: gen.generate(using: string),
        params: gen.generate(using: Text.Param.params.shuffle())
      )
    }
  }

  public var output: String {
    if params.isEmpty { return title.titled() }
    return title.titled() + "| "
      + params.map { $0.output }.joined(separator: " ")
  }

  public static func ==== (lhs: Text, rhs: Text) -> Property {
    return lhs.title ==== rhs.title
      ^&&^ lhs.params ==== rhs.params
  }

  public static func ==== (lhs: Text, rhs: Raw.Head) -> Property {
    let state = lhs.params.all { p1 in
      return rhs.params.some { p2 in p2 ==== p1 }
    }
    return state ^&&^ lhs.title ==== rhs.title
  }
}

func ==== (text: Text, raw: Raw.Tail) -> Property {
  return text.title ==== raw.title
    ^&&^ raw.params ==== text.params
}

func ==== (text: [Raw.Param], raw: [Text.Param]) -> Property {
  return false <?> "OKOKOK"
}

func ==== (lhs: Text.Param, rhs: Raw.Param) -> Property {
  switch (lhs, rhs) {
  case (.trim, .trim(true)):
    return true <?> "trim"
  case (.ansi, .ansi(true)):
    return true <?> "ansi"
  case (.emojize, .emojize(true)):
    return true <?> "emojize"
  case let (.font(f1), .font(f2)):
    return (f1 ==== f2) <?> "font"
  case let (.size(s1), .size(s2)):
    return (s1 ==== s2) <?> "size"
  case let (.length(l1), .length(l2)):
    return (l1 ==== l2) <?> "length"
  case let (.color(c1), .color(c2)):
    return (c1 ==== c2) <?> "color"
  default:
    return false <?> "no a match: \(lhs) vs \(rhs)"
  }
}

func ==== (lhs: Menu.Action, rhs: Raw.Param) -> Property {
  return false <?> "no"
}

func ==== (lhs: Image, rhs: Raw.Param) -> Property {
  return false <?> "no"
}

func ==== (lhs: Raw.Param, rhs: Text.Param) -> Property {
  return rhs ==== lhs
}
