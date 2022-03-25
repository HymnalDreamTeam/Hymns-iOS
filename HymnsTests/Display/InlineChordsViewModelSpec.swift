import Combine
import Mockingbird
import Nimble
import PDFKit
import Quick
@testable import Hymns

class InlineChordsViewModelSpec: QuickSpec {

    override func spec() {
        describe("InlineChordsViewModel") {
            let lyrics = [
                // Verse 1
                ChordLine("1"),
                ChordLine("[G]Drink! A river pure and clear"),
                ChordLine("That’s [G7]flowing from the throne;"),
                ChordLine("[C]Eat! The tree of life with fruits"),
                ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
                ChordLine(""),
                // Chorus
                ChordLine(""),
                ChordLine("  Do come, oh, do come,"),
                ChordLine("  Says [G7]Spirit and the Bride:"),
                ChordLine("  []Do come, oh, do come,"),
                ChordLine("  Let [B7]him who thirsts and [Em]will"),
                ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
                ChordLine(""),
                // Verse 3
                ChordLine("2"),
                ChordLine("Christ, our river, Christ, our water,"),
                ChordLine("Springing from within;"),
                ChordLine("Christ, our tree, and Christ, the fruits,"),
                ChordLine("To be enjoyed therein,"),
                ChordLine("Christ, our day, and Christ, our light,"),
                ChordLine("and Christ, our morningstar:"),
                ChordLine("Christ, our everything!")
            ]
            let dummyPdf = createDummyPdf()
            let testQueue = DispatchQueue(label: "test_queue")
            var preloader: PDFLoaderMock!
            var target: InlineChordsViewModel!

            beforeEach {
                preloader = mock(PDFLoader.self)
            }

            context("init without guitar url") {
                beforeEach {
                    target = InlineChordsViewModel(backgroundQueue: testQueue, chords: lyrics, guitarUrl: nil,
                                                   mainQueue: testQueue, preloader: preloader)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
                }
                it("should set pdf document to nil") {
                    expect(target.pdfDocument).to(beNil())
                }
                describe("load pdf") {
                    beforeEach {
                        target.loadPdf()
                    }
                    it("should set pdf document to nil") {
                        expect(target.pdfDocument).to(beNil())
                    }
                }
            }
            context("init with guitar url") {
                let guitarUrl = URL(string: "https://www.hymnal.net/Hymns/Hymnal/pdfs/e1151_g.pdf")!
                beforeEach {
                    target = InlineChordsViewModel(backgroundQueue: testQueue, chords: lyrics, guitarUrl: guitarUrl,
                                                   mainQueue: testQueue, preloader: preloader)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
                }
                it("should set pdf document to nil") {
                    expect(target.pdfDocument).to(beNil())
                }
                describe("load pdf") {
                    context("pdf preloaded") {
                        beforeEach {
                            given(preloader.get(url: guitarUrl)) ~> dummyPdf
                            target.loadPdf()
                        }
                        it("should set pdf document to the preloaded pdf") {
                            expect(target.pdfDocument).to(equal(dummyPdf))
                        }
                    }
                    context("pdf not preloaded") {
                        beforeEach {
                            given(preloader.get(url: guitarUrl)) ~> nil
                            target.loadPdf()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should show loaded pdf") {
                            expect(target.pdfDocument!.string!).to(equal("Drink! A river pure and clear that’s flowing from the throne Experience of Christ — As Food and Drink\n1151\n1. Drink! A riv er pure and clear that’s flow ing from the throne; 3􏰁􏰂􏰂􏰂􏰂C􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 G􏰀\n(Guitar: Capo 1)\n􏰁􏰂􏰂􏰂􏰂􏰃G 􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰈􏰀 􏰈􏰈􏰈\n         Eat! The tree of life with fruits a bun dant, rich ly grown; 5􏰁􏰂􏰂􏰂􏰂G 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 􏰈 C􏰈 􏰈\n􏰈􏰈􏰈􏰈\nLook! No need of lamp nor sun nor moon to keep it bright, for\n 􏰄􏰄 􏰂􏰂 􏰈􏰅 􏰈7\n7􏰁􏰂􏰂G 􏰈D􏰈􏰈G􏰀􏰅C G􏰇 􏰆\nHere there is no night!\n      9\n􏰁􏰂􏰂􏰂􏰈􏰈 􏰈􏰈􏰈 􏰈􏰈􏰅􏰈􏰈􏰈􏰀\nChorus 􏰄\n􏰂G􏰄􏰄 G\n7\n  􏰆\n     (C) Do come, oh, do come, Says Spir it and the Bride:\n􏰄\n11􏰁􏰂􏰂􏰂􏰂C􏰈􏰄 􏰈 􏰈 􏰈 􏰈 􏰈􏰄 􏰈􏰅 􏰈 􏰈 􏰈 􏰀\n􏰄\nDo come, oh, do come, Let 􏰄\ndo come,\nhim\nG\nthat hear eth, cry.\n      􏰁􏰂􏰂􏰄 􏰈􏰄 􏰆􏰈􏰅􏰈􏰈 13􏰂􏰂G􏰈􏰈 􏰈􏰈􏰈\n􏰈C􏰈􏰈 and will Take\n2. Christ, our river, Christ, our water, springing from within;\nChrist, our tree, and Christ, the fruits, to be enjoyed therein, Christ, our day, and Christ, our light, and Christ, our morningstar:\nChrist, our everything!\n3. We are washing all our robes the tree of life to eat; “O Lord, Amen, Hallelujah!”—Jesus is so sweet!\nWe our spirits exercise, and thus experience Christ.\nWhat a Christ have we!\n4. Now we have a home so bright that outshines the sun, Where the brothers all unite and truly are one.\nJesus gets us all together, Him we now display\nIn the local church.\n      Do come, oh,\nLet him who thirsts\n􏰄􏰄 15􏰁􏰂􏰂􏰂􏰂G􏰈􏰈􏰈D􏰈􏰈􏰈G􏰀􏰅C G􏰇\n7\n 􏰆􏰆\n    free ly\nthe wa ter of life!\nwww.hymnal.net\n"))
                        }
                    }
                }
            }
            context("init with malformed guitar url") {
                let guitarUrl = URL(string: "https://nopdfhere.pdf")!
                beforeEach {
                    target = InlineChordsViewModel(backgroundQueue: testQueue, chords: lyrics, guitarUrl: guitarUrl,
                                                   mainQueue: testQueue, preloader: preloader)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
                }
                it("should set pdf document to nil") {
                    expect(target.pdfDocument).to(beNil())
                }
                describe("load pdf") {
                    beforeEach {
                        given(preloader.get(url: guitarUrl)) ~> nil
                        target.loadPdf()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set pdfDocument to nil") {
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
