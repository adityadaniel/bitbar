import PathKit
import Foundation
import SwiftyBeaver

class MoveExecuteable {
  private let log = SwiftyBeaver.self
  private let cliPath = Path("/usr/local/bin")
  private let cliFile: Path

  init() {
    cliFile = cliPath + Path("bitbar")
  }

  func execute() {
    tryRemovingExistingBinary()
    tryCopyingBinaryToDestPath()
  }

  private func tryRemovingExistingBinary() {
    try? cliFile.delete()
  }

  private func tryCopyingBinaryToDestPath() {
    guard let cliURL = Bundle.main.url(forAuxiliaryExecutable: "CLI") else {
      return log.error("Could not find embedded executable")
    }

    do {
      try Path(cliURL).copy(cliFile)
    } catch {
      log.error("Could not copy \(cliURL.absoluteString) to \(cliFile.dir): \(error)")
    }
  }
}
