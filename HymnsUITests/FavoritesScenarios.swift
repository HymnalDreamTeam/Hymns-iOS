import XCTest

class FavoritesScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_goToFavorite() {
        _ = HomeViewCan(app, testCase: self)
            .goToFavorites()
            .waitUntilDisplayed("classic40", "classic2", "classic1151")
            .tapFavorite("classic1151")
            .waitUntilDisplayed("verse 1 line 1")
    }
}
