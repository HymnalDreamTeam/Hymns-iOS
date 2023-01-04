import Foundation
import XCTest

public class SettingsHymnViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func toggleRepeatChorus() -> SettingsHymnViewCan {
        let repeatChorus = app.switches.element(boundBy: 0)
        XCTAssertEqual(repeatChorus.label, "Repeat chorus, For songs with only one chorus, repeat the chorus after every verse.")
        repeatChorus.twoFingerTap()
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
        XCTAssertTrue(app.staticTexts["Hello there 👋"].exists)
        return self
    }

    public func cancelAboutUs() -> SettingsHymnViewCan {
        app.buttons["Close page"].tap()
        return self
    }

    public func verifyAboutUsDialogNotExists() -> SettingsHymnViewCan {
        XCTAssertFalse(app.staticTexts["Hello there 👋"].exists)
        return self
    }

    public func tapVersionInformation() -> SettingsHymnViewCan {
        app.buttons["Version information"].tap()
        return self
    }

    public func returnToHome() -> HomeViewCan {
        return HomeViewCan(app, testCase: testCase)
    }
}
