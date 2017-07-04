extension Pref {
  class InstallCommandLineInterface: MenuItem {
    required convenience  init() {
      self.init(title: "Install CLI", isClickable: true)
    }

    override func onDidClick() {
      mainStore.dispatch(.installCommandLineInterface)
    }
  }
}
