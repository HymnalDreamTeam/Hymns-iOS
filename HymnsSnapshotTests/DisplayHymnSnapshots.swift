import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DisplayHymnSnapshots: XCTestCase {

    var viewModel: DisplayHymnViewModel!

    override func setUp() {
        super.setUp()
    }

    func test_loading() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn40_identifier)
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_error() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn40_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 40"
        viewModel.isFavorited = false
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn40_identifier)
        lyricsViewModel.lyrics = nil
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic40() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn40_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 40"
        viewModel.isFavorited = false
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn40_identifier)
        lyricsViewModel.lyrics
            = [VerseViewModel(verseNumber: "1", verseLines: hymn40_hymn.lyrics[0].verseContent),
               VerseViewModel(verseNumber: "2", verseLines: hymn40_hymn.lyrics[1].verseContent),
               VerseViewModel(verseNumber: "3", verseLines: hymn40_hymn.lyrics[2].verseContent),
               VerseViewModel(verseNumber: "4", verseLines: hymn40_hymn.lyrics[3].verseContent),
               VerseViewModel(verseNumber: "5", verseLines: hymn40_hymn.lyrics[4].verseContent)]
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn40_identifier)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1334() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1334_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1334"
        viewModel.isFavorited = true
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1334_identifier)
        lyricsViewModel.lyrics
            = [VerseViewModel(verseNumber: "1", verseLines: hymn1334_hymn.lyrics[0].verseContent)
        ]
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1334_identifier)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_noTabs() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier)
        lyricsViewModel.lyrics = [VerseViewModel(verseNumber: "1", verseLines: hymn1151_hymn.lyrics[0].verseContent),
                                  VerseViewModel(verseLines: hymn1151_hymn.lyrics[1].verseContent),
                                  VerseViewModel(verseNumber: "2", verseLines: hymn1151_hymn.lyrics[2].verseContent),
                                  VerseViewModel(verseNumber: "3", verseLines: hymn1151_hymn.lyrics[3].verseContent),
                                  VerseViewModel(verseNumber: "4", verseLines: hymn1151_hymn.lyrics[4].verseContent)]
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [HymnTab]()
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_oneTab() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = nil
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier)
        lyricsViewModel.lyrics = [VerseViewModel(verseNumber: "1", verseLines: hymn1151_hymn.lyrics[0].verseContent),
                                  VerseViewModel(verseLines: hymn1151_hymn.lyrics[1].verseContent),
                                  VerseViewModel(verseNumber: "2", verseLines: hymn1151_hymn.lyrics[2].verseContent),
                                  VerseViewModel(verseNumber: "3", verseLines: hymn1151_hymn.lyrics[3].verseContent),
                                  VerseViewModel(verseNumber: "4", verseLines: hymn1151_hymn.lyrics[4].verseContent)]
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_twoTabs() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier)
        lyricsViewModel.lyrics = [VerseViewModel(verseNumber: "1", verseLines: hymn1151_hymn.lyrics[0].verseContent),
                                  VerseViewModel(verseLines: hymn1151_hymn.lyrics[1].verseContent),
                                  VerseViewModel(verseNumber: "2", verseLines: hymn1151_hymn.lyrics[2].verseContent),
                                  VerseViewModel(verseNumber: "3", verseLines: hymn1151_hymn.lyrics[3].verseContent),
                                  VerseViewModel(verseNumber: "4", verseLines: hymn1151_hymn.lyrics[4].verseContent)]
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).maxSize().eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_musicTabSelected() {
        let preloader = PdfLoaderTestImpl()
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier, pdfPreloader: preloader)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false

        let pdfView = DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(preloader: preloader, url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=gtpdf")!))

        viewModel.currentTab = .music(HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.piano(pdfView.eraseToAnyView())])).eraseToAnyView())
        viewModel.tabItems = [.lyrics(EmptyView().eraseToAnyView()), viewModel.currentTab]
        let bottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        bottomBarViewModel.buttons = [
            .share("Shareable lyrics"),
            .fontSize(FontPickerViewModel()),
            .languages([cupOfChrist_songResult]),
            .tags,
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!))
        ]
        viewModel.bottomBar = bottomBarViewModel
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_musicTabSelected_guitarSelected() {
        let preloader = PdfLoaderTestImpl()
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier, pdfPreloader: preloader)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false

        let musicViewModel = HymnMusicViewModel(musicViews:
                                                    [.piano(EmptyView().eraseToAnyView()),
                                                     .guitar(Text("Guitar Chords here").eraseToAnyView())])
        musicViewModel.currentTab = .guitar(Text("Guitar Chords here").eraseToAnyView())
        let musicView = HymnMusicView(viewModel: musicViewModel).eraseToAnyView()
        viewModel.currentTab = .music(musicView)
        viewModel.tabItems = [.lyrics(EmptyView().eraseToAnyView()), viewModel.currentTab]
        let bottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        bottomBarViewModel.buttons = [
            .share("Shareable lyrics"),
            .fontSize(FontPickerViewModel()),
            .languages([cupOfChrist_songResult]),
            .tags,
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!))
        ]
        viewModel.bottomBar = bottomBarViewModel
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
