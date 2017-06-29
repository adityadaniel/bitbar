import Parser

class Tray {
  init(title: String, isVisible: Bool = true) {}
  func set(_ tails: [Parser.Menu.Tail]) {}
  func set(error: String) {}
  func set(errors: [String]) {}
  func set(title: String) {}
  func set(title: Plugin.Text) {}
  func show() {}
  func hide() {}
}
