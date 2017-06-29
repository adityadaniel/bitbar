import Parser

protocol Rotatable: class {
  func rotator(didRotate: Parser.Text)
}
