import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DisplayHymnSnapshots: XCTestCase {

    var viewModel: DisplayHymnViewModel!

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
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic40() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn40_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 40"
        viewModel.isFavorited = false
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn40_identifier, lyrics: classic40_preview.lyrics.verses)!
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn40_identifier, hymn: hymn)
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
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1334_identifier, lyrics: classic1334_preview.lyrics.verses)!
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1334_identifier, hymn: hymn)
        viewModel.bottomBar!.buttons = [.share("lyrics"), .fontSize(FontPickerViewModel()), .tags]
        assertVersionedSnapshot(
            matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_classic1151_nilFavorite() {
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier)
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = nil
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier, lyrics: classic1151_preview.lyrics.verses)!
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab]
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier, hymn: hymn)
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
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier, lyrics: classic1151_preview.lyrics.verses)!
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        viewModel.tabItems = [HymnTab]()
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier, hymn: hymn)
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
        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier, lyrics: classic1151_preview.lyrics.verses)!
        viewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        viewModel.tabItems = [viewModel.currentTab, .music(EmptyView().eraseToAnyView())]
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier, hymn: hymn)
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

        let pdfView = DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(preloader: preloader, url: URL(string: "/en/hymn/h/1151/f=gtpdf")!))

        viewModel.currentTab = .music(HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.piano(pdfView.eraseToAnyView())])).eraseToAnyView())
        viewModel.tabItems = [.lyrics(EmptyView().eraseToAnyView()), viewModel.currentTab]
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        let bottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier, hymn: hymn)
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
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "temp", lyrics: [VerseEntity]())
        let bottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier, hymn: hymn)
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
