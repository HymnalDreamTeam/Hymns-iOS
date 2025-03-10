import XCTest

class DisplayHymnScenarios: BaseTestCase {

    override func setUp() {
        super.setUp()
        app.launch()
        _ = HomeViewCan(app, testCase: self)
            .waitForButtons("Hymn 1151, classic1151", "Hymn 40, classic40", "Hymn 2, Classic 2", "Hymn 3, classic3")
            .tapResult("Hymn 1151, classic1151")
            .waitForTextViews("verse 1 line 1")
    }

    func test_maximizePdf() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openMusic()
            .openPiano()
            .verifyPdfDisplaying("Hymn 1151\'s Piano")
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
            .waitForStaticTexts("Category", "Subcategory")
            .waitForButtons("song's category", "song's subcategory")
            .openCategory("song's category")
            .waitForStaticTexts("song's category", "Hymn 1151", "Click me!", "New tune 37", "Don't click!", "Hymn 883", "Don't click either!")
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
        var initialTextSize: CGSize?

        _ = DisplayHymnViewCan(app, testCase: self)
            .tapFontPicker()
            .waitForFontPicker()
            .verifyFontPickerExists()
            .assertDefaultFontPickerValue()
            .saveTextViewSize("verse 1 line 1", closure: { size in
                initialTextSize = size
            })
            .verifyTextViewSizeEqual(size: initialTextSize!, text: "verse 1 line 1")
            .adjustFontPickerToSmallest()
            .assertSmallestFontPickerValue()
            .verifyTextViewSizeSmaller(size: initialTextSize!, text: "verse 1 line 1")
            .adjustFontPickerToLargest()
            .assertLargestFontPickerValue()
            .verifyTextViewSizeLarger(size: initialTextSize!, text: "verse 1 line 1")
            .tapFontPicker()
            .verifyFontPickerNotExists()
    }

    func test_languages() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openLanguages()
            .waitForStaticTexts("Languages", "Change to another language")
            .waitForButtons("Cebuano 1151", "Chinese Supplement 216 (Simp.)", "Chinese Supplement 216 (Trad.)", "Dutch 35", "Tagalog 1151", "Cancel")
            .pressCancel()
            .waitForTextViews("verse 1 line 1")
            .verifyStaticTextsNotExists("Languages", "Change to another language")
            .openLanguages()
            .waitForStaticTexts("Languages", "Change to another language")
            .pressButton("Chinese Supplement 216 (Trad.)")
            .waitForStaticTexts("Chinese Supplement 216 (Trad.)")
            .waitForTextViews("chinese verse 1 chinese line 1")
            .goBack()
            .waitForTextViews("verse 1 line 1")
    }

    func test_relevant() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .openRelevant()
            .waitForStaticTexts("Relevant songs", "Change to a relevant hymn")
            .waitForButtons("Hymn 2")
            .pressCancel()
            .waitForTextViews("verse 1 line 1")
            .verifyStaticTextsNotExists("Relevant songs", "Change to a relevant hymn")
            .openRelevant()
            .waitForStaticTexts("Relevant songs", "Change to a relevant hymn")
            .pressButton("Hymn 2")
            .waitForStaticTexts("Hymn 2")
            .waitForTextViews("classic hymn 2 verse 1")
    }

    func test_favorite() {
        app.launch()
        _ = HomeViewCan(app, testCase: self)
            .tapResult("Hymn 3, classic3")
            .waitForTextViews("classic hymn 3 verse 1")
            .favoriteSong()
            .goBackToHome()
            .goToFavorites()
            .tapFavorite("Hymn 3, Classic 3")
            .waitForTextViews("classic hymn 3 verse 1")
            .unfavoriteSong()
            .goBackToFavorites()
            .verifyButtonsNotExist("Hymn 3, Classic 3")
    }

    func test_swipeBetweenHymns() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .swipeLeft()
            .waitForTextViews("classic hymn 1152")
            .tapFontPicker()
            .waitForFontPicker()
            .swipeRight()
            .waitForTextViews("classic hymn 1152")
            .tapFontPicker()
            .swipeRight()
            .verifyFontPickerNotExists()
            .waitForTextViews("verse 1 line 1")
    }

    func test_scrolling() {
        _ = DisplayHymnViewCan(app, testCase: self)
            .waitForStaticTexts("Hymn 1151")
            .waitForButtons("Lyrics", "Music", "Change lyrics font size")

            .swipeDown() // Should have no impact on toolbar or bottom bar visibility
            .waitForStaticTexts("Hymn 1151")
            .waitForButtons("Lyrics", "Music", "Change lyrics font size")

            .swipeUp() // Should make the toolbars and bottom bar disappear
            .verifyStaticTextsNotDisplayed("Hymn 1151")
            .verifyButtonsNotDisplayed("Lyrics", "Music", "Change lyrics font size")

            .swipeUp() // Should make the toolbars and bottom bar disappear
            .verifyStaticTextsNotDisplayed("Hymn 1151")
            .verifyButtonsNotDisplayed("Lyrics", "Music", "Change lyrics font size")

            .swipeDown() // Only the bottom bar should be visible now
            .verifyStaticTextsNotDisplayed("Hymn 1151")
            .verifyButtonsNotDisplayed("Lyrics", "Music")
            .waitForButtons("Change lyrics font size")

            .swipeDown() // Toolbars and bottom bar should be dispalyed
            .waitForStaticTexts("Hymn 1151")
            .waitForButtons("Lyrics", "Music", "Change lyrics font size")
    }
}
