import Foundation
import XCTest

public class HomeViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func dismissToolTip() -> HomeViewCan {
        app.buttons["Try searching by hymn type (e.g. ns151, ch1, s3)"].tap()
        return self
    }

    public func activateSearch() -> HomeViewCan {
        app.textFields.element.tap()
        return self
    }

    public func typeSearchText(_ searchText: String) -> HomeViewCan {
        app.textFields.element.clearAndEnterText(searchText)
        return self
    }

    public func verifySearchText(_ searchText: String) -> HomeViewCan {
        XCTAssertTrue(app.textFields[searchText].exists)
        return self
    }

    public func verifySearchTextNotExists(_ searchText: String) -> HomeViewCan {
        XCTAssertFalse(app.textFields[searchText].exists)
        return self
    }

    public func verifyCancelExists() -> HomeViewCan {
        XCTAssertTrue(app.buttons["Cancel"].exists)
        return self
    }

    public func verifyCancelNotExists() -> HomeViewCan {
        XCTAssertFalse(app.buttons["Cancel"].exists)
        return self
    }

    public func cancelSearch() -> HomeViewCan {
        app.buttons["Cancel"].tap()
        return self
    }

    public func verifyClearTextExists() -> HomeViewCan {
        XCTAssertTrue(app.buttons["Close"].exists)
        return self
    }

    public func verifyClearTextNotExists() -> HomeViewCan {
        XCTAssertFalse(app.buttons["Close"].exists)
        return self
    }

    public func clearText() -> HomeViewCan {
        app.buttons["Close"].tap()
        return self
    }

    public func tapResult(_ result: String) -> DisplayHymnViewCan {
        _ = pressButton(result)
        return DisplayHymnViewCan(app, testCase: testCase)
    }

    public func tapHome() -> HomeViewCan {
        app.buttons["Search tab"].tap()
        return self
    }

    public func verifyHomeTab() -> HomeViewCan {
        XCTAssertTrue(app.staticTexts["Look up any hymn"].exists)
        return self
    }

    public func tapBrowse() -> HomeViewCan {
        app.buttons["Browse tab"].tap()
        return self
    }

    public func goToBrowse() -> BrowseViewCan {
        _ = tapBrowse()
        return BrowseViewCan(app, testCase: testCase)
    }

    public func verifyBrowseTab() -> HomeViewCan {
        XCTAssertTrue(app.staticTexts["Browse"].exists)
        return self
    }

    public func tapFavorites() -> HomeViewCan {
        app.buttons["Favorites tab"].tap()
        return self
    }

    public func goToFavorites() -> FavoritesViewCan {
        _ = tapFavorites()
        return FavoritesViewCan(app, testCase: testCase)
    }

    public func verifyFavoritesTab() -> HomeViewCan {
        XCTAssertTrue(app.staticTexts["Favorites"].exists)
        return self
    }

    public func tapSettings() -> HomeViewCan {
        app.buttons["Settings tab"].tap()
        return self
    }

    public func goToSettings() -> SettingsHymnViewCan {
        _ = tapSettings()
        return SettingsHymnViewCan(app, testCase: testCase)
    }

    public func verifySettingsTab() -> HomeViewCan {
        XCTAssertTrue(app.staticTexts["Settings"].exists)
        return self
    }
}
