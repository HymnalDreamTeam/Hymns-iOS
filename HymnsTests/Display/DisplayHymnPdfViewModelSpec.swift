import Combine
import Mockingbird
import Nimble
import PDFKit
import Quick
@testable import Hymns

class DisplayHymnPdfViewModelSpec: QuickSpec {

    override class func spec() {
        describe("DisplayHymnPdfViewModel") {
            let testQueue = DispatchQueue(label: "test_queue")
            let url = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf")!
            let dummyPdf = Self.createDummyPdf()
            var preloader: PDFLoaderMock!
            var target: DisplayHymnPdfViewModel!
            beforeEach {
                preloader = mock(PDFLoader.self)
            }
            describe("loading pdf") {
                context("pdf found") {
                    beforeEach {
                        let url = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf")!
                        target = DisplayHymnPdfViewModel(backgroundQueue: testQueue, mainQueue: testQueue, preloader: preloader, url: url)
                    }
                    context("pdf already preloaded") {
                        beforeEach {
                            given(preloader.get(url: url)) ~> dummyPdf
                            target.loadPdf()
                        }
                        it("should set pdf using preloaded document") {
                            expect(target.isLoading).to(beFalse())
                            expect(target.pdfDocument).to(be(dummyPdf))
                        }
                    }
                    context("pdf not preloaded") {
                        beforeEach {
                            given(preloader.get(url: url)) ~> nil
                            target.loadPdf()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should show loaded pdf") {
                            expect(target.isLoading).to(beFalse())
                            expect(target.pdfDocument!.string!).to(match("Drink! A river pure and clear that’s flowing from the throne"))
                        }
                    }
                }
                context("pdf not found") {
                    beforeEach {
                        let url = URL(string: "https://nopdfhere.pdf")!
                        target = DisplayHymnPdfViewModel(backgroundQueue: testQueue, mainQueue: testQueue, preloader: preloader, url: url)
                        target.loadPdf()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should show error pdf") {
                        expect(target.isLoading).to(beFalse())
                        expect(target.pdfDocument).to(beNil())
                    }
                }
            }
        }
    }

    private class func createDummyPdf() -> PDFDocument {
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
        return PDFDocument(data: data)!
    }
}
