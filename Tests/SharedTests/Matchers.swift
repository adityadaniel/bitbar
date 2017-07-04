import Nimble
import Dollar
import Cent
import Foundation

public func cyclicSubset<T: Equatable>(of cycle: [T]) -> Predicate<[T]> {
  return Predicate { (actual: Expression<[T]>) throws -> PredicateResult in
    let msg = ExpectationMessage.expectedActualValueTo("be cyclic")
    if let list = try actual.evaluate() {
      if list.isEmpty { return PredicateResult(bool: false, message: msg) }
      for (index, value) in cycle.enumerated() {
        switch (value, list.get(index: index % list.count)) {
        case let (that, .some(this)) where that == this:
          continue
        default:
          return PredicateResult(status: .fail, message: msg)
        }
      }

      return PredicateResult(bool: true, message: msg)
    }

    return PredicateResult(status: .fail, message: msg)
  }
}

public func beginWith<T: Equatable>(_ array: [T]) -> Predicate<[T]> {
  return Predicate { (actual: Expression<[T]>) throws -> PredicateResult in
    let msg = ExpectationMessage.expectedActualValueTo("begin with")
    let failed = PredicateResult(status: .fail, message: msg)

    guard let list = try actual.evaluate() else {
      return failed
    }

    if list.count < array.count {
      return failed
    }

    for (index, value) in array.enumerated() {
      if value != list[index] {
        return failed
      }
    }

    return PredicateResult(bool: true, message: msg)
  }
}

public func beCyclicSubset<T: Equatable>(of cycle: [T], from: Int = 0) -> Predicate<[T]> {
  return Predicate { (actual: Expression<[T]>) throws -> PredicateResult in
    let msg = ExpectationMessage.expectedActualValueTo("be cyclic")
    let failed = PredicateResult(status: .fail, message: msg)

    guard let list = try actual.evaluate() else {
      return failed
    }

    if (list.count - from) <= 0 {
      return failed
    }

    for (index, value) in list.enumerated() where index >= from {
      if value != cycle[(index - from) % cycle.count] {
        return failed
      }
    }

    return PredicateResult(bool: true, message: msg)
  }
}
