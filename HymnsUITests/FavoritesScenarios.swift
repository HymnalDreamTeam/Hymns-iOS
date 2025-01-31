import XCTest

class FavoritesScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
        _ = HomeViewCan(app, testCase: self)
            .goToFavorites()
            .waitForButtons("Hymn 40, classic40", "Hymn 2, classic2", "Hymn 1151, classic1151")
    }

    func test_goToFavorite() {
        _ = FavoritesViewCan(app, testCase: self)
            .tapFavorite("Hymn 2, classic2")
            .waitForTextViews("classic hymn 2 verse 1")
    }
}
