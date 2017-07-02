import Quick
import Nimble
import Toml
@testable import Config

class ConfigTests: QuickSpec {
  override func spec() {
    var config: Config = try! Config.using(template: .test)

    describe("config") {
      afterEach {
        try? config.cleanup()
      }

      let load = { (plugin: String) -> Plugin in
        config = try! Config.using(template: .test)
        return config.findPlugin(byName: plugin)
      }

      describe("global") {
        describe("cliEnabled") {
          it("should be enabled") {
            expect(config.cliEnabled).to(equal(true))
          }
        }

        describe("cliPort") {
          it("should have a default value") {
            expect(config.cliPort).to(equal(1234))
          }
        }

        describe("ignoreFiles") {
          it("should have a default value") {
            expect(config.ignoreFiles).to(equal([".*", ".git"]))
          }
        }

        describe("refresh-on-wake") {
          it("should have a default value") {
            expect(config.refreshOnWake).to(beTrue())
          }
        }

        describe("find plugin by name") {
          describe("non existing plugin") {
            let plugin = config.findPlugin(byName: "<?>")

            it("has not name") {
              expect(plugin.name).to(beNil())
            }

            it("defaults to global values") {
              expect(plugin.cycleInterval).to(equal(10))
            }
          }

          it("locates existing plugin") {
            expect(config.findPlugin(byName: "uptime.plugin.sh").name).to(equal("uptime.plugin.sh"))
          }
        }
      }

      describe("empty config file") {
        beforeEach {
          config = try! Config.using(template: .blank)
        }

        describe("global") {
          it("uses global preset") {
            expect(config.cliPort).to(equal(9111))
          }
        }

        describe("plugin") {
          it("uses global preset") {
            expect(config.findPlugin(byName: "do-no-exists").cycleInterval).to(equal(10))
          }
        }
      }

      describe("invalid config file") {

        it("throws an error when reading") {
          expect { try Config.using(template: .invalid) }
            .to(throwError(errorType: TomlError.self))
        }

        describe("global") {
          it("uses global preset") {
            expect(config.cliPort).to(equal(9111))
          }
        }

        describe("plugin") {
          it("uses global preset") {
            expect(config.findPlugin(byName: "do-no-exists").cycleInterval).to(equal(10))
          }
        }
      }

      describe("useDefault") {
        beforeEach {
          config = try! Config.using(template: .test)
          config.useDefault()
        }

        describe("global") {
          it("overrides current in memory config with defaults") {
            expect(config.cliPort).to(equal(9111))
          }
        }

        describe("plugin") {
          it("uses global preset") {
            expect(config.findPlugin(byName: "do-no-exists").cycleInterval).to(equal(10))
          }
        }
      }

      describe("enabled") {
        it("should be disabled") {
          expect(load("disabled.plugin.sh").isEnabled).to(equal(false))
        }

        it("is enabled by default") {
          expect(load("default.plugin.sh").isEnabled).to(equal(true))
        }

        it("should be enabled") {
          expect(load("enabled.plugin.sh").isEnabled).to(equal(true))
        }
      }

      describe("plugins") {
        let plugin = load("uptime.plugin.sh")
        describe("name") {
          it("should have a name") {
            expect(plugin.name).to(equal("uptime.plugin.sh"))
          }
        }

        describe("font family") {
          it("should have a font family") {
            expect(plugin.fontFamily).to(equal("Mono"))
          }

          it("should default to nil") {
            expect(load("no-font.sh").fontFamily).to(beNil())
          }
        }

        describe("font size") {
          it("should have a font size") {
            expect(plugin.fontSize).to(equal(10))
          }

          it("should default to nil") {
            expect(load("no-font.sh").fontSize).to(beNil())
          }
        }
      }

      describe("cycle interval") {
        it("should fallback to global config") {
          expect(load("cycleInterval.fallback.sh").cycleInterval).to(equal(10))
        }

        it("should override global interval") {
          expect(load("cycleInterval.plugin.sh").cycleInterval).to(equal(600))
        }

        it("should handle seconds") {
          expect(load("ci-sec.plugin.sh").cycleInterval).to(equal(10))
        }

        it("should handle minutes") {
          expect(load("ci-min.plugin.sh").cycleInterval).to(equal(600))
        }

        it("should handle hours") {
          expect(load("ci-hours.plugin.sh").cycleInterval).to(equal(36000))
        }

        it("should handle days") {
          expect(load("ci-days.plugin.sh").cycleInterval).to(equal(864000))
        }

        it("should fall back to the default value on invalid data") {
          expect(load("ci-invalid.plugin.sh").cycleInterval).to(equal(10))
        }
      }

      describe("env") {
        it("overrides global envs") {
          let env = ["env1": "value1", "env2": "value2", "env3": "global"]
          expect(load("env.plugin.sh").env).to(equal(env))
        }

        it("should merge env with parent") {
          let env = ["env1": "value1", "env3": "global", "env2": "value2"]
          expect(load("uptime.plugin.sh").env).to(equal(env))
        }
      }

      describe("args") {
        it("overrides global state") {
          let args = ["arg1", "arg2", "arg3"]
          expect(load("uptime.plugin.sh").args).to(equal(args))
        }

        it("should merge env with parent") {
          let args = ["global1", "global2"]
          expect(load("env.plugin.sh").args).to(equal(args))
        }
      }
    }
  }
}
