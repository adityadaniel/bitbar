import Foundation

protocol GUI: class {
  var queue: DispatchQueue { get }
  func perform(block: @escaping () -> Void)
}
