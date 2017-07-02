import ReSwift

extension Pref {
  class OpenAtLogin: MenuItem {
    required convenience init(openAtLogin: Bool) {
      self.init(title: "Open at Login", isChecked: openAtLogin, isClickable: true)
    }

    override func newState(state: AppState) {
      isChecked = state.openOnLogin
    }

    override func onDidClick() {
      isChecked = !isChecked
      if isChecked {
        mainStore.dispatch(.doNotOpenOnLogin)
      } else {
        mainStore.dispatch(.openOnLogin)
      }
    }
  }
}
