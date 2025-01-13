import PDFKit
import Prefire
import SwiftUI

struct PdfViewer: UIViewRepresentable {

    private let pdfDocument: PDFDocument

    init(_ pdfDocument: PDFDocument) {
        self.pdfDocument = pdfDocument
    }

    func makeUIView(context: Context) -> PDFView {
        return PDFView()
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdfDocument
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.sizeToFit()
        pdfView.autoScales = true
    }
}

#if DEBUG
struct PdfViewer_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        PdfViewer(PDFDocument(data: createPdfData())!)
    }

    static func createPdfData() -> Data {
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
            let text = "I'm a PDF!"
            text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        }
        return data
    }
}
#endif
