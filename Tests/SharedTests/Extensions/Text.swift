import Parser

public typealias Text = Parser.Text

public extension Text {
  static let text1: Text = .normal("A", [])
  static let text2: Text = .normal("B", [])
  static let text3: Text = .normal("C", [])
}
