import Quick
import Nimble
import PathKit

@testable import Config

class ConfigDistributionTests: QuickSpec {
  override func spec() {
    var config: DistConfig!

    beforeEach {
      config = DistConfig(home: try! .uniqueTemporary())
    }

    afterEach {
      try? config.cleanup()
    }

    it("should not have a config on start up") {
      expect(config.hasConfig).to(beFalse())
    }

    describe("override") {
      it("should be able to override with shipped config") {
        expect(config.hasConfig).to(beFalse())
        _ = try? config.override(with: .shipped)
        expect(config.hasConfig).to(beTrue())
      }

      it("should be able to override with shipped config") {
        expect(config.hasConfig).to(beFalse())
        _ = try? config.override(with: .shipped)
        expect(config.has(config: .shipped)).to(beTrue())
        expect(config.hasConfig).to(beTrue())
      }

      it("should be able to init an empty file") {
        expect(config.hasConfig).to(beFalse())
        _ = try? config.override(with: .blank)
        expect(config.has(config: .blank)).to(beTrue())
        expect(config.hasConfig).to(beTrue())
      }
    }
  }
}
