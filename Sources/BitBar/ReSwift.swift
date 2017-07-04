import ReSwift
import Sparkle
import SwiftyBeaver
import Plugin

let manager = Manager(trayer: Tray.self)
let log = SwiftyBeaver.self

struct AppState: StateType {
  var openOnLogin = App.autostart
}

extension Store {
  func dispatch(_ action: MenuEvent) {
    dispatch(action as Action)
  }
}

private func installCommandLineInterface() {
  MoveExecuteable().execute()
  notify(
    text: "CLI has been installed",
    subtext: "Access it using 'bitbar' in your terminal"
  )
}

var events = [MenuEvent]()

func counterReducer(action: Action, state: AppState?) -> AppState {
  var state = state ?? AppState()

  guard let event = action as? MenuEvent else { return state }

  if App.isInTestMode() {
    events.append(event)
  }

  switch event {
  case let .didSetError(item):
    item.set(error: true)
    if let plugin = manager.plugin(from: item) {
      plugin.set(error: true)
    } else {
      log.error("No plugin found")
    }
  case let .runInTerminal(item):
    if let script = manager.script(from: item) {
      App.open(script: script)
    } else {
      log.error("No script found")
    }
  case let .refreshPlugin(item):
    if let plugin = manager.plugin(from: item) {
      plugin.refresh()
    } else {
      log.error("No script found")
    }
  case .refreshAll:
    manager.refresh()
  case .checkForUpdates:
    if !App.isInTestMode() {
      SUUpdater.shared().checkForUpdates(manager)
    }
  case .quitApplication:
    if !App.isInTestMode() {
      NSApp.terminate(manager)
    }
  case .openWebsite:
    if !App.isInTestMode() {
      App.open(url: App.website)
    }
  case let .openOnLogin(pending):
    App.startAtLogin(pending)
    state.openOnLogin = pending
  case let .openUrlInBrowser(url):
    if !App.isInTestMode() {
      App.open(url: url)
    }
  case .installCommandLineInterface:
    installCommandLineInterface()
  case .openPluginFolder:
    if !App.isInTestMode() {
      if let path = App.pluginPath {
        App.open(path: path)
      }
    }
  case .changePluginPath:
    if !App.isInTestMode() {
      PathSelector(withURL: App.pluginURL).ask { url in
        App.update(pluginPath: url.path)
        try? manager.set(path: url.path)
      }
    }
  case let .openPathInTerminal(path):
    App.open(script: path)
  case let .openScriptInTerminal(script):
    App.open(script: script)
  }

  return state
}

let mainStore = Store<AppState>(
  reducer: counterReducer,
  state: AppState()
)
