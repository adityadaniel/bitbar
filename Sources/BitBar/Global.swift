import Cocoa

func notify(text: String, subtext: String? = nil) {
  let alert = NSAlert()
  alert.messageText = text
  if let sub = subtext {
    alert.informativeText = sub
  }

  alert.display()
}

func bug(_ msg: String) -> Never {
  preconditionFailure("[Bug] " + msg)
}
