extension Pref {
  class RunInTerminal: MenuItem {
    required convenience init() {
      self.init(title: "Run in Terminal…", shortcut: "o")
    }

    override func onDidClick() {
      mainStore.dispatch(.runInTerminal(self))
    }
  }
}
