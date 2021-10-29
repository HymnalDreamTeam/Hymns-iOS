import PDFKit
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DisplayHymnPdfSnapshots: XCTestCase {

    var preloader: PDFLoader!
    var viewModel: DisplayHymnViewModel!

    override func setUp() {
        super.setUp()
        preloader = PdfLoaderTestImpl()
        viewModel = DisplayHymnViewModel(hymnToDisplay: hymn1151_identifier, pdfPreloader: preloader)
    }

    func test_classic1151_chords() {
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false
        viewModel.currentTab = .chords(DisplayHymnPdfView(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=gtpdf")!,
                                                          pdfPreloader: preloader).eraseToAnyView())
        viewModel.tabItems = [
            .lyrics(HymnLyricsView(viewModel: HymnLyricsViewModel(hymnToDisplay: hymn1151_identifier)).maxSize().eraseToAnyView()),
            viewModel.currentTab,
            .guitar(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=pdf")!).eraseToAnyView()),
            .piano(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=ppdf")!).eraseToAnyView())]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        sleep(2)
        assertVersionedSnapshot(matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_classic1151_guitar() {
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false
        viewModel.currentTab = .guitar(DisplayHymnPdfView(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=ppdf")!,
                                                          pdfPreloader: preloader).eraseToAnyView())
        viewModel.tabItems = [
            .lyrics(HymnLyricsView(viewModel: HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)).maxSize().eraseToAnyView()),
            .chords(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=gtpdf")!).eraseToAnyView()),
            viewModel.currentTab,
            .piano(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=ppdf")!).eraseToAnyView())]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        sleep(2)
        assertVersionedSnapshot(matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }

    func test_classic1151_piano() {
        viewModel.isLoaded = true
        viewModel.title = "Hymn 1151"
        viewModel.isFavorited = false
        viewModel.currentTab = .piano(DisplayHymnPdfView(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=ppdf")!,
                                                         pdfPreloader: preloader).eraseToAnyView())
        viewModel.tabItems = [
            .lyrics(HymnLyricsView(viewModel: HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)).maxSize().eraseToAnyView()),
            .chords(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=gtpdf")!).eraseToAnyView()),
            .guitar(PDFViewer(url: URL(string: "http://www.hymnal.net/en/hymn/h/1151/f=pdf")!).eraseToAnyView()),
            viewModel.currentTab]
        viewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: hymn1151_identifier)
        sleep(2)
        assertVersionedSnapshot(matching: DisplayHymnView(viewModel: viewModel).ignoresSafeArea(), as: .swiftUiImage())
    }
}
