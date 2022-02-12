import Foundation
import PDFKit
import Resolver

class DisplayHymnPdfViewModel: ObservableObject {

    @Published var pdfDocument: PDFDocument?

    private let analytics: AnalyticsLogger
    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let preloader: PDFLoader
    private let url: URL

    init(analytics: AnalyticsLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         preloader: PDFLoader = Resolver.resolve(),
         url: URL) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.mainQueue = mainQueue
        self.preloader = preloader
        self.url = url
    }

    func loadPdf() {
        if let preloadedDoc = preloader.get(url: url) {
            self.analytics.logDisplayMusicPdfSuccess(url: url)
            self.pdfDocument = preloadedDoc
        } else {
            backgroundQueue.async {
                self.analytics.logLoadMusicPdf(url: self.url)
                if let document = PDFDocument(url: self.url) {
                    self.mainQueue.async {
                        self.analytics.logDisplayMusicPdfSuccess(url: self.url)
                        self.pdfDocument = document
                    }
                } else if let fileURL = Bundle.main.url(forResource: "pdfErrorState", withExtension: "pdf") {
                    self.mainQueue.async {
                        self.analytics.logDisplayMusicPdfFailed(url: self.url)
                        self.pdfDocument = PDFDocument(url: fileURL)
                    }
                }
            }
        }
    }
}
