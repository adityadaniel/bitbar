import Quick
import Nimble
import Async
import PathKit

@testable import Plugin
@testable import SharedTests

class IntervalTests: QuickSpec {
  override func spec() {
    var plugin: IntervalHost!
    var output: [IntervalHost.Event]!

    describe("no arguments") {
      beforeEach {
        output = [.stdout("A\nB\n")]
        plugin = IntervalHost()
      }

      describe("start") {
        it("starts") {
          plugin.start()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply starts") {
          after(2) {
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          plugin.deallocate()

          after(2) {
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
          plugin.stop()
          plugin.stop()

          after(2) {
            expect(plugin.events).to(beEmpty())
          }
        }

        it("aborts when deallocated") {
          plugin.stop()
          plugin.deallocate()

          after(2) {
            expect(plugin.events).to(beEmpty())
          }
        }
      }

      describe("invoke") {
        it("invokes") {
          after(2) {
            plugin.invoke(["1", "2"])
          }

          after(4) {
            expect(plugin.events).to(equal([
              .stdout("A\nB\n"),
              .stdout("1\n2\n")
              ]))
          }
        }

        describe("restart") {
          it("does persit arguments on restart") {
            after(1) {
              plugin.invoke(["1", "2"])
            }

            after(3) {
              plugin.restart()
            }

            after(4) {
              expect(plugin.events).to(equal([
                .stdout("A\nB\n"),
                .stdout("1\n2\n"),
                .stdout("1\n2\n")
                ]))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            after(1) {
              plugin.invoke(["1", "2"])
            }

            after(3) {
              plugin.stop()
            }

            after(4) {
              expect(plugin.events).to(equal([
                .stdout("A\nB\n"),
                .stdout("1\n2\n")
                ]))
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            after(1) {
              plugin.invoke(["1", "2"])
            }

            after(2) {
              plugin.start()
            }

            after(4) {
              expect(plugin.events).to(equal([
                .stdout("A\nB\n"),
                .stdout("1\n2\n"),
                .stdout("1\n2\n")
                ]))
            }
          }
        }
      }

      describe("restart") {
        it("restart") {
          plugin.restart()
          after(3) {
            expect(plugin.events).to(equal([.stdout("A\nB\n")]))
          }
        }

        it("only reports once on multiply restarts") {
          after(1) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal([.stdout("A\nB\n"), .stdout("A\nB\n")]))
          }
        }

        it("aborts when deallocated") {
          after(1) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(equal([.stdout("A\nB\n")]))
          }
        }
      }
    }

    describe("arguments") {
      beforeEach {
        output = [.stdout("X\nY\n")]
        plugin = IntervalHost(args: ["X", "Y"])
      }

      describe("start") {
        it("starts") {
          plugin.start()
          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }

        it("only reports once on multiply starts") {
          after(2) {
            plugin.start()
            plugin.start()
          }

          after(4) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          after(1) {
            plugin.start()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
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
          after(1) {
            plugin.stop()
            plugin.stop()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
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
            expect(plugin.events).to(equal([.stdout("1\n2\n")]))
          }
        }

        describe("restart") {
          it("does not persit arguments on restart") {
            after(1) {
              plugin.invoke(["1", "2"])
            }

            after(2) {
              plugin.restart()
            }

            after(4) {
              expect(plugin.events).to(equal(output + [.stdout("1\n2\n"), .stdout("1\n2\n")]))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            after(1) {
              plugin.invoke(["1", "2"])
              plugin.stop()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            after(1) {
              plugin.invoke(["1", "2"])
              plugin.start()
            }

            after(3) {
              expect(plugin.events).to(equal(output + [.stdout("1\n2\n")]))
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
          after(1) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("aborts when deallocated") {
          after(1) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }
      }
    }

    describe("env") {
      beforeEach {
        output = [.stdout("P\nQ\n")]
        plugin = IntervalHost(env: ["ENV1": "P", "ENV2": "Q"])
      }

      describe("start") {
        it("starts") {
          after(1) {
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("only reports once on multiply starts") {
          after(1) {
            plugin.start()
            plugin.start()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("does autostart") {
          expect(plugin.events).toEventually(equal(output))
        }

        it("aborts when deallocated") {
          after(1) {
            plugin.start()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
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
          after(1) {
            plugin.stop()
            plugin.stop()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
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
          after(1) {
            plugin.invoke(["1", "2"])
          }

          after(3) {
            expect(plugin.events).to(equal(output + [.stdout("1\n2\n")]))
          }
        }

        describe("restart") {
          it("does not persit arguments on restart") {
            after(1) {
              plugin.invoke(["1", "2"])
              plugin.restart()
            }

            after(3) {
              expect(plugin.events).to(equal(output + [.stdout("1\n2\n")]))
            }
          }
        }

        describe("stop") {
          it("aborts on stop") {
            after(0.5) {
              plugin.invoke(["1", "2"])
              plugin.stop()
            }

            after(3) {
              expect(plugin.events).to(equal(output))
            }
          }
        }

        describe("start") {
          it("aborts on start") {
            after(1) {
              plugin.invoke(["1", "2"])
              plugin.start()
            }

            after(3) {
              expect(plugin.events).to(equal(output + [.stdout("1\n2\n")]))
            }
          }
        }
      }

      describe("restart") {
        it("restart") {
          after(1) {
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("only reports once on multiply restarts") {
          after(1) {
            plugin.restart()
            plugin.restart()
          }

          after(3) {
            expect(plugin.events).to(equal(output + output))
          }
        }

        it("aborts when deallocated") {
          after(1) {
            plugin.restart()
            plugin.deallocate()
          }

          after(3) {
            expect(plugin.events).to(equal(output))
          }
        }
      }
    }

    describe("error") {
      beforeEach {
        plugin = IntervalHost(path: .streamError)
      }

      xit("should output stderr and stdout") {
        expect(plugin.events).toEventually(contain(.stderr("ERROR")))
        expect(plugin.events).toEventually(contain(.stdout("A\n")))
        expect(plugin.events).toEventually(contain(.stdout("B\n")))
      }
    }
  }
}
