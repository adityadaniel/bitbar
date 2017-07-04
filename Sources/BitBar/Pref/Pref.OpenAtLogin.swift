import ReSwift

extension Pref {
  class OpenAtLogin: MenuItem {
    required convenience init(openAtLogin ok: Bool) {
      self.init(title: "Open at Login", isChecked: ok, isClickable: true)
    }

    override func newState(state: AppState) {
      isChecked = state.openOnLogin
    }

    override func onDidClick() {
      mainStore.dispatch(.openOnLogin(!isChecked))
    }
  }
}
