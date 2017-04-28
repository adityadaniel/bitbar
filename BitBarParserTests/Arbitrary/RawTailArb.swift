import SwiftCheck
@testable import BitBarParser

extension Raw.Tail: Arbable {
  typealias Tail = Raw.Tail
  typealias Param = Raw.Param

  public static var arbitrary: Gen<Tail> {
    return Gen.compose { gen in
      return Tail(
        level: gen.generate(using: Int.arbitrary.suchThat { $0 >= 0}),
        title: gen.generate(using: string),
        params: gen.generate(using: Param.params.shuffle())
      )
    }
  }

  private static func from(level: Int, gen: GenComposer) -> Tail {
    return Tail(
      level: level,
      title: gen.generate(using: string),
      params: gen.generate(using: Param.params.shuffle())
    )
  }

  static func sequence(gen: GenComposer) -> Gen<[Tail]> {
    let data = (0...5).reduce((curr: 0, tails: [Tail]())) { state, _ in
      let up: Bool = gen.generate()
      if up || state.curr == 0 {
        return (
          curr: state.curr + 1,
          tails: state.tails + [from(level: state.curr, gen: gen)]
        )
      }

      return (
        curr: state.curr - 1,
        tails: state.tails + [from(level: state.curr, gen: gen)]
      )
    }.tails

    return Gen.pure(data)
  }

  public static func ==== (lhs: Tail, rhs: Tail) -> Property {
    return lhs.title ==== rhs.title
      ^&&^ lhs.params ==== rhs.params
      ^&&^ lhs.level ==== rhs.level
  }

  static func ==== (tail: Menu.Tail, raw: Raw.Tail) -> Property {
    switch tail {
    case let .text(text, params, _, action):
      return text ==== raw
        ^&&^ params ==== raw.params
        ^&&^ raw.params ==== action
    case let .image(image, params, _, action):
      return raw.params.some { image ==== $0 }
        ^&&^ raw.params ==== action
        ^&&^ params ==== raw.params
    case let .error(errors):
      preconditionFailure("Found errors: \(errors)")
    case .separator:
      return raw.title ==== "-"
        ^&&^ raw.params.count ==== 0
    }
  }

  var output: String {
    if params.isEmpty {
      return indent + title.titled() + "\n"
    }

    return indent + title.titled() + "| " + params
      .map { $0.output }.joined(separator: " ") + "\n"
  }

  private var indent: String {
    return (0..<level).map { _ in "--" }.joined()
  }
}

func ==== (lhs: [Raw.Tail], rhs: [Menu.Tail]) -> Property {
  return lhs.some { raw in has(raw, rhs) }
}

func ==== (lhs: Raw.Tail, rhs: Menu.Tail) -> Property {
  return true <?> "OKO"
}

func ==== (lhs: [Menu.Param], rhs: [Raw.Param]) -> Property {
  return true <?> "OKO"
}

func has(_ m1: Raw.Tail, _ menus: [Menu.Tail]) -> Property {
  return menus.some { m2 in
    switch m2 {
    case let .text(_, _, menus, _):
      return m1 ==== m2 ^||^ has(m1, menus)
    case let .image(_, _, menus, _):
      return m1 ==== m2 ^||^ has(m1, menus)
    default:
      return m1 ==== m2
    }
  }
}
