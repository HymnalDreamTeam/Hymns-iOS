import Foundation
import XCTest

/**
 * Base calss for all the *Can classes.
 */
public class BaseViewCan {

    let app: XCUIApplication
    let testCase: XCTestCase

    init(_ app: XCUIApplication, testCase: XCTestCase) {
        self.app = app
        self.testCase = testCase
    }

    public func waitForButtons(_ predicates: NSPredicate..., timeout: TimeInterval = 1) -> Self {
        for predicate in predicates {
            XCTAssertTrue(app.buttons.element(matching: predicate).waitForExistence(timeout: timeout))
        }
        return self
    }

    public func waitForButtons(_ strings: String..., timeout: TimeInterval = 1) -> Self {
        for string in strings {
            XCTAssertTrue(
                app.buttons.element(
                    matching: NSPredicate(
                        format: "label == '\(string.replacingOccurrences(of: "\'", with: "\\'"))'"))
                    .waitForExistence(timeout: timeout))
        }
        return self
    }

    public func pressButton(_ predicate: NSPredicate) -> Self {
        _ = waitForButtons(predicate)
        app.buttons.element(matching: predicate).tap()
        return self
    }

    public func pressButton(_ buttonText: String) -> Self {
        _ = waitForButtons(buttonText)
        app.buttons[buttonText].tap()
        return self
    }

    public func verifyButtonsNotExist(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertFalse(app.buttons[string].exists)
        }
        return self
    }

    public func waitForTextViews(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertTrue(app.textViews[string].waitForExistence(timeout: 1))
        }
        return self
    }

    public func waitForStaticTexts(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertTrue(app.staticTexts[string].waitForExistence(timeout: 1))
        }
        return self
    }

    public func verifyStaticTextSize(size: CGSize, text: String) -> Self {
        XCTAssertEqual(size.width, app.staticTexts[text].frame.size.width, accuracy: 0.0001)
        XCTAssertEqual(size.height, app.staticTexts[text].frame.size.height, accuracy: 0.0001)
        return self
    }

    public func verifyTextViewSize(size: CGSize, text: String) -> Self {
        XCTAssertEqual(size.width, app.textViews[text].frame.size.width, accuracy: 1)
        XCTAssertEqual(size.height, app.textViews[text].frame.size.height, accuracy: 1)
        return self
    }

    public func waitForSliders(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertTrue(app.sliders[string].waitForExistence(timeout: 1))
        }
        return self
    }

    public func checkTextViewsCount(_ string: String, _ count: Int) -> Self {
        XCTAssertEqual(app.textViews.matching(identifier: "classic hymn 2 chorus").count, count)
        return self
    }

    public func verifySlidersExist(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertTrue(app.sliders[string].exists)
        }
        return self
    }

    public func verifySlidersNotExist(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertFalse(app.sliders[string].exists)
        }
        return self
    }

    public func verifyStaticTextsNotExists(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertFalse(app.staticTexts[string].exists)
        }
        return self
    }

    public func waitForImages(_ strings: String...) -> Self {
        for string in strings {
            XCTAssertTrue(app.images[string].waitForExistence(timeout: 1))
        }
        return self
    }

    public func takeScreenshot(name: String) -> Self {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)
        return self
    }

    public func swipeUp() -> Self {
        app.swipeUp()
        return self
    }

    public func swipeDown() -> Self {
        app.swipeDown()
        return self
    }

    public func swipeLeft() -> Self {
        app.swipeLeft()
        return self
    }

    public func swipeRight() -> Self {
        app.swipeRight()
        return self
    }
}

extension XCUIElement {
    /**
     * Removes any current text in the field before typing in the new value
     * - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }
}
