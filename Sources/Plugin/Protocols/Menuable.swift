public protocol Menuable {
  func plugin(didBecomeHidden: Plugin)
  func plugin(didBecomeVisible: Plugin)
  func plugin(_ plugin: Plugin, didSetTitle: Text)
  func plugin(_ plugin: Plugin, didSetTitle: String)
  func plugin(_ plugin: Plugin, didSetErrors: [String])
}
