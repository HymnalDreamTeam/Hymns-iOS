import Foundation
import XCTest

public class BrowseViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func goToTags() -> BrowseViewCan {
        app.buttons["Tags"].tap()
        return self
    }

    public func tapTag(_ tag: String) -> BrowseResultsViewCan {
        app.buttons[tag].tap()
        return BrowseResultsViewCan(app, testCase: testCase)
    }

    public func tapCategory(_ category: String) -> BrowseViewCan {
        app.staticTexts[category].tap()
        return self
    }

    public func assertCategory(_ category: String, chevronUp: Bool) -> BrowseViewCan {
        for index in 0..<app.cells.count {
            let cell = app.cells.element(boundBy: index)
            let staticTexts = cell.descendants(matching: .staticText)
            for index2 in 0..<staticTexts.count {
                let staticText = staticTexts.element(boundBy: index2)
                if staticText.label == category {
                    let label = cell.descendants(matching: .image).element(boundBy: 0).label
                    if #available(iOS 15.0, *) {
                        XCTAssertEqual(label, chevronUp ? "Go Up" : "Go Down")
                    } else if #available(iOS 14.5, *) {
                        XCTAssertEqual(label, chevronUp ? "go up" : "go down")
                    } else {
                        XCTAssertEqual(label, chevronUp ? "chevron.up" : "chevron.down")
                    }
                    return self
                }
            }
        }
        testCase.record(XCTIssue(type: .assertionFailure, compactDescription: "unable to find category \(category) with chevron \(chevronUp ? "up" : "down")"))
        return self
    }

    public func tapSubcategory(_ subcategory: String, count: Int) -> BrowseResultsViewCan {
        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] '\(subcategory)' && label CONTAINS[c] '\(count)'")).tap()
        return BrowseResultsViewCan(app, testCase: testCase)
    }

    public func assertSubcategory(category: String, subcategory: String, count: Int) -> BrowseViewCan {
        for index in 0..<app.cells.count {
            let cell = app.cells.element(boundBy: index)
            let matchingButton = cell.descendants(matching: .button).element(matching: NSPredicate(format: "label CONTAINS[c] '\(subcategory)' && label CONTAINS[c] '\(count)'"))
            if matchingButton.exists {
                // Found the subcategory
                return self
            }
        }
        testCase.record(XCTIssue(type: .assertionFailure, compactDescription: "unable to find subcategory \(subcategory) with count \(count)"))
        return self
    }

    public func goToScriptureSongs() -> BrowseViewCan {
        while !app.buttons["Scripture Songs"].exists {
            app.scrollViews.element.swipeLeft()
        }
        app.buttons["Scripture Songs"].tap()
        return self
    }

    public func tapBook(_ book: String) -> BrowseViewCan {
        app.staticTexts[book].tap()
        return self
    }

    public func assertBook(_ book: String, chevronUp: Bool) -> BrowseViewCan {
        for index in 0..<app.cells.count {
            let cell = app.cells.element(boundBy: index)
            if cell.descendants(matching: .staticText).element.label == book {
                XCTAssertEqual(cell.descendants(matching: .image).element.label, chevronUp ? "chevron.up" : "chevron.down")
                return self
            }
        }
        testCase.record(XCTIssue(type: .assertionFailure, compactDescription: "unable to find book \(book) with chevron \(chevronUp ? "up" : "down")"))
        return self
    }

    public func tapReference(_ predicate: NSPredicate) -> DisplayHymnViewCan {
        _ = pressButton(predicate)
        return DisplayHymnViewCan(app, testCase: testCase)
    }

    public func goToAllSongs() -> BrowseViewCan {
        while !app.buttons["All Songs"].exists {
            app.scrollViews.element.swipeLeft()
        }
        app.buttons["All Songs"].tap()
        return self
    }

    public func tapHymnType(_ hymnType: String) -> BrowseResultsViewCan {
        app.buttons[hymnType].tap()
        return BrowseResultsViewCan(app, testCase: testCase)
    }
}
