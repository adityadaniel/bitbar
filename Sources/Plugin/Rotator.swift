import Parser

final class Rotator: Timeable {
  private typealias Text = Parser.Text
  private var text = [Text]()
  private weak var delegate: Rotatable?
  private var timer: StopWatch!
  private var currentIndex = 0

  init(every interval: Int, delegate: Rotatable) {
    self.delegate = delegate
    self.timer = StopWatch(every: interval, delegate: self)
  }

  internal func timer(didTick timer: StopWatch) {
    guard let owner = delegate else { return timer.stop() }
    if text.isEmpty { return timer.stop() }
    update(owner: owner, to: currentIndex % text.count)
    currentIndex = (currentIndex + 1) % text.count
  }

  public func set(text: [Parser.Text]) throws {
    guard text.isPresent else { throw RotatorError.emptySet }
    guard delegate != nil else { return stop() }
    self.text = text
    if text.count == 1 { timer.fire(then: .stop) }
    else { timer.fire(then: .start) }
  }

  public func stop() {
    currentIndex = 0
    timer.stop()
  }

  public func start() {
    currentIndex = 0
    timer.start()
  }

  private func update(owner: Rotatable, to index: Int) {
    owner.rotator(didRotate: text[index])
  }
}