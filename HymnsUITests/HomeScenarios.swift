import XCTest

class HomeScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_goToSongFromRecentSongs() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForTextViews("verse 1 line 1")
    }

    func test_goToSongFromNumber() {
        _ = HomeViewCan(app, testCase: self)
            .dismissToolTip()
            .activateSearch()
            .waitForButtons("Cancel")
            .typeSearchText("1151")
            .waitForButtons("Hymn 1151, Hymn 1151")
            .tapResult("Hymn 1151, Hymn 1151")
            .waitForTextViews("verse 1 line 1")
    }

    func test_goToSongFromSearchResults() {
        _ = HomeViewCan(app, testCase: self)
            .activateSearch()
            .typeSearchText("search param")
            .waitForButtons("Hymn 1151, Click me!")
            .tapResult("Hymn 1151, Click me!")
            .waitForTextViews("verse 1 line 1")
    }

    func test_switchBetweenTabs() {
        _ = HomeViewCan(app, testCase: self)
            .verifyHomeTab()
            .tapBrowse()
            .verifyBrowseTab()
            .tapFavorites()
            .verifyFavoritesTab()
            .tapSettings()
            .verifySettingsTab()
            .tapHome()
            .verifyHomeTab()
    }

    func test_activateSearch() {
        _ = HomeViewCan(app, testCase: self)
            .verifyCancelNotExists()
            .activateSearch()
            .waitForButtons("Cancel")
            .verifyClearTextNotExists()
            .typeSearchText("1151")
            .verifySearchText("1151")
            .verifyClearTextExists()
            .clearText()
            .verifyClearTextNotExists()
            .verifySearchTextNotExists("1151")
            .cancelSearch()
            .verifyCancelNotExists()
    }
}
