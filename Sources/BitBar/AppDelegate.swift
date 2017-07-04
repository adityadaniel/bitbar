import Cocoa
import Emojize
import Plugin
import API
import AppKit
import Async
import Sparkle
import SwiftyBeaver
import API

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  internal let log = SwiftyBeaver.self
  private var notificationCenter = NSWorkspace.shared().notificationCenter
  private var openPluginHandler: OpenPluginHandler?
  private var refreshPluginHandler: RefreshPluginHandler?
  private var server: Server?

  func applicationDidFinishLaunching(_: Notification) {
    if App.isInTestMode() { return }
    handleConfig()
    setEnvs()
    setOpenUrlHandler()
    setOnWakeUpHandler()
    handleStartupApp()
    handleServerStartup()
    loadPluginManager()
  }

  private func loadPluginManager() {
    guard let path = App.pluginPath else {
      return mainStore.dispatch(.changePluginPath)
    }

    do {
      try manager.set(path: path)
    } catch {
      log.error("Could not load plugin path: \(path): \(error)")
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
      openPluginHandler = OpenPluginHandler(queries)
      openPluginHandler?.execute()
    case .some("refreshPlugin"):
      refreshPluginHandler = RefreshPluginHandler(queries, manager: manager)
      refreshPluginHandler?.execute()
    case let other:
      log.error("\(String(describing: other)) is not a supported protocol")
    }
  }

  private func handleServerStartup() {
    do {
      server = try Server.start(port: App.port, manager: manager)
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

  private func handleStartupApp() {
    App.terminateHelperApp()
  }

  private func handleConfig() {
    do {
      try App.config.distribute()
    } catch {
      log.error("Could not distribute config file: \(error)")
    }
  }
}
