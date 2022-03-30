import XCTest

class DisplayHymnScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForStaticTexts("verse 1 line 1")
    }

    func test_maximizePdf() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openMusic()
            .openPiano()
            .verifyPdfDisplaying("Hymn 1151\'s Piano\n")
            .maximizeSheetMusic()
            .closeSheetMusic()
    }

    func test_shareLyrics() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openShareSheet()
            .waitForButtons("Edit Actions…", timeout: 2)
    }

    func test_tagSheet() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openOverflowMenu()
            .openTagSheet()
            .verifyTagSheet()
    }

    func test_songInfoDialog() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openOverflowMenu()
            .waitForStaticTexts("Additional options")
            .waitForButtons("Song Info", "Search in SoundCloud", "Search in YouTube")
            .openSongInfo()
            .waitForStaticTexts("Category", "song's category", "Subcategory", "song's subcategory")
    }

    func test_audioPlayer() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openAudioPlayer()
            .waitForPlayButton()
            .openSpeedPicker()
            .waitForSpeedPickerButtons()
            .waitForStaticTexts("Speed: 1.0x")
    }

    func test_changeFontSize() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .tapFontPicker()
            .waitForFontPicker()
            .verifyFontPickerExists()
            .assertDefaultFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 86.6666, height: 18.0), text: "verse 1 line 1")
            .adjustFontPickerToSmallest()
            .assertSmallestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 77.0, height: 15.6666), text: "verse 1 line 1")
            .adjustFontPickerToLargest()
            .assertLargestFontPickerValue()
            .verifyStaticTextSize(size: CGSize(width: 129.6666, height: 28.6666), text: "verse 1 line 1")
            .tapFontPicker()
            .verifyFontPickerNotExists()
    }

    func test_languages() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openLanguages()
            .waitForStaticTexts("Languages", "Change to another language")
            .waitForButtons("Cebuano", "诗歌(简)", "詩歌(繁)", "Dutch", "Tagalog", "Cancel")
            .pressCancel()
            .waitForStaticTexts("verse 1 line 1")
            .verifyStaticTextsNotExists("Languages", "Change to another language")
            .openLanguages()
            .pressButton("诗歌(简)")
            .waitForStaticTexts("Chinese Supplement 216", "chinese verse 1 chinese line 1")
    }

    func test_relevant() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openRelevant()
            .waitForStaticTexts("Relevant songs", "Change to a relevant hymn")
            .waitForButtons("New Tune")
            .pressCancel()
            .waitForStaticTexts("verse 1 line 1")
            .verifyStaticTextsNotExists("Relevant songs", "Change to a relevant hymn")
            .openRelevant()
            .pressButton("New Tune")
            .waitForStaticTexts("Hymn 2", "classic hymn 2 verse 1")
    }

    func test_favorite() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .favoriteSong()
            .goBackToHome()
            .goToFavorites()
            .waitForButtons("Hymn 1151, Minoru's song")
            .tapFavorite("Hymn 1151, Minoru's song")
            .waitForStaticTexts("verse 1 line 1")
            .unfavoriteSong()
            .goBackToFavorites()
            .verifyButtonsNotExist("Hymn 1151, Minoru's song")
    }

    func test_swipeBetweenHymns() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .swipeLeft()
            .waitForStaticTexts("classic hymn 1152")
            .tapFontPicker()
            .waitForFontPicker()
            .swipeRight()
            .waitForStaticTexts("classic hymn 1152")
            .tapFontPicker()
            .swipeRight()
            .verifyFontPickerNotExists()
            .waitForStaticTexts("verse 1 line 1")
    }
}
