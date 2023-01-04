import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class SettingsViewModelSpec: QuickSpec {

    override func spec() {
        describe("SettingsViewModel") {
            var target: SettingsViewModel!
            beforeEach {
                target = SettingsViewModel()
            }
            describe("populating settings") {
                beforeEach {
                    target.populateSettings(result: .constant(nil))
                }

                var settingsSize = 6
                if #available(iOS 16, *) { // iOS 16+ has "version information", which is the 7th item
                    settingsSize = 7
                }
                it("should contain exactly \(settingsSize) item") {
                    expect(target.settings).to(haveCount(settingsSize))
                }
            }
        }
    }
}
