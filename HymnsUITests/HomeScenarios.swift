import XCTest

class HomeScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_goToSongFromRecentSongs() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("classic1151", "classic40", "Hymn 2: Classic 2", "classic3")
            .tapResult("classic1151")
            .waitForStaticTexts("Hymn 1151", "verse 1 line 1")
    }

    func test_goToSongFromNumber() {
        _ = HomeViewCan(app, testCase: self)
            .dismissToolTip()
            .activateSearch()
            .waitForButtons("Cancel")
            .typeSearchText("1151")
            .waitForButtons("Hymn 1151")
            .tapResult("Hymn 1151")
            .waitForStaticTexts("Hymn 1151", "verse 1 line 1")
    }

    func test_goToSongFromSearchResults() {
        _ = HomeViewCan(app, testCase: self)
            .activateSearch()
            .typeSearchText("search param")
            .waitForButtons("Click me!")
            .tapResult("Click me!")
            .waitForStaticTexts("Hymn 1151", "verse 1 line 1")
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
