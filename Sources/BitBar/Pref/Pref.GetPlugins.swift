extension Pref {
  class GetPlugins: MenuItem {
    required convenience init() {
      self.init(title: "Get Plugins…", isClickable: true)
    }

    override func onDidClick() {
      mainStore.dispatch(.openWebsite)
    }
  }
}
