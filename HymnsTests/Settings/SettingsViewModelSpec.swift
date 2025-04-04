import Combine
import Quick
import Mockingbird
import Nimble
import StoreKit
@testable import Hymns

class SettingsViewModelSpec: QuickSpec {

    override class func spec() {
        describe("SettingsViewModel") {
            var systemUtil: SystemUtilMock!
            var target: SettingsViewModel!
            var coffeeDonation: CoffeeDonationMock!
            beforeEach {
                coffeeDonation = mock(CoffeeDonation.self)
                systemUtil = mock(SystemUtil.self)
                target = SettingsViewModel(systemUtil: systemUtil)
            }
            describe("populating settings") {
                context("donation products available") {
                    beforeEach {
                        given(systemUtil.donationProducts) ~> [coffeeDonation!]
                    }
                    let settingsSize = 9
                    it("should contain exactly \(settingsSize) item") {
                        target.populateSettings(result: .constant(nil))
                        expect(target.settings).to(haveCount(settingsSize))
                    }
                }
                context("donation products unavailable") {
                    beforeEach {
                        given(systemUtil.donationProducts) ~> []
                    }
                    let settingsSize = 8
                    it("should contain exactly \(settingsSize) item") {
                        target.populateSettings(result: .constant(nil))
                        expect(target.settings).to(haveCount(settingsSize))
                    }
                }
            }
        }
    }
}
