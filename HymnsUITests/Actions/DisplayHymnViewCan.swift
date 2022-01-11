import Foundation
import XCTest

public class DisplayHymnViewCan: BaseViewCan {

    override init(_ app: XCUIApplication, testCase: XCTestCase) {
        super.init(app, testCase: testCase)
    }

    public func goBackToHome() -> HomeViewCan {
        _ = pressButton("Go back")
        return HomeViewCan(app, testCase: testCase)
    }

    public func goBackToBrowse() -> BrowseViewCan {
        _ = pressButton("Go back")
        return BrowseViewCan(app, testCase: testCase)
    }

    public func goBackToBrowseResults() -> BrowseResultsViewCan {
        _ = pressButton("Go back")
        return BrowseResultsViewCan(app, testCase: testCase)
    }

    public func openPiano() -> DisplayHymnViewCan {
        return pressButton("Piano")
    }

    public func maximizeSheetMusic() -> DisplayHymnViewCan {
        return pressButton("Maximize music")
    }

    public func closeSheetMusic() -> DisplayHymnViewCan {
        return pressButton("Close")
    }

    public func openShareSheet() -> DisplayHymnViewCan {
        return pressButton("Share lyrics")
    }

    public func tapFontPicker() -> DisplayHymnViewCan {
        return pressButton("Change lyrics font size")
    }

    public func waitForFontPicker() -> DisplayHymnViewCan {
        return waitForSliders("Font picker slider")
    }

    public func verifyFontPickerExists() -> DisplayHymnViewCan {
        return verifySlidersExist("Font picker slider")
    }

    public func verifyFontPickerNotExists() -> DisplayHymnViewCan {
        return verifySlidersNotExist("Font picker slider")
    }

    private func assertFontPickerValue(_ value: String) -> DisplayHymnViewCan {
        // swiftlint:disable:next force_cast
        XCTAssertEqual(app.sliders["Font picker slider"].value as! String, value)
        return self
    }

    public func assertDefaultFontPickerValue() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return assertFontPickerValue("15")
        } else {
            return assertFontPickerValue("0.182")
        }
    }

    public func adjustFontPickerToSmallest() -> DisplayHymnViewCan {
        app.sliders["Font picker slider"].adjust(toNormalizedSliderPosition: 0)
        return self
    }

    public func assertSmallestFontPickerValue() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return assertFontPickerValue("13")
        } else {
            return assertFontPickerValue("0")
        }
    }

    public func adjustFontPickerToLargest() -> DisplayHymnViewCan {
        app.sliders["Font picker slider"].adjust(toNormalizedSliderPosition: 1)
        return self
    }

    public func assertLargestFontPickerValue() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return assertFontPickerValue("24")
        } else {
            return assertFontPickerValue("1")
        }
    }

    public func openLanguages() -> DisplayHymnViewCan {
        return pressButton("Show languages")
    }

    public func openAudioPlayer() -> DisplayHymnViewCan {
        return pressButton("Play music")
    }

    public func waitForPlayButton() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return waitForButtons("Play")
        } else if #available(iOS 14.5, *) {
            return waitForButtons("play")
        } else {
            return waitForButtons("play.circle")
        }
    }

    public func openSpeedPicker() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return pressButton("Timer")
        } else {
            return pressButton("timer")
        }
    }

    public func waitForSpeedPickerButtons() -> DisplayHymnViewCan {
        if #available(iOS 15.0, *) {
            return waitForButtons("Remove", "Add")
        } else if #available(iOS 14.5, *) {
            return waitForButtons("remove", "add")
        } else {
            return waitForButtons("minus", "plus")
        }
    }

    public func openRelevant() -> DisplayHymnViewCan {
        return pressButton("Relevant songs")
    }

    public func openTagSheet() -> DisplayHymnViewCan {
        return pressButton("Tags")
    }

    public func openSongInfo() -> DisplayHymnViewCan {
        return pressButton("Song Info")
    }

    public func openOverflowMenu() -> DisplayHymnViewCan {
        return pressButton("More options")
    }

    public func pressCancel() -> DisplayHymnViewCan {
        return pressButton("Cancel")
    }

    public override func pressButton(_ buttonText: String) -> Self {
        _ = waitForButtons(buttonText)

        // Pick the middle one when it's in a view pager with 5 elements when possible.
        if app.buttons.matching(identifier: buttonText).count == 5 && app.buttons.matching(identifier: buttonText).element(boundBy: 2).isHittable {
            app.buttons.matching(identifier: buttonText).element(boundBy: 2).tap()
            return self
        }

        for index in 0..<app.buttons.matching(identifier: buttonText).count {
            if app.buttons.matching(identifier: buttonText).element(boundBy: index).isHittable {
                app.buttons.matching(identifier: buttonText).element(boundBy: index).tap()
                return self
            }
        }
        XCTFail("Couldn't find hittable button with \(buttonText)")
        return self
    }
}
