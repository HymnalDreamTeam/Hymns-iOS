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
            .waitForStaticTexts("verse 1 line 1")
            .openMusic()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .openPiano()
            .verifyPdfDisplaying("Hymn 1151\'s Piano\n")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openInlineChords()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
    }

    func test_transpose() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForStaticTexts("verse 1 line 1")
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
            .waitForStaticTexts("verse 1 line 1")
            .openMusic()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
            .verifyStaticTextSize(size: CGSize(width: 67.6666, height: 17.3333), text: "Songbase")
            .tapFontPicker()
            .adjustFontPickerToSmallest()
            .assertSmallestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 63.3333, height: 16.3333), text: "Songbase")
            .adjustFontPickerToLargest()
            .assertLargestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 108.3333, height: 27.6666), text: "Songbase")
    }

    func test_guitarFallbackToSheetMusicChordsSongbaseIsMissing() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 3, classic3")
            .waitForStaticTexts("classic hymn 3 chorus")
            .openMusic()
            .verifyPdfDisplaying("Hymn 3\'s Chords\n")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openPiano()
            .verifyPdfDisplaying("Hymn 3\'s Piano\n")
            .maximizeSheetMusic()
            .closeSheetMusic()
            .openGuitar()
            .verifyPdfDisplaying("Hymn 3\'s Chords\n")
            .maximizeSheetMusic()
            .closeSheetMusic()
    }

    func test_guitarFallbackToGuitarSheetWhenChordsAreMissing() {
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 40, classic40")
            .waitForStaticTexts("classic hymn 40 verse 2")
            .openMusic()
            .verifyPdfDisplaying("Hymn 40\'s Guitar\n")
            .openPiano()
            .verifyPdfDisplaying("Hymn 40\'s Piano\n")
    }
}
