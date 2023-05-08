import Combine
import Foundation
import PDFKit
import Resolver

/**
 * Asynchronously loads and caches PDF documents loaded from web URLs
 */
protocol PDFLoader {
    func load(url: URL)
    func get(url: URL) -> PDFDocument?
}

class PDFLoaderImpl: PDFLoader {

    private let analytics: FirebaseLogger
    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let session: URLSession
    private var cache = [URL: PDFDocument]()

    init(analytics: FirebaseLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         session: URLSession = Resolver.resolve()) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.mainQueue = mainQueue
        self.session = session
    }

    /**
     * Saves the `HTML` or `URL` for the current session.
     */
    func load(url: URL) {
        backgroundQueue.async {
            self.analytics.logPreloadMusicPdf(url: url)
            if let document = PDFDocument(url: url) {
                self.mainQueue.async {
                    self.cache[url] = document
                }
            }
        }
    }

    func get(url: URL) -> PDFDocument? {
        return cache[url]
    }
}

extension Resolver {
    public static func registerPDFLoader() {
        register { PDFLoaderImpl() as PDFLoader }.scope(.application)
    }
}
