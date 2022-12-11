import Combine
import Mockingbird
import Nimble
import PDFKit
import Quick
@testable import Hymns

class DisplayHymnPdfViewModelSpec: QuickSpec {

    override func spec() {
        describe("DisplayHymnPdfViewModel") {
            let testQueue = DispatchQueue(label: "test_queue")
            let url = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf")!
            let dummyPdf = createDummyPdf()
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
                            if #available(iOS 16.0, *) {
                                expect(target.pdfDocument!.string!).to(match("Drink! A river pure and clear that’s flowing from the throne Experience of Christ . As Food and Drink"))
                            } else {
                                expect(target.pdfDocument!.string!).to(equal("Drink! A river pure and clear that’s flowing from the throne Experience of Christ — As Food and Drink\n1151\n1. Drink! A riv er pure and clear that’s flow ing from the throne; 3􏰁􏰂􏰂􏰂􏰂C􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 G􏰀\n(Guitar: Capo 1)\n􏰁􏰂􏰂􏰂􏰂􏰃G 􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰀 􏰈􏰈􏰈\n         Eat! The tree of life with fruits a bun dant, rich ly grown; 5􏰁􏰂􏰂􏰂􏰂G 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 C􏰈 􏰈\n􏰈􏰈􏰈􏰈\nLook! No need of lamp nor sun nor moon to keep it bright, for\n 􏰄􏰄 􏰂􏰂 􏰈􏰅 􏰈7\n7􏰁􏰂􏰂G 􏰈D􏰈􏰈G􏰀􏰅C G􏰇 􏰆\nHere there is no night!\n      9\n􏰁􏰂􏰂􏰂􏰈􏰈 􏰈􏰈􏰈 􏰈􏰈􏰅􏰈􏰈􏰈􏰀\nChorus 􏰄\n􏰂G􏰄􏰄 G\n7\n  􏰆\n     (C) Do come, oh, do come, Says Spir it and the Bride:\n􏰄\n11􏰁􏰂􏰂􏰂􏰂C􏰈􏰄 􏰈 􏰈 􏰈 􏰈 􏰈􏰄 􏰈􏰅 􏰈 􏰈 􏰈 􏰀\n􏰄\nDo come, oh, do come, Let 􏰄\ndo come,\nhim\nG\nthat hear eth, cry.\n      􏰁􏰂􏰂􏰄 􏰈􏰄 􏰆􏰈􏰅􏰈􏰈 13􏰂􏰂G􏰈􏰈 􏰈􏰈􏰈\n􏰈C􏰈􏰈 and will Take\n2. Christ, our river, Christ, our water, springing from within;\nChrist, our tree, and Christ, the fruits, to be enjoyed therein, Christ, our day, and Christ, our light, and Christ, our morningstar:\nChrist, our everything!\n3. We are washing all our robes the tree of life to eat; “O Lord, Amen, Hallelujah!”—Jesus is so sweet!\nWe our spirits exercise, and thus experience Christ.\nWhat a Christ have we!\n4. Now we have a home so bright that outshines the sun, Where the brothers all unite and truly are one.\nJesus gets us all together, Him we now display\nIn the local church.\n      Do come, oh,\nLet him who thirsts\n􏰄􏰄 15􏰁􏰂􏰂􏰂􏰂G􏰈􏰈􏰈D􏰈􏰈􏰈G􏰀􏰅C G􏰇\n7\n 􏰆􏰆\n    free ly\nthe wa ter of life!\nwww.hymnal.net\n"))
                            }
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

    private func createDummyPdf() -> PDFDocument {
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
