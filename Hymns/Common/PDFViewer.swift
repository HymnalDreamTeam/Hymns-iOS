import SwiftUI
import PDFKit

struct PDFViewer: UIViewRepresentable {

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
