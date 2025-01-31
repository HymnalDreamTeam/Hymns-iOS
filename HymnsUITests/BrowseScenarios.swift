import XCTest

class BrowseScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_browseTags() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToTags()
            .waitForButtons("tag1", "tag2")
            .tapTag("tag1")
            .waitForButtons("Hymn 1151, Click me!", "Hymn 40, Don't click me!", timeout: 3)
            .tapResult("Hymn 1151, Click me!")
            .waitForTextViews("verse 1 line 1")
            .goBackToBrowseResults()
            .waitForButtons("Hymn 1151, Click me!", "Hymn 40, Don't click me!", timeout: 3)
            .goBackToBrowse()
            .waitForButtons("tag1", "tag2")
    }

    func test_browseCategory() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .assertCategory("category 1", chevronUp: false)
            .assertCategory("category 2", chevronUp: false)
            .tapCategory("category 1")
            .assertCategory("category 1", chevronUp: true)
            .assertCategory("category 2", chevronUp: false)
            .assertSubcategory(category: "category 1", subcategory: "All subcategories", count: 6)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 1", count: 5)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 2", count: 1)
            .tapSubcategory("subcategory 2", count: 1)
            .waitForButtons("Hymn 1151, Click me!", "New tune 37, Don't click!", "Hymn 883, Don't click either!")
            .tapResult("Hymn 1151, Click me!")
            .waitForTextViews("verse 1 line 1")
            .goBackToBrowseResults()
            .waitForButtons("Hymn 1151, Click me!", "New tune 37, Don't click!", "Hymn 883, Don't click either!")
            .goBackToBrowse()
            .assertCategory("category 1", chevronUp: true)
            .assertCategory("category 2", chevronUp: false)
            .assertSubcategory(category: "category 1", subcategory: "All subcategories", count: 6)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 1", count: 5)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 2", count: 1)
    }

    // Need to test new tunes as well because of an issue in iOS 15.4 where onAppear wasn't being
    // called, which caused the new tunes page to have a forever loading screen.
    func test_browseNewTunes() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToNewTunes()
            .assertCategory("category 1", chevronUp: false)
            .assertCategory("category 2", chevronUp: false)
            .tapCategory("category 1")
            .assertCategory("category 1", chevronUp: true)
            .assertCategory("category 2", chevronUp: false)
            .assertSubcategory(category: "category 1", subcategory: "All subcategories", count: 6)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 1", count: 5)
            .assertSubcategory(category: "category 1", subcategory: "subcategory 2", count: 1)
    }

    func test_browseScriptures() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToScriptureSongs()
            .assertCategory("Genesis", chevronUp: false)
            .assertCategory("Hosea", chevronUp: false)
            .assertCategory("Revelation", chevronUp: false)
            .tapBook("Revelation")
            .assertCategory("Genesis", chevronUp: false)
            .assertCategory("Hosea", chevronUp: false)
            .assertCategory("Revelation", chevronUp: true)
            .waitForButtons(NSPredicate(format: "label CONTAINS[c] 'General' && label CONTAINS[c] 'Don\\'t click me!'"),
                            NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
            .tapReference(NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
            .waitForTextViews("verse 1 line 1")
            .goBackToBrowse()
            .assertCategory("Genesis", chevronUp: false)
            .assertCategory("Hosea", chevronUp: false)
            .assertCategory("Revelation", chevronUp: true)
            .waitForButtons(NSPredicate(format: "label CONTAINS[c] 'General' && label CONTAINS[c] 'Don\\'t click me!'"),
                            NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
    }

    func test_browseAllSongs() {
        _ = HomeViewCan(app, testCase: self)
            .goToBrowse()
            .goToAllSongs()
            .waitForButtons("Howard Higashi Songs")
            .tapHymnType("Howard Higashi Songs")
            .waitForButtons("1. Higashi title 1")
            .tapResult("2. Higashi title 2")
            .waitForTextViews("howard higashi verse 1 line 2")
            .goBackToBrowseResults()
            .waitForButtons("1. Higashi title 1")
            .goBackToBrowse()
            .waitForButtons("Classic Hymns", "New Songs", "Children's Songs", "Howard Higashi Songs")
    }
}
