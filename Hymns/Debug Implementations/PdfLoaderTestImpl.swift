#if DEBUG
import Foundation
import PDFKit

/**
 * PDF Loader that only returns the stored sample pdf.
 */
class PdfLoaderTestImpl: PDFLoader {

    private static let pdfStore = [
        "/en/hymn/h/1151/f=ppdf": "Hymn 1151's Piano",
        "/en/hymn/h/1151/f=gtpdf": "Hymn 1151's Chords",
        "/en/hymn/h/3/f=ppdf": "Hymn 3's Piano",
        "/en/hymn/h/3/f=gtpdf": "Hymn 3's Chords",
        "/en/hymn/h/40/f=ppdf": "Hymn 40's Piano",
        "/en/hymn/h/40/f=gpdf": "Hymn 40's Guitar"]

    func load(url: URL) {
        // no-op
    }

    func get(url: URL) -> PDFDocument? {
        PdfLoaderTestImpl.createPdf(url)
    }

    static func createPdf(_ url: URL? = nil) -> PDFDocument? {
        PDFDocument(data: createPdfData(url))
    }

    static func createPdfData(_ url: URL?) -> Data {
        let storedResponse = url.flatMap { url in
            self.pdfStore[url.absoluteString]
        }

        let format = UIGraphicsPDFRendererFormat()
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
            ]
            let text: String
            if let storedResponse = storedResponse {
                text = storedResponse
            } else {
                text = "I'm a PDF!"
            }
            text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        }
        return data
    }
}
#endif
