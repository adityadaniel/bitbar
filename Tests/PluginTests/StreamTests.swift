import Quick
import Nimble
import Async
import PathKit
import SharedTests

@testable import Plugin

class StreamTests: QuickSpec {
  override func spec() {
    var plugin: SteamHost!
    var output: [SteamHost.Event]!

    describe("no arguments") {
      beforeEach {
        output = [.stdout("A\n"), .stdout("B\n")]
        plugin = SteamHost()
      }

      describe("start") {
        it("starts") {
          plugin.start()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply starts") {
          plugin.start()

          after(0.5) {
            plugin.start()
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          plugin.start()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("stop") {
        it("stops") {
          plugin.stop()
          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("does nothing on multiply stops") {
          after(0.5) {
            plugin.stop()
            plugin.stop()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("aborts when deallocated") {
          plugin.stop()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("invoke") {
        it("invokes") {
          plugin.invoke(["1", "2"])
          after(3) {
            expect(plugin.events).to(equal([.stdout("1\n"), .stdout("2\n")]))
          }
        }

        describe("restart") {
          it("does not persit arguments on restart") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.restart()
            }

            after(3) {
              expect(plugin.events).to(equal([.stdout("A\n"), .stdout("B\n")]))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.stop()
            }

            after(3) {
              expect(plugin.events).to(beEmpty())
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.start()
            }

            after(3) {
              expect(plugin.events).to(equal([.stdout("A\n"), .stdout("B\n")]))
            }
          }
        }
      }

      describe("restart") {
        it("restart") {
          plugin.restart()
          after(3) {
            expect(plugin.events).to(equal([.stdout("A\n"), .stdout("B\n")]))
          }
        }

        it("only reports once on multiply restarts") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal([.stdout("A\n"), .stdout("B\n")]))
          }
        }

        it("aborts when deallocated") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }
    }

    describe("arguments") {
      beforeEach {
        output = [.stdout("X\n"), .stdout("Y\n")]
        plugin = SteamHost(args: ["X", "Y"])
      }

      describe("start") {
        it("starts") {
          plugin.start()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply starts") {
          plugin.start()

          after(0.5) {
            plugin.start()
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          plugin.start()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("stop") {
        it("stops") {
          plugin.stop()
          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("does nothing on multiply stops") {
          after(0.5) {
            plugin.stop()
            plugin.stop()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("aborts when deallocated") {
          plugin.stop()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("invoke") {
        it("invokes") {
          plugin.invoke(["1", "2"])
          after(3) {
            expect(plugin.events).to(equal([.stdout("1\n"), .stdout("2\n")]))
          }
        }

        describe("restart") {
          it("does not persit arguments on restart") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.restart()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.stop()
            }

            after(3) {
              expect(plugin.events).to(beEmpty())
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.start()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }
      }

      describe("restart") {
        it("restart") {
          plugin.restart()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply restarts") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("aborts when deallocated") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }
    }

    describe("env") {
      beforeEach {
        output = [.stdout("P\n"), .stdout("Q\n")]
        plugin = SteamHost(env: ["ENV1": "P", "ENV2": "Q"])
      }

      describe("start") {
        it("starts") {
          plugin.start()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply starts") {
          plugin.start()

          after(0.5) {
            plugin.start()
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          plugin.start()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("stop") {
        it("stops") {
          plugin.stop()
          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("does nothing on multiply stops") {
          after(0.5) {
            plugin.stop()
            plugin.stop()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("aborts when deallocated") {
          plugin.stop()

          after(0.5) {
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("invoke") {
        it("invokes") {
          plugin.invoke(["1", "2"])
          after(3) {
            expect(plugin.events).to(equal([.stdout("1\n"), .stdout("2\n")]))
          }
        }

        describe("restart") {
          it("does not persit arguments on restart") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.restart()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.stop()
            }

            after(3) {
              expect(plugin.events).to(beEmpty())
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            plugin.invoke(["1", "2"])
            after(0.5) {
              plugin.start()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }
      }

      describe("restart") {
        it("restart") {
          plugin.restart()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply restarts") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("aborts when deallocated") {
          plugin.restart()

          after(0.5) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }
    }

    describe("error") {
      beforeEach {
        output = [.stdout("A\n"), .stdout("ERROR\n"), .stdout("B\n")]
        plugin = SteamHost(path: .streamError)
      }

      it("should output stderr and stdout") {
        after(3) {
          expect(plugin.events).to(contain(.stderr("ERROR")))
          expect(plugin.events).to(contain(.stdout("A\n")))
          expect(plugin.events).to(contain(.stdout("B\n")))
        }
      }
    }
  }
}
