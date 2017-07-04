import FootlessParser
typealias P<T> = Parser<Character, T>

final class IntervalParam: Param<String, Double> {
  override func transform(_ value: String) throws -> Double {
    return try FootlessParser.parse(IntervalParam.parser, value)
  }

  private static func toTime(value: (Double, String)) -> P<Double> {
    let (double, unit) = value
    switch unit {
    case "s":
      return pure(double)
    case "m":
      return pure(double * 60.0)
    case "h":
      return pure(double * 60.0 * 60.0)
    case "d":
      return pure(double * 24.0 * 60.0 * 60.0)
    default:
      return stop("Invalid unit \(unit)")
    }
  }

  private static var digits: P<Double> {
    return oneOrMore(digit) >>- { digit in
      guard let double = Double(digit) else {
        return stop("Could not read \(digit) as double")
      }

      return pure(double)
    }
  }

  private static var unit: P<String> {
    return count(1, oneOf("smhd"))
  }

  private static var parser: P<Double> {
    return curry({ ($0, $1) }) <^> digits <*> unit >>- toTime
  }

  private static func stop <A, B>(_ message: String) -> Parser<A, B> {
    return Parser { parsedtokens in
      throw ParseError.Mismatch(parsedtokens, message, "<stop>")
    }
  }
}
