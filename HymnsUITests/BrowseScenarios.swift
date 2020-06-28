import XCTest

class BrowseScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
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
    }
}
