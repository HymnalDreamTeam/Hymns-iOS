import Foundation
import XCTest

public class DisplayHymnViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func goBack() -> DisplayHymnViewCan {
        _ = pressButton("Go back")
        return DisplayHymnViewCan(app, testCase: testCase)
    }

    public func close() -> DisplayHymnViewCan {
        _ = pressButton("Close")
        return DisplayHymnViewCan(app, testCase: testCase)
    }

    public func goBackToHome() -> HomeViewCan {
        _ = goBack()
        return switchToHome()
    }

    public func switchToHome() -> HomeViewCan {
        return HomeViewCan(app, testCase: testCase)
    }

    public func goBackToBrowse() -> BrowseViewCan {
        _ = goBack()
        return switchToBrowse()
    }

    public func switchToBrowse() -> BrowseViewCan {
        return BrowseViewCan(app, testCase: testCase)
    }

    public func goBackToFavorites() -> FavoritesViewCan {
        _ = goBack()
        return switchToFavorites()
    }

    public func switchToFavorites() -> FavoritesViewCan {
        return FavoritesViewCan(app, testCase: testCase)
    }

    public func goBackToBrowseResults() -> BrowseResultsViewCan {
        _ = pressButton("Go back")
        return switchToBrowseResults()
    }

    public func switchToBrowseResults() -> BrowseResultsViewCan {
        return BrowseResultsViewCan(app, testCase: testCase)
    }

    public func favoriteSong() -> DisplayHymnViewCan {
        return pressButton("Mark song as a favorite")
    }

    public func unfavoriteSong() -> DisplayHymnViewCan {
        return pressButton("Unmark song as a favorite")
    }

    public func openMusic() -> DisplayHymnViewCan {
        return pressButton("Music")
    }

    public func maximizeSheetMusic() -> DisplayHymnViewCan {
        return pressButton("Maximize sheet music")
    }

    public func openPiano() -> DisplayHymnViewCan {
        return pressButton("Piano sheet music")
    }

    public func openGuitar() -> DisplayHymnViewCan {
        return pressButton("Guitar sheet music")
    }

    public func openInlineChords() -> DisplayHymnViewCan {
        return pressButton("Inline chords")
    }

    public func transposeUp() -> DisplayHymnViewCan {
        return pressButton("Transpose up a half step")
    }

    public func transposeDown() -> DisplayHymnViewCan {
        return pressButton("Transpose down a half step")
    }

    public func transposeReset(_ transposition: Int) -> DisplayHymnViewCan {
        return pressButton(transposition == 0 ? "Transpose" : String(format: "Capo %+d", transposition))
    }

    public func verifyPdfDisplaying(_ string: String) -> DisplayHymnViewCan {
        // swiftlint:disable force_cast
        XCTAssertEqual(string, app.textViews.element(boundBy: 0).value! as! String)
        return self
    }

    public func closeSheetMusic() -> DisplayHymnViewCan {
        // There is another "Close" for the song view itself, so we need special logic to specify
        // closing the sheet music.
        let predicate = NSPredicate { (evaluatedObject, _) -> Bool in
            guard let element = evaluatedObject as? XCUIElementSnapshot else { return false }
            return element.label == "Close" &&
                // Pick the "Close" button that is left-aligned because the other "Close" button is next
                // to the favorites button on the right side.
                element.frame.minX == 0
        }
        app.buttons.element(matching: predicate).tap()
        return self
    }

    public func openShareSheet() -> DisplayHymnViewCan {
        return pressButton("Share lyrics")
    }

    public func tapFontPicker() -> DisplayHymnViewCan {
        return pressButton("Change lyrics font size")
    }

    public func waitForFontPicker() -> DisplayHymnViewCan {
        return waitForSliders("Slide to change the font size")
    }

    public func verifyFontPickerExists() -> DisplayHymnViewCan {
        return verifySlidersExist("Slide to change the font size")
    }

    public func verifyFontPickerNotExists() -> DisplayHymnViewCan {
        return verifySlidersNotExist("Slide to change the font size")
    }

    private func assertFontPickerValue(_ value: String) -> DisplayHymnViewCan {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(app.sliders["Slide to change the font size"].value as! String, value)
        return self
    }

    public func assertDefaultFontPickerValue() -> DisplayHymnViewCan {
        return assertFontPickerValue("15")
    }

    public func adjustFontPickerToSmallest() -> DisplayHymnViewCan {
        app.sliders["Slide to change the font size"].adjust(toNormalizedSliderPosition: 0)
        return self
    }

    public func assertSmallestFontPickerValue() -> DisplayHymnViewCan {
        return assertFontPickerValue("13")
    }

    public func adjustFontPickerToLargest() -> DisplayHymnViewCan {
        app.sliders["Slide to change the font size"].adjust(toNormalizedSliderPosition: 1)
        return self
    }

    public func assertLargestFontPickerValue() -> DisplayHymnViewCan {
        return assertFontPickerValue("24")
    }

    public func openLanguages() -> DisplayHymnViewCan {
        return pressButton("Show languages")
    }

    public func openAudioPlayer() -> DisplayHymnViewCan {
        return pressButton("Play music")
    }

    public func waitForPlayButton() -> DisplayHymnViewCan {
        return waitForButtons("Play")
    }

    public func verifyPlayButtonNotExists() -> DisplayHymnViewCan {
        return verifyButtonsNotExist("Play")
    }

    public func openSpeedPicker() -> DisplayHymnViewCan {
        return pressButton("Timer")
    }

    public func waitForSpeedPickerButtons() -> DisplayHymnViewCan {
        return waitForButtons("minus", "plus")
    }

    public func openRelevant() -> DisplayHymnViewCan {
        return pressButton("Relevant songs")
    }

    public func openTagSheet() -> DisplayHymnViewCan {
        return pressButton("Tags")
    }

    public func verifyTagSheet() -> DisplayHymnViewCan {
        if app.textFields.element(matching: NSPredicate(format: "placeholderValue == %@", "Name your tag")).exists {
            return self
        }
        XCTFail("Couldn't find tag sheet")
        return self
    }

    public func openSongInfo() -> DisplayHymnViewCan {
        return pressButton("Song Info")
    }

    public func openCategory(_ category: String) -> BrowseResultsViewCan {
        _ = pressButton(category)
        return BrowseResultsViewCan(app, testCase: testCase)
    }

    public func openOverflowMenu() -> DisplayHymnViewCan {
        return pressButton("More options")
    }

    public func pressCancel() -> DisplayHymnViewCan {
        return pressButton("Cancel")
    }

    private func onScreenPredicate(_ identifier: String) -> NSPredicate {
        NSPredicate { (evaluatedObject, _) -> Bool in
            guard let element = evaluatedObject as? XCUIElementSnapshot else { return false }
            return element.label == identifier &&
                element.frame.minX >= 0 &&
            element.frame.maxX <= self.app.frame.maxX
        }
    }

    public override func waitForStaticTexts(_ identifiers: String...) -> Self {
        for identifier in identifiers {
            XCTAssertTrue(
                app.staticTexts
                    .element(matching: onScreenPredicate(identifier))
                    .waitForExistence(timeout: 1))
            XCTAssertTrue(
                app.staticTexts.matching(identifier: identifier)
                    .element(matching: onScreenPredicate(identifier))
                    .isHittable)
        }
        return self
    }

    public func verifyStaticTextsNotDisplayed(_ identifiers: String...) -> Self {
        for identifier in identifiers {
            XCTAssertFalse(
                app.staticTexts
                    .element(matching: onScreenPredicate(identifier))
                    .isHittable)
        }
        return self
    }

    public override func waitForButtons(_ identifiers: String..., timeout: TimeInterval = 1) -> Self {
        for identifier in identifiers {
            XCTAssertTrue(
                app.buttons
                    .element(matching: onScreenPredicate(identifier))
                    .waitForExistence(timeout: 1))
            XCTAssertTrue(
                app.buttons
                    .element(matching: onScreenPredicate(identifier))
                    .isHittable)
        }
        return self
    }

    public func verifyButtonsNotDisplayed(_ identifiers: String...) -> Self {
        for identifier in identifiers {
            XCTAssertFalse(
                app.staticTexts
                    .element(matching: onScreenPredicate(identifier))
                    .isHittable)
        }
        return self
    }

    public override func pressButton(_ buttonText: String) -> Self {
        _ = waitForButtons(buttonText)
        app.buttons.element(matching: onScreenPredicate(buttonText)).tap()
        return self
    }
}
