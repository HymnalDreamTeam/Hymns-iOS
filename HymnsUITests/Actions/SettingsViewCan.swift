import Foundation
import XCTest

public class SettingsHymnViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func toggleRepeatChorus() -> SettingsHymnViewCan {
        app.switches["Repeat chorus\nFor songs with only one chorus, repeat the chorus after every verse"].tap()
        return self
    }

    public func tapClearHistory() -> SettingsHymnViewCan {
        app.buttons["Clear recent songs"].tap()
        return self
    }

    public func tapAboutUs() -> SettingsHymnViewCan {
        app.buttons["About us"].tap()
        return self
    }

    public func verifyAboutUsDialogExists() -> SettingsHymnViewCan {
        XCTAssertTrue(app.staticTexts["Hello There 👋"].exists)
        return self
    }

    public func cancelAboutUs() -> SettingsHymnViewCan {
        app.buttons["xmark"].tap()
        return self
    }

    public func verifyAboutUsDialogNotExists() -> SettingsHymnViewCan {
        XCTAssertFalse(app.staticTexts["Hello There 👋"].exists)
        return self
    }

    public func returnToHome() -> HomeViewCan {
        return HomeViewCan(app, testCase: testCase)
    }
}
