import Foundation
import PDFKit
import Resolver

class DisplayHymnPdfViewModel: ObservableObject {

    @Published var isLoading: Bool = true
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
            self.isLoading = false
        } else {
            self.isLoading = true
            self.analytics.logLoadMusicPdf(url: self.url)
            backgroundQueue.async {
                if let document = PDFDocument(url: self.url) {
                    self.analytics.logDisplayMusicPdfSuccess(url: self.url)
                    self.mainQueue.async {
                        self.isLoading = false
                        self.pdfDocument = document
                    }
                } else {
                    self.analytics.logDisplayMusicPdfFailed(url: self.url)
                    self.mainQueue.async {
                        self.isLoading = false
                        self.pdfDocument = nil
                    }
                }
            }
        }
    }
}
