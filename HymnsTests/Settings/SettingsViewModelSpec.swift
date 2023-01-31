import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class SettingsViewModelSpec: QuickSpec {

    override func spec() {
        describe("SettingsViewModel") {
            var systemUtil: SystemUtilMock!
            var target: SettingsViewModel!
            beforeEach {
                systemUtil = mock(SystemUtil.self)
                target = SettingsViewModel(systemUtil: systemUtil)
            }
            describe("populating settings") {
                context("network available") {
                    beforeEach {
                        given(systemUtil.isNetworkAvailable()) ~> true
                    }
                    var settingsSize = 7
                    if #available(iOS 16, *) { // iOS 16+ has "version information", which is the 7th item
                        settingsSize = 8
                    }
                    it("should contain exactly \(settingsSize) item") {
                        target.populateSettings(result: .constant(nil))
                        expect(target.settings).to(haveCount(settingsSize))
                    }
                }
                context("network unavailable") {
                    beforeEach {
                        given(systemUtil.isNetworkAvailable()) ~> false
                    }
                    var settingsSize = 6
                    if #available(iOS 16, *) { // iOS 16+ has "version information", which is the 7th item
                        settingsSize = 7
                    }
                    it("should contain exactly \(settingsSize) item") {
                        target.populateSettings(result: .constant(nil))
                        expect(target.settings).to(haveCount(settingsSize))
                    }
                }
            }
        }
    }
}
