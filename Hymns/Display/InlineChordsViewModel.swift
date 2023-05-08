import Combine
import Foundation
import PDFKit
import Resolver

class InlineChordsViewModel: ObservableObject {

    @Published var chords: [ChordLine] = [ChordLine]()
    @Published var pdfDocument: PDFDocument?

    private let analytics: FirebaseLogger
    private let backgroundQueue: DispatchQueue
    private let guitarUrl: URL?
    private let mainQueue: DispatchQueue
    private let preloader: PDFLoader

    init(analytics: FirebaseLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         chords: [ChordLine],
         guitarUrl: URL?,
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         preloader: PDFLoader = Resolver.resolve()) {
        self.backgroundQueue = backgroundQueue
        self.analytics = analytics
        self.chords = chords
        self.guitarUrl = guitarUrl
        self.mainQueue = mainQueue
        self.preloader = preloader
    }

    func loadPdf() {
        guard let guitarUrl = guitarUrl else {
            return
        }

        if let preloadedDoc = preloader.get(url: guitarUrl) {
            self.analytics.logDisplayMusicPdfSuccess(url: guitarUrl)
            self.pdfDocument = preloadedDoc
        } else {
            self.analytics.logLoadMusicPdf(url: guitarUrl)
            backgroundQueue.async {
                if let document = PDFDocument(url: guitarUrl) {
                    self.analytics.logDisplayMusicPdfSuccess(url: guitarUrl)
                    self.mainQueue.async {
                        self.pdfDocument = document
                    }
                } else {
                    self.analytics.logDisplayMusicPdfFailed(url: guitarUrl)
                    self.mainQueue.async {
                        self.pdfDocument = nil
                    }
                }
            }
        }
    }
}
