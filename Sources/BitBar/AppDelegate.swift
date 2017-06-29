import Cocoa
import Files
import Emojize
import AppKit
import Async
import Sparkle
import Vapor
import SwiftyBeaver

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, Parent {
  internal let queue = AppDelegate.newQueue(label: "AppDelegate")
  internal weak var root: Parent?
  internal let log = SwiftyBeaver.self
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  internal let manager = PluginManager.instance
  private let updater = SUUpdater.shared()
  private var server: Droplet?
  private var openPluginHandler: OpenPluginHandler?
  private var refreshPluginHandler: RefreshPluginHandler?
  private let installCLI = MoveExecuteable()
  private var pathSelector: PathSelector?

  func applicationDidFinishLaunching(_: Notification) {
    if App.isInTestMode() { return }
    manager.root = self
    handleConfigFile()
    setEnvs()
    setOpenUrlHandler()
    setOnWakeUpHandler()
    handleStartupApp()
    loadPluginManager()
    handleServerStartup()
}

  func on(_ event: MenuEvent) {
    switch event {
    case .refreshAll: manager.refresh()
    case .openWebsite: App.open(url: App.website)
    case .openOnLogin: App.startAtLogin(true)
    case .doNotOpenOnLogin: App.startAtLogin(false)
    case let .openUrlInBrowser(url): App.open(url: url)
    case .quitApplication: NSApp.terminate(self)
    case .checkForUpdates: updater?.checkForUpdates(self)
    case .installCommandLineInterface: installCommandLineInterface()
    case .openPluginFolder:
      if let path = App.pluginPath {
        App.open(path: path)
      }
    case .changePluginPath: askAboutPluginPath()
    case let .openPathInTerminal(path):
      open(script: path)
    case let .openScriptInTerminal(script):
      open(script: script.path, args: script.args)
    default:
      log.info("Ignored event in AppDelegate: \(event)")
    }
  }

  private func loadPluginManager() {
    if let path = App.pluginPath {
      return manager.set(path: path)
    }

    askAboutPluginPath()
  }

  private func askAboutPluginPath() {
    pathSelector = PathSelector(withURL: App.pluginURL)
    pathSelector?.ask { [weak self] url in
      guard let this = self else { return }
      App.update(pluginPath: url.path)
      this.loadPluginManager()
    }
  }

  @objc private func onDidWake() {
    manager.refresh()
  }

  private func setOnWakeUpHandler() {
    notificationCenter.addObserver(
      self,
      selector: #selector(onDidWake),
      name: .NSWorkspaceDidWake,
      object: nil
    )
  }

  private func setOpenUrlHandler() {
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleEvent(event:replyEvent:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
  }

  @objc func handleEvent(event: NSAppleEventDescriptor!, replyEvent: NSAppleEventDescriptor) {
    guard let desc = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
      return log.error("Could not read descriptor from bitbar://")
    }

    guard let string = desc.stringValue else {
      return log.error("Could not read url string from bitbar://")
    }

    guard let components = NSURLComponents(string: string) else {
      return log.error("Could not get components from url \(string)")
    }

    guard let params = components.queryItems else {
      return log.error("Could not read params from url ")
    }

    var queries = [String: String]()
    for param in params {
      queries[param.name] = param.value
    }

    switch components.host {
    case .some("openPlugin"):
      openPluginHandler = OpenPluginHandler(queries, parent: self)
      openPluginHandler?.execute()
    case .some("refreshPlugin"):
      refreshPluginHandler = RefreshPluginHandler(queries, manager: manager)
      refreshPluginHandler?.execute()
    case let other:
      log.error("\(String(describing: other)) is not a supported protocol")
    }
  }

  private func open(script path: String, args: [String] = []) {
    App.openScript(inTerminal: path, args: args) { [weak self] maybe in
      if let error = maybe {
        self?.log.error("Could not open \(path) in terminal: \(error)")
      }
    }
  }

  private func handleServerStartup() {
    do {
      server = try startServer()
    } catch {
      log.error("Could not start server: \(error)")
    }
  }

 private func setEnvs() {
   if UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" {
     setenv("BitBarDarkMode", "1", 1)
   }

   setenv("BitBar", "1", 1)
 }

  private func installCommandLineInterface() {
    installCLI.execute()
    notify(
      text: "CLI has been installed",
      subtext: "Access it using 'bitbar' in your terminal"
    )
  }

  private func handleStartupApp() {
    App.terminateHelperApp()
  }

  private func handleConfigFile() {
    do {
      try App.config.distribute()
    } catch {
      log.error("Could not distribute config file: \(error)")
    }
  }
}
