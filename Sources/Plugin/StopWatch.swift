import SwiftyTimer

class StopWatch: Base {
  enum Event: String {
    case stop, start
  }

  private let queue = DispatchQueue(label: "StopWatch", qos: .userInteractive, target: .main)
  private var timer: Timer?
  private let interval: Double
  private var fired: Timer?
  private weak var delegate: Timeable?

  init(every time: Int, delegate: Timeable, start autostart: Bool = true) {
    self.interval = Double(time)
    super.init()
    self.delegate = delegate
    if autostart { start() }
  }

  internal var id: Int {
    return ObjectIdentifier(timer ?? self).hashValue
  }

  public var isActive: Bool {
    return timer?.isValid ?? false
  }

  private func newTimer() -> Timer {
    return Timer.new(every: interval, onTick)
  }

  func fire(then event: Event) {
    queue.async { [weak self] in
      guard let this = self else { return }

      this.onTick()

      switch (event, this.isActive) {
      case (.start, true):
        this.log.info("Already started")
      case (.start, false):
        this.unsafeStart()
      case (.stop, false):
        this.log.info("Already stopped")
      case (.stop, true):
        this.unsafeStop()
      }
    }
  }

  func restart() {
    log.verbose("Restart timer")
    stop()
    start()
  }

  func stop() {
    queue.async { [weak self] in
      self?.unsafeStop()
    }
  }

  private func unsafeStop() {
    queue.async { [weak self] in
      self?.both()
    }
  }

  private func invalidate(_ timer: Timer?) {
    guard let aTimer = timer else { return }
    guard aTimer.isValid else { return }
    aTimer.invalidate()
  }

  func start() {
    queue.async { [weak self] in
      self?.unsafeStart()
    }
  }

  private func unsafeStart() {
    queue.async { [weak self] in
      guard let this = self else { return }
      if this.isActive { return this.log.info("Already active") }
      this.log.verbose("Start timer")

      this.both()

      this.timer = this.newTimer()
      this.timer?.start(modes: .defaultRunLoopMode, .eventTrackingRunLoopMode)
    }
  }

  private func both() {
    invalidate(timer)
    invalidate(fired)
  }

  private func onTick() {
    if let receiver = delegate {
      return receiver.timer(didTick: self)
    }

    stop()
  }
}
