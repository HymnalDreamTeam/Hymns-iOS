import XCTest

/// Tests various scenarios that navigate between views
class NavigationScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_closeFunctionality_fromHome() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .tapResult("Hymn 1151, classic1151")
        _ = testNavigationToDifferentLanguageFromHymn1151(displayHymnViewCan)
            .switchToHome()
            .waitForButtons("Hymn 1151, Hymn: Minoru's song", "Hymn 40, classic40")
    }

    func test_closeFunctionality_fromSongInfo() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .tapResult("Hymn 1151, classic1151")
            .waitForStaticTexts("verse 1 line 1")
            .openOverflowMenu()
            .waitForStaticTexts("Additional options")
            .openSongInfo()
            .waitForStaticTexts("Category", "Subcategory")
            .openCategory("song's category")
            .tapResult("Hymn 1151, Click me!")
        _ = testNavigationToDifferentRelevantFromHymn1151(displayHymnViewCan)
            .switchToHome()
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2")
    }

    func test_closeFunctionality_fromFavorites() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .goToFavorites()
            .tapFavorite("Hymn 1151, classic1151")
        _ = testNavigationToDifferentRelevantFromHymn1151(displayHymnViewCan)
            .switchToFavorites()
            .waitForButtons("Hymn 40, classic40", "Hymn 2, classic2", "Hymn 1151, classic1151")
    }

    func test_closeFunctionality_fromBrowseTags() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToTags()
            .tapTag("tag1")
            .tapResult("Hymn 1151, Click me!")
        _ = testNavigationToDifferentLanguageFromHymn1151(displayHymnViewCan)
            .switchToBrowse()
            .waitForButtons("tag1", "tag2")
    }

    func test_closeFunctionality_fromBrowseCategory() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .assertCategory("category 1", chevronUp: false)
            .tapCategory("category 1")
            .assertSubcategory(category: "category 1", subcategory: "subcategory 2", count: 1)
            .tapSubcategory("subcategory 2", count: 1)
            .tapResult("Hymn 1151, Click me!")
        _ = testNavigationToDifferentLanguageFromHymn1151(displayHymnViewCan)
            .switchToBrowse()
            .assertCategory("category 1", chevronUp: true)
    }

    func test_closeFunctionality_fromBrowseScriptures() {
        let displayHymnViewCan = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToScriptureSongs()
            .assertCategory("Revelation", chevronUp: false)
            .tapBook("Revelation")
            .tapReference(NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
        _ = testNavigationToDifferentRelevantFromHymn1151(displayHymnViewCan)
            .switchToBrowse()
            .assertCategory("Genesis", chevronUp: false)
            .assertCategory("Hosea", chevronUp: false)
            .assertCategory("Revelation", chevronUp: true)
            .waitForButtons(NSPredicate(format: "label CONTAINS[c] 'General' && label CONTAINS[c] 'Don\\'t click me!'"),
                            NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
    }

    func test_closeFunctionality_fromBrowseAll() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToAllSongs()
            .tapHymnType("Howard Higashi Songs")
            .tapResult("2. Higashi title 2")
            .waitForStaticTexts("howard higashi verse 1 line 2")
            .openLanguages()
            .pressButton("Chinese Supplement 216 (Trad.)")
            .waitForStaticTexts("chinese verse 1 chinese line 1")
            .goBack()
            // "Back" goes to the original song.
            .waitForStaticTexts("howard higashi verse 1 line 2")
            .openLanguages()
            .pressButton("Chinese Supplement 216 (Trad.)")
            .waitForStaticTexts("chinese verse 1 chinese line 1")
            // "Close" goes all the way back the beginning.
            .close()
            .switchToBrowse()
            .waitForButtons("Classic Hymns", "New Songs", "Children's Songs", "Howard Higashi Songs", "Songbase Songs")
    }

    /// Once we are on Hymn 1151, we can run the same set of functions to test navigation.
    private func testNavigationToDifferentLanguageFromHymn1151(_ displayHymnViewCan: DisplayHymnViewCan) -> DisplayHymnViewCan {
        displayHymnViewCan
            .waitForStaticTexts("verse 1 line 1")
            .openLanguages()
            .pressButton("Chinese Supplement 216 (Trad.)")
            .waitForStaticTexts("chinese verse 1 chinese line 1")
            // "Back" goes to the original song.
            .goBack()
            .waitForStaticTexts("verse 1 line 1")
            .openLanguages()
            .waitForStaticTexts("Languages", "Change to another language")
            .pressButton("Chinese Supplement 216 (Trad.)")
            .waitForStaticTexts("chinese verse 1 chinese line 1")
            .close()
    }

    private func testNavigationToDifferentRelevantFromHymn1151(_ displayHymnViewCan: DisplayHymnViewCan) -> DisplayHymnViewCan {
        displayHymnViewCan
            .waitForStaticTexts("verse 1 line 1")
            .openRelevant()
            .pressButton("Hymn 2")
            .waitForStaticTexts("classic hymn 2 verse 1")
            // "Back" goes to the original song.
            .goBack()
            .waitForStaticTexts("verse 1 line 1")
            .openRelevant()
            .pressButton("Hymn 2")
            .waitForStaticTexts("classic hymn 2 verse 1")
            .close()
    }
}
