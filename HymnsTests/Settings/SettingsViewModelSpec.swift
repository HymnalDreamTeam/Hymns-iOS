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

                let settingsSize = 6 // Change this value as we add more settings.
                it("should contain exactly \(settingsSize) item") {
                    expect(target.settings).to(haveCount(settingsSize))
                }
            }
        }
    }
}
