extension Param {
  static var cycleInterval: IntervalParam {
    return IntervalParam("cycle-interval")
  }

  static var name: StringParam {
    return StringParam("name")
  }

  static var cliPort: IntegerParam {
    return IntegerParam("cli-port")
  }

  static var fontSize: IntegerParam {
    return IntegerParam("font-size")
  }

  static var fontFamily: StringParam {
    return StringParam("font-family")
  }

  static var refreshOnWake: BoolParam {
    return BoolParam("refresh-on-wake")
  }

  static var cliEnabled: BoolParam {
    return BoolParam("cli-enabled")
  }

  static var enabled: BoolParam {
    return BoolParam("enabled")
  }

  static var args: ArrayParam {
    return ArrayParam("args")
  }

  static var ignoreFiles: ArrayParam {
    return ArrayParam("ignore-files")
  }

  static var env: DictParam {
    return DictParam("env")
  }
}
