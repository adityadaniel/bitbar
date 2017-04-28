extension Array {
  func has<T: Equatable>(_ el: [T]...) -> Bool {
    el.all { e1 in
      return self.some { e2 in e2 == e1 }
    }
  }

  func has<T: Equatable>(_ el: [T]) -> Bool {
    return has(el)
  }

  func not<T: Equatable>(_ el: T...) -> Bool {
    return !has(el)
  }
}

extension Array {
  // @example [1,2,3].all { $0 > 2 } // => true
  func some(block: (Element) -> Bool) -> Bool {
    return reduce(false) { acc, el in
      return acc || block(el)
    }
  }

  // @example [1,2,3].all { $0 > 0 } // => true
  public func all(block: (Element) -> Bool) -> Bool {
    if isEmpty { return true }
    return reduce(true) { acc, el in
      return acc && block(el)
    }
  }
}


enum Action: Equatable {
  case nop
  case refresh
  case script(String, [String], Bool, Bool)
  case href(String, Bool)
}

enum Color {
  case hex(String)
  case name(String)

  static func == (lhs: Color, rhs: Color) -> Bool {
    switch (lhs, rhs) {
    case let (.name(s1), .name(s2)):
      return s1 == s2
    case let (.hex(c1), .hex(c2)):
      return c1 == c2
    default:
      return false
    }
  }

  var param: Raw.Param {
    return .color(self)
  }
}

enum Image: Equatable {
  case base64(String, Bool)
  case href(String, Bool)

  static func == (lhs: Image, rhs: Image) -> Bool {
    switch (lhs, rhs) {
    case let (.base64(b1, s1), .base64(b2, s2)):
      return b1 == b2 && s1 == s2
    case let (.href(h1, s1), .href(h2, s2)):
      return h1 == h2 && s1 == s2
    default:
      return false
    }
  }

  var param: Raw.Param {
    return .image(self)
  }
}

enum Raw {
  case head(String, [Param], [Raw])
  case tail(String, [Param], Int)


  static func == (raw: Raw, menu: Menu) -> Bool {
    switch (raw, menu) {
    case let (.head, _):
      return false
    case (.tail("-", [], _), .separator):
      return true
    case (_, .separator):
      return false
    case let (.tail(title, p1, _), .text(text, p2, _, action)):
      return text.title == title && p1 == p2 && p1.some { $0 == action }
    case let (.tail(_, p1, _), .image(image, p2, _, action)):
      return p1.some { $0 == image } && p1 == p2  && p1.some { $0 == action }
    case let (_, .error(messages)):
      preconditionFailure("Got errors: \(messages)")
    }
  }

  enum Param: Equatable {
    case bash(String) // => Action.script(Script(.bash, .argument))
    case trim(Bool) // Just trim
    case dropdown(Bool) // Remove all menus
    case href(String) // Head: Fail, can't have href, Tail: Action.href(.href)
    case image(Image) // Head: Fail, cant have image, Tail: Tail.image(image)
    case font(String) // Head/Tail.text.add(.font)
    case size(Float) // Head/Tail.text.add(.size)
    case terminal(Bool) // Head: Fail, can't have it, Tail: Add to Action.script, if not, fail
    case refresh(Bool) // Head: fail, Tail: Add to .href or .action
    case length(Int) // Add to Head/Tail.text.add(.length)
    case alternate(Bool) // Head: fail, Tail: Tail.params.add(.alternate)
    case emojize(Bool) // Head/T.text.add(.emojize)
    case ansi(Bool) // H/T.text.add(.ansi)
    case color(Color) // H/T.text.add(color)
    case checked(Bool) // Head: fail, Tail.params.add(.checked)
    case argument(Int, String) // Head: fail, Tail: add to Action.script
    case error(String, String, String) // Head/Tail: replace with warning symbol, add error to submenu
    static func == (raw: Raw.Param, image: Image) -> Bool {
      return raw == .image(image)
    }

    public static func == (lhs: Raw.Param, rhs: Raw.Param) -> Bool {
      switch (lhs, rhs) {
      case let (.font(f1), .font(f2)):
        return f1 == f2
      case let (.size(s1), .size(s2)):
        return s1 == s2
      case let (.length(l1), .length(l2)):
        return l1 == l2
      case let (.emojize(e1), .emojize(e2)):
        return e1 == e2
      case let (.trim(t1), .trim(t2)):
        return t1 == t2
      case let (.ansi(a1), .ansi(a2)):
        return a1 == a2
      case let (.color(c1), .color(c2)):
        return c1 == c2
      case let (.bash(b1), .bash(b2)):
        return b1 == b2
      case let (.dropdown(d1), .dropdown(d2)):
        return d1 == d2
      case let (.href(h1), .href(h2)):
        return h1 == h2
      case let (.image(i1), .image(i2)):
        return i1 == i2
      case let (.terminal(t1), .terminal(t2)):
        return t1 == t2
      case let (.refresh(r1), .refresh(r2)):
        return r1 == r2
      case let (.alternate(a1), .alternate(a2)):
        return a1 == a2
      case let (.checked(c1), .checked(c2)):
        return c1 == c2
      case let (.argument(i1, a1), .argument(i2, a2)):
        return i1 == i2 && a1 == a2
      case let (.error(e11, e12, e13), .error(e21, e22, e23)):
        return e11 == e21 && e12 == e22 && e13 == e23
      default:
        return false
      }
    }

    static func == (p1: Raw.Param, p2: Menu.Param) -> Bool {
      switch (p1, p2) {
      case (.checked(true), .checked):
        return true
      case (.alternate(true), .alternate):
        return true
      default:
        return false
      }
    }

    static func == (lhs: Text.Param, rhs: Raw.Param) -> Bool {
      switch (lhs, rhs) {
      case (.trim, .trim(true)):
        return true
      case (.ansi, .ansi(true)):
        return true
      case (.emojize, .emojize(true)):
        return true
      case let (.font(f1), .font(f2)):
        return f1 == f2
      case let (.size(s1), .size(s2)):
        return s1 == s2
      case let (.length(l1), .length(l2)):
        return l1 == l2
      case let (.color(c1), .color(c2)):
        return c1 == c2
      default:
        return false
      }
    }
  }
}

enum Text {
  enum Param {
    case font(String)
    case length(Int)
    case color(Color)
    case size(Float)
    case emojize
    case ansi
    case trim
  }

  case normal(String, [Param])
}

enum Bar {
  case text(Text, [Menu])
  case error([String])

  static func == (bar: Bar, raw: Raw) -> Bool {
    switch (bar, raw) {
    case let (.text(text, m1), .head(title, params, m2)):
      return text.title == title
        && m1 == m2
        && params == text.params
    case (_, .tail):
      return false
    case (.error(messages), _):
      precondition("can't compare error with raw")
    }
  }
}

enum Menu {
  case text(Text, [Param], [Menu], Action)
  case image(Image, [Param], [Menu], Action)
  case separator
  case error([Error])

  enum Param {
    case alternate
    case checked
  }
}

func == (p1: [Raw.Param], p2: [Menu.Param]) -> Bool {
  let s1 = p2.all { param2 in
    return p1.some { param1 in
      param2 == param1
    }
  }

  let s2 = p1.all { param1 in
    return p2.some { param2 in
      return param1 == param2
    }
  }

  return s1 && s2
}


func == (p1: Raw.Param, p2: Text.Param) -> Bool {
  switch (p1, p2) {
  case (.trim, .trim(true)):
    return true
  case (.ansi, .ansi(true)):
    return true
  case (.emojize, .emojize(true)):
    return true
  case let (.font(f1), .font(f2)):
    return f1 == f2
  case let (.size(s1), size(s2)):
    return s1 == s2
  case let (.length(l1), .length(l2)):
    return l1 == l2
  case let (.color(c1), .color(c2)):
    return c1 == c2
  default:
    return false
  }
}

func == (p1: [Raw.Param], p2: [Text.Param]) -> Bool {
  let s1 = p2.all { param2 in
    return p1.all { param1 in
      return param2 == param1
    }
  }

  let s2 = p1.all { param1 in
    return p2.all { param2 in
      return param2 == param1
    }
  }

  return s1 && s2
}

func == (raw: Raw, text: Text) -> Bool {
  switch (raw, text) {
  case let (.head(t1, p1, _), .normal(t2, p2)):
    return t1 == t2 && p1 == p2
  case let (.tail(t1, p1, _), .normal(t2, p2)):
    return t1 == t2 && p1 == p2
  }

  return state ^&&^ raw.title == rhs.title
}

func == (params: [Raw.Param], action: Action) -> Bool {
  switch action {
  case let .script(path, args, terminal, refresh):
    let all = [.bash(path)] + args.enumerated().map { .argument($0.0, $0.1) }
    let s1 = params.has(all)
    let s2 = params.all {
      switch $0 {
      case .refresh:
        return refresh
      case .terminal:
        return terminal
      case .href:
        return false
      default:
        return true
      }
    }

    return s1 && s2
  case let .href(url, refresh):
    let s1 = params.has(.href(url), .refresh))
    let s2 = params.all {
      switch $0 {
      case .terminal:
        return false
      case .bash:
        return false
      case .argument:
        return false
      default:
        return true
      }
    }

    return s1 && s2
  }
}

func == (raw: Raw, menu: Menu) -> Bool {
  switch (raw, menu) {
  case let (.head, _):
    return false
  case let (.tail("-", params, index), .separator):
    return params.isEmpty && index >= 0
  case (_, .separator):
    return false
  case let (.tail(title, p1, index), .text(text, p2, _, action)) where index >= 0:
    return text == title && p1 == p2 && p1 == action
  case let (.tail(_, p1, _), .image(image, p2, _, action)):
    return p1.has(image.param) && p1 == p2 && p1 == action
  case let (_, .error(messages)):
    preconditionFailure("Got errors: \(messages)")
  }
}

func == (text: Text, title: String) -> Bool {
  switch text {
  case .normal(text, _):
    return true
  case .error(text):
    return true
  default:
    return false
  }
}

func == (params: [Raw.Param], image: Image) -> Bool {
  return params.has(.image(image))
}
