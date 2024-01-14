import PDFKit
import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DisplayHymnPdfSnapshots: XCTestCase {

    var preloader: PDFLoader!

    override func setUp() {
        super.setUp()
        preloader = PdfLoaderTestImpl()
    }

    func test_loading() {
        let view = DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: URL(string: "http://www.dummylink.com")!)).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }

    func test_displayError() {
        let errorViewModel = DisplayHymnPdfViewModel(url: URL(string: "http://www.dummylink.com")!)
        errorViewModel.isLoading = false
        let view = DisplayHymnPdfView(viewModel: errorViewModel).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }

    func test_displayPdf() {
        let view = DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(preloader: preloader, url: URL(string: "/en/hymn/h/1151/f=gtpdf")!)).ignoresSafeArea()
        assertVersionedSnapshot(matching: view, as: .image(layout: .sizeThatFits))
    }
}
