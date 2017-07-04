import Nimble
import Just

func respond(with type: ResponseType) -> Predicate<HTTPResult> {
  return Predicate.simple("return \(type)") { actual in
    return PredicateStatus(bool: try actual.evaluate()?.text?.isEmpty ?? true)
  }
}
