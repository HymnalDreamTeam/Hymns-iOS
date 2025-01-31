import XCTest

class DisplayHymnMusicScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func test_goBetweenMusic() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForTextViews("verse 1 line 1")
            .openMusic()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .openPiano()
            .verifyPdfDisplaying("Hymn 1151\'s Piano")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openInlineChords()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
    }

    func test_transpose() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForTextViews("verse 1 line 1")
            .openMusic()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Transpose", "Transpose up a half step")
            .transposeUp()
            .waitForStaticTexts("G#", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Capo +1", "Transpose up a half step")
            .transposeUp()
            .waitForStaticTexts("A", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Capo +2", "Transpose up a half step")
            .transposeUp()
            .waitForStaticTexts("A#", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Capo +3", "Transpose up a half step")
            .transposeDown()
            .waitForStaticTexts("A", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Capo +2", "Transpose up a half step")
            .transposeReset(2)
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .waitForButtons("Transpose down a half step", "Transpose", "Transpose up a half step")
    }

    func test_changeFontOfInlineChords() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForTextViews("verse 1 line 1")
            .openMusic()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .verifyStaticTextSize(size: CGSize(width: 68.6666, height: 18), text: "Songbase")
            .tapFontPicker()
            .adjustFontPickerToSmallest()
            .assertSmallestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 64.6666, height: 17), text: "Songbase")
            .adjustFontPickerToLargest()
            .assertLargestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 104.3333, height: 28.6666), text: "Songbase")
    }

    func test_guitarFallbackToSheetMusicChordsSongbaseIsMissing() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 3, classic3")
            .waitForTextViews("classic hymn 3 chorus")
            .openMusic()
            .verifyPdfDisplaying("Hymn 3\'s Chords")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openPiano()
            .verifyPdfDisplaying("Hymn 3\'s Piano")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openGuitar()
            .verifyPdfDisplaying("Hymn 3\'s Chords")
            .maximizeSheetMusic()
            .closeSheetMusic()
    }

    func test_guitarFallbackToGuitarSheetWhenChordsAreMissing() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 40, classic40")
            .waitForTextViews("classic hymn 40 verse 2")
            .openMusic()
            .verifyPdfDisplaying("Hymn 40\'s Guitar")
            .openPiano()
            .verifyPdfDisplaying("Hymn 40\'s Piano")
    }
}
