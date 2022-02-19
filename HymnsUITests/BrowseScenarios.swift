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
            .waitForButtons("Click me!", "Don't click me!", timeout: 3)
            .tapResult("Click me!")
            .waitForStaticTexts("verse 1 line 1")
            .goBackToBrowseResults()
            .waitForButtons("Click me!", "Don't click me!", timeout: 3)
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
            .waitForButtons("Click me!", "Don't click!", "Don't click either!")
            .tapResult("Click me!")
            .waitForStaticTexts("verse 1 line 1")
            .goBackToBrowseResults()
            .waitForButtons("Click me!", "Don't click!", "Don't click either!")
            .goBackToBrowse()
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
            .waitForStaticTexts("verse 1 line 1")
            .goBackToBrowse()
            .assertCategory("Genesis", chevronUp: false)
            .assertCategory("Hosea", chevronUp: false)
            .assertCategory("Revelation", chevronUp: true)
            .waitForButtons(NSPredicate(format: "label CONTAINS[c] 'General' && label CONTAINS[c] 'Don\\'t click me!'"),
                            NSPredicate(format: "label CONTAINS[c] '22' && label CONTAINS[c] 'Click me!'"))
    }

//    func test_browseAllSongs() {
//        _ = HomeViewCan(app, testCase: self)
//            .goToBrowse()
//            .goToAllSongs()
//            .waitForButtons("Classic Hymns", "New Songs", "Children's Songs", "Howard Higashi Songs")
//            .tapHymnType("Classic Hymns")
//            .waitForButtons("1. Title of Hymn 1", timeout: 10)
//            .tapResult("2. Title of Hymn 2")
//            .waitForStaticTexts("classic hymn 2 verse 1")
//            .goBackToBrowseResults()
//            .waitForButtons("1. Title of Hymn 1", timeout: 10)
//            .goBackToBrowse()
//            .waitForButtons("Classic hymns", "New songs", "Children's songs", "Howard Higashi songs")
//    }
}
