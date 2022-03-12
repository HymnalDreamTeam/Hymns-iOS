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
            .openGuitar()
            .waitForStaticTexts("G", "Songbase", "version", "of", "Hymn", "1151", "chords")
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
