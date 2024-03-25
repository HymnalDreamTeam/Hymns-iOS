import Foundation
import XCTest

class SettingsScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_toggleRepeatChorus() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 2, Classic 2")
            .tapResult("Hymn 2, Classic 2")
            .waitForStaticTexts("classic hymn 2 chorus")
            .checkStaticTextCount("classic hymn 2 chorus", 1)
            .goBackToHome()
            .goToSettings()
            .toggleRepeatChorus()
            .returnToHome()
            .tapHome()
            .tapResult("Hymn 2, Classic 2")
            .waitForStaticTexts("classic hymn 2 chorus")
            .checkStaticTextCount("classic hymn 2 chorus", 2)
    }

    func test_clearHistory() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151")
            .goToSettings()
            .checkAndDismissToolTip()
            .tapClearHistory()
            .waitForStaticTexts("Recent songs cleared")
            .returnToHome()
            .tapHome()
            .verifyButtonsNotExist("classic1151")
            .waitForImages("empty search illustration")
    }

    func test_goToAboutUs() {
        _ = HomeViewCan(app, testCase: self)
            .goToSettings()
            .tapAboutUs()
            .verifyAboutUsDialogExists()
            .cancelAboutUs()
            .verifyAboutUsDialogNotExists()
    }

    func test_goToVersionInformation() {
        if #available(iOS 16, *) {
            _ = HomeViewCan(app, testCase: self)
                .goToSettings()
                .tapVersionInformation()
                .waitForStaticTexts("Version information", "Release version", "Build version", "iOS version")
        }
    }
}
