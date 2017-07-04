import Parser
import ReSwift
import Plugin

enum MenuEvent: ReSwift.Action, Hashable {
  case refreshAll
  case quitApplication
  case openPluginFolder
  case openWebsite
  case changePluginPath
  case checkForUpdates
  case installCommandLineInterface
  case refreshPlugin(Childable)
  case openOnLogin(Bool)
  case openUrlInBrowser(String)
  case runInTerminal(Childable)
  case openPathInTerminal(String)
  case openScriptInTerminal(Parser.Action.Script)
  case didSetError(MenuItem)

  public var hashValue: Int {
    return String(describing: self).hashValue
  }

  public static func == (lhs: MenuEvent, rhs: MenuEvent) -> Bool {
    return String(describing: lhs) == String(describing: rhs)
  }
}
