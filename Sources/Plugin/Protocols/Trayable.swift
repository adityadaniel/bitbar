import Parser

public protocol Trayable: class {
  init(title: String, isVisible: Bool)
  func set(_ tails: [Parser.Menu.Tail])
  func set(error: String)
  func set(errors: [String])
  func set(title: String)
  func set(title: Parser.Text)
  func set(errors: [MenuError])
  func has(child: Childable) -> Bool
  func show()
  func hide()
  func set(error: Bool)
}
