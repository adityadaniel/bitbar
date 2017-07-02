import ReSwift
import Sparkle
import SwiftyBeaver
import Plugin

let manager = Manager(trayer: Tray.self)
let log = SwiftyBeaver.self

struct AppState: StateType {
  var openOnLogin: Bool = false
}

extension Store {
  func dispatch(_ action: MenuEvent) {
    dispatch(action as Action)
  }
}

struct OpenAtStartup: Action {}
struct DoNotOpenAtLogin: Action {}

private func installCommandLineInterface() {
  MoveExecuteable().execute()
  notify(
    text: "CLI has been installed",
    subtext: "Access it using 'bitbar' in your terminal"
  )
}

func counterReducer(action: Action, state: AppState?) -> AppState {
  var state = state ?? AppState()

  guard let event = action as? MenuEvent else { return state }

  switch event {
  case .refreshAll:
    manager.refresh()
  case .checkForUpdates:
    SUUpdater.shared().checkForUpdates(manager)
  case .quitApplication:
    NSApp.terminate(manager)
  case .openWebsite:
    App.open(url: App.website)
  case .openOnLogin:
    App.startAtLogin(true)
    state.openOnLogin = true
  case .doNotOpenOnLogin:
    App.startAtLogin(false)
    state.openOnLogin = false
  case let .openUrlInBrowser(url):
    App.open(url: url)
  case .installCommandLineInterface:
    installCommandLineInterface()
  case .openPluginFolder:
    if let path = App.pluginPath {
      App.open(path: path)
    }
  case .changePluginPath:
    PathSelector(withURL: App.pluginURL).ask { url in
      App.update(pluginPath: url.path)
      try? manager.set(path: url.path)
    }
  case let .openPathInTerminal(path):
    App.openScript(inTerminal: path, args: []) { maybe in
      if let error = maybe {
        log.error("Could not open \(path) in terminal: \(error)")
      }
    }
  case let .openScriptInTerminal(script):
    App.openScript(inTerminal: script.path, args: script.args) { maybe in
      if let error = maybe {
        log.error("Could not open \(script.path) in terminal: \(error)")
      }
    }
  default:
     log.info("Ignored event in AppDelegate: \(event)")
  }

  return state
}

let mainStore = Store<AppState>(
  reducer: counterReducer,
  state: AppState()
)
