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
            var target: InlineChordsViewModel!

            context("init") {
                beforeEach {
                    target = InlineChordsViewModel(chords: lyrics)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
                }
            }
        }
    }
}
