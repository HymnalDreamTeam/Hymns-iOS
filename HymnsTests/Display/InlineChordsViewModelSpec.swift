import Combine
import Mockingbird
import Nimble
import PDFKit
import Quick
@testable import Hymns

class InlineChordsViewModelSpec: QuickSpec {

    override func spec() {
        describe("InlineChordsViewModel") {
            var target: InlineChordsViewModel!
            context("chords exist") {
                let chordLines = [
                    // Verse 1
                    ChordLineEntity(createChordLine("1")),
                    ChordLineEntity(createChordLine("[G]Drink! A river pure and clear")),
                    ChordLineEntity(createChordLine("That’s [G7]flowing from the throne;")),
                    ChordLineEntity(createChordLine("[C#m7]Eat! The tree of life with fruits")),
                    ChordLineEntity(createChordLine("[G]Here there [D7]is no [G-C-G]night!")),
                    ChordLineEntity(createChordLine("")),
                    // Chorus
                    ChordLineEntity(createChordLine("")),
                    ChordLineEntity(createChordLine("  Do come, oh, do come,")),
                    ChordLineEntity(createChordLine("  Says [G7]Spirit and the Bride:")),
                    ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
                    ChordLineEntity(createChordLine("  Let [B7]him who thirsts and [Em]will")),
                    ChordLineEntity(createChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!")),
                    ChordLineEntity(createChordLine(""))
                ]
                beforeEach {
                    target = InlineChordsViewModel(chordLines: chordLines)
                }
                it("should set the chords to the passed-in chords") {
                    expect(String(describing: target.chordLines))
                        .to(equal("[[word: 1, chords: nil, fontSize: 15.0], [word: Drink!, chords: Optional(\"G\"), fontSize: 15.0, word: A, chords: Optional(\"\"), fontSize: 15.0, word: river, chords: Optional(\"\"), fontSize: 15.0, word: pure, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: clear, chords: Optional(\"\"), fontSize: 15.0], [word: That’s, chords: Optional(\"\"), fontSize: 15.0, word: flowing, chords: Optional(\"G7\"), fontSize: 15.0, word: from, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: throne;, chords: Optional(\"\"), fontSize: 15.0], [word: Eat!, chords: Optional(\"C#m7\"), fontSize: 15.0, word: The, chords: Optional(\"\"), fontSize: 15.0, word: tree, chords: Optional(\"\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life, chords: Optional(\"\"), fontSize: 15.0, word: with, chords: Optional(\"\"), fontSize: 15.0, word: fruits, chords: Optional(\"\"), fontSize: 15.0], [word: Here, chords: Optional(\"G\"), fontSize: 15.0, word: there, chords: Optional(\"\"), fontSize: 15.0, word: is, chords: Optional(\"D7\"), fontSize: 15.0, word: no, chords: Optional(\"\"), fontSize: 15.0, word: night!, chords: Optional(\"G-C-G\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: Do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0, word: oh,, chords: nil, fontSize: 15.0, word: do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0], [word: Says, chords: Optional(\"\"), fontSize: 15.0, word: Spirit, chords: Optional(\"G7\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: Bride:, chords: Optional(\"\"), fontSize: 15.0], [word: Do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0, word: oh,, chords: Optional(\"\"), fontSize: 15.0, word: do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0], [word: Let, chords: Optional(\"\"), fontSize: 15.0, word: him, chords: Optional(\"B7\"), fontSize: 15.0, word: who, chords: Optional(\"\"), fontSize: 15.0, word: thirsts, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: will, chords: Optional(\"Em\"), fontSize: 15.0], [word: Take, chords: Optional(\"\"), fontSize: 15.0, word: freely, chords: Optional(\"G\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: water, chords: Optional(\"D\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life!, chords: Optional(\"GCG\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0]]"))
                }
                it("should have the default transposition label text and color") {
                    expect(target.transpositionLabelText).to(equal("Transpose"))
                    expect(target.transpositionLabelColor).to(equal(.primary))
                }
                describe("transpose") {
                    describe("up one full step") {
                        beforeEach {
                            target.transpose(2)
                        }
                        it("should transpose all the chords in the lyrics") {
                            let transposedLyrics = [
                                // Verse 1
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("1"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[A]Drink! A river pure and clear"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("That’s [A7]flowing from the throne;"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[D#m7]Eat! The tree of life with fruits"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[A]Here there [E7]is no [A-D-A]night!"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine(""))),
                                // Chorus
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine(""))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Do come, oh, do come,"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Says [A7]Spirit and the Bride:"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  []Do come, oh, do come,"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Let [C#7]him who thirsts and [F#m]will"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Take [A]freely the [E]water of [A]l[D]i[A]fe!"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("")))
                            ]
                            zip(transposedLyrics, target.chordLines).forEach { (expectedLine, actualLine) in
                                zip(expectedLine.chordWords, actualLine.chordWords).forEach { (expectedWord, actualWord) in
                                    expect(actualWord.word).to(equal(expectedWord.word))
                                    if expectedWord.chords == nil {
                                        expect(actualWord.chords).to(beNil())
                                    } else {
                                        expect(actualWord.chords).to(equal(expectedWord.chords))
                                    }
                                    expect(actualWord.fontSize).to(equal(expectedWord.fontSize))
                                }
                            }
                        }
                        it("should set transposition label and color") {
                            expect(target.transpositionLabelText).to(equal("Capo +2"))
                            expect(target.transpositionLabelColor).to(equal(.accentColor))
                        }
                        describe("reset transposition") {
                            beforeEach {
                                target.resetTransposition()
                            }
                            it("should reset all the chords in the lyrics") {
                                expect(String(describing: target.chordLines))
                                    .to(equal("[[word: 1, chords: nil, fontSize: 15.0], [word: Drink!, chords: Optional(\"G\"), fontSize: 15.0, word: A, chords: Optional(\"\"), fontSize: 15.0, word: river, chords: Optional(\"\"), fontSize: 15.0, word: pure, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: clear, chords: Optional(\"\"), fontSize: 15.0], [word: That’s, chords: Optional(\"\"), fontSize: 15.0, word: flowing, chords: Optional(\"G7\"), fontSize: 15.0, word: from, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: throne;, chords: Optional(\"\"), fontSize: 15.0], [word: Eat!, chords: Optional(\"Dbm7\"), fontSize: 15.0, word: The, chords: Optional(\"\"), fontSize: 15.0, word: tree, chords: Optional(\"\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life, chords: Optional(\"\"), fontSize: 15.0, word: with, chords: Optional(\"\"), fontSize: 15.0, word: fruits, chords: Optional(\"\"), fontSize: 15.0], [word: Here, chords: Optional(\"G\"), fontSize: 15.0, word: there, chords: Optional(\"\"), fontSize: 15.0, word: is, chords: Optional(\"D7\"), fontSize: 15.0, word: no, chords: Optional(\"\"), fontSize: 15.0, word: night!, chords: Optional(\"G-C-G\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: Do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0, word: oh,, chords: nil, fontSize: 15.0, word: do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0], [word: Says, chords: Optional(\"\"), fontSize: 15.0, word: Spirit, chords: Optional(\"G7\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: Bride:, chords: Optional(\"\"), fontSize: 15.0], [word: Do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0, word: oh,, chords: Optional(\"\"), fontSize: 15.0, word: do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0], [word: Let, chords: Optional(\"\"), fontSize: 15.0, word: him, chords: Optional(\"B7\"), fontSize: 15.0, word: who, chords: Optional(\"\"), fontSize: 15.0, word: thirsts, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: will, chords: Optional(\"Em\"), fontSize: 15.0], [word: Take, chords: Optional(\"\"), fontSize: 15.0, word: freely, chords: Optional(\"G\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: water, chords: Optional(\"D\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life!, chords: Optional(\"GCG\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0]]"))
                            }
                            it("should set transposition label and color") {
                                expect(target.transpositionLabelText).to(equal("Transpose"))
                                expect(target.transpositionLabelColor).to(equal(.primary))
                            }
                        }
                    }
                    describe("down three full steps") {
                        beforeEach {
                            target.transpose(-3)
                        }
                        it("should transpose all the chords in the lyrics") {
                            let transposedLyrics = [
                                // Verse 1
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("1"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[E]Drink! A river pure and clear"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("That’s [E7]flowing from the throne;"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[Bbm7]Eat! The tree of life with fruits"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("[E]Here there [B7]is no [E-A-E]night!"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine(""))),
                                // Chorus
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine(""))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Do come, oh, do come,"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Says [E7]Spirit and the Bride:"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  []Do come, oh, do come,"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Let [Ab7]him who thirsts and [Dbm]will"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("  Take [E]freely the [B]water of [E]l[A]i[E]fe!"))),
                                ChordLineViewModel(chordLine: ChordLineEntity(createChordLine("")))
                            ]
                            zip(transposedLyrics, target.chordLines).forEach { (expectedLine, actualLine) in
                                zip(expectedLine.chordWords, actualLine.chordWords).forEach { (expectedWord, actualWord) in
                                    expect(actualWord.word).to(equal(expectedWord.word))
                                    if expectedWord.chords == nil {
                                        expect(actualWord.chords).to(beNil())
                                    } else {
                                        expect(actualWord.chords).to(equal(expectedWord.chords))
                                    }
                                    expect(actualWord.fontSize).to(equal(expectedWord.fontSize))
                                }
                            }
                        }
                        it("should set transposition label and color") {
                            expect(target.transpositionLabelText).to(equal("Capo -3"))
                            expect(target.transpositionLabelColor).to(equal(.accentColor))
                        }
                        describe("reset transposition") {
                            beforeEach {
                                target.resetTransposition()
                            }
                            it("should reset all the chords in the lyrics") {
                                expect(String(describing: target.chordLines))
                                    .to(equal("[[word: 1, chords: nil, fontSize: 15.0], [word: Drink!, chords: Optional(\"G\"), fontSize: 15.0, word: A, chords: Optional(\"\"), fontSize: 15.0, word: river, chords: Optional(\"\"), fontSize: 15.0, word: pure, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: clear, chords: Optional(\"\"), fontSize: 15.0], [word: That’s, chords: Optional(\"\"), fontSize: 15.0, word: flowing, chords: Optional(\"G7\"), fontSize: 15.0, word: from, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: throne;, chords: Optional(\"\"), fontSize: 15.0], [word: Eat!, chords: Optional(\"C#m7\"), fontSize: 15.0, word: The, chords: Optional(\"\"), fontSize: 15.0, word: tree, chords: Optional(\"\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life, chords: Optional(\"\"), fontSize: 15.0, word: with, chords: Optional(\"\"), fontSize: 15.0, word: fruits, chords: Optional(\"\"), fontSize: 15.0], [word: Here, chords: Optional(\"G\"), fontSize: 15.0, word: there, chords: Optional(\"\"), fontSize: 15.0, word: is, chords: Optional(\"D7\"), fontSize: 15.0, word: no, chords: Optional(\"\"), fontSize: 15.0, word: night!, chords: Optional(\"G-C-G\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: Do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0, word: oh,, chords: nil, fontSize: 15.0, word: do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0], [word: Says, chords: Optional(\"\"), fontSize: 15.0, word: Spirit, chords: Optional(\"G7\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: Bride:, chords: Optional(\"\"), fontSize: 15.0], [word: Do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0, word: oh,, chords: Optional(\"\"), fontSize: 15.0, word: do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0], [word: Let, chords: Optional(\"\"), fontSize: 15.0, word: him, chords: Optional(\"B7\"), fontSize: 15.0, word: who, chords: Optional(\"\"), fontSize: 15.0, word: thirsts, chords: Optional(\"\"), fontSize: 15.0, word: and, chords: Optional(\"\"), fontSize: 15.0, word: will, chords: Optional(\"Em\"), fontSize: 15.0], [word: Take, chords: Optional(\"\"), fontSize: 15.0, word: freely, chords: Optional(\"G\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: water, chords: Optional(\"D\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life!, chords: Optional(\"GCG\"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0]]"))
                            }
                            it("should set transposition label and color") {
                                expect(target.transpositionLabelText).to(equal("Transpose"))
                                expect(target.transpositionLabelColor).to(equal(.primary))
                            }
                        }
                    }
                }
            }
            context("chords don't exist") {
                let chordLines = [
                    // Verse 1
                    ChordLineEntity(createChordLine("1")),
                    ChordLineEntity(createChordLine("Drink! A river pure and clear")),
                    ChordLineEntity(createChordLine("That’s flowing from the throne;")),
                    ChordLineEntity(createChordLine("Eat! The tree of life with fruits")),
                    ChordLineEntity(createChordLine("Here there is no night!")),
                    ChordLineEntity(createChordLine("")),
                    // Chorus
                    ChordLineEntity(createChordLine("")),
                    ChordLineEntity(createChordLine("  Do come, oh, do come,")),
                    ChordLineEntity(createChordLine("  Says Spirit and the Bride:")),
                    ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
                    ChordLineEntity(createChordLine("  Let him who thirsts and will")),
                    ChordLineEntity(createChordLine("  Take []freely the []water of []l[]i[]fe!")),
                    ChordLineEntity(createChordLine(""))
                ]
                beforeEach {
                    target = InlineChordsViewModel(chordLines: chordLines)
                }
                it("should set the chords to the passed-in chords") {
                    expect(String(describing: target.chordLines))
                        .to(equal("[[word: 1, chords: nil, fontSize: 15.0], [word: Drink!, chords: nil, fontSize: 15.0, word: A, chords: nil, fontSize: 15.0, word: river, chords: nil, fontSize: 15.0, word: pure, chords: nil, fontSize: 15.0, word: and, chords: nil, fontSize: 15.0, word: clear, chords: nil, fontSize: 15.0], [word: That’s, chords: nil, fontSize: 15.0, word: flowing, chords: nil, fontSize: 15.0, word: from, chords: nil, fontSize: 15.0, word: the, chords: nil, fontSize: 15.0, word: throne;, chords: nil, fontSize: 15.0], [word: Eat!, chords: nil, fontSize: 15.0, word: The, chords: nil, fontSize: 15.0, word: tree, chords: nil, fontSize: 15.0, word: of, chords: nil, fontSize: 15.0, word: life, chords: nil, fontSize: 15.0, word: with, chords: nil, fontSize: 15.0, word: fruits, chords: nil, fontSize: 15.0], [word: Here, chords: nil, fontSize: 15.0, word: there, chords: nil, fontSize: 15.0, word: is, chords: nil, fontSize: 15.0, word: no, chords: nil, fontSize: 15.0, word: night!, chords: nil, fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: , chords: nil, fontSize: 15.0], [word: Do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0, word: oh,, chords: nil, fontSize: 15.0, word: do, chords: nil, fontSize: 15.0, word: come,, chords: nil, fontSize: 15.0], [word: Says, chords: nil, fontSize: 15.0, word: Spirit, chords: nil, fontSize: 15.0, word: and, chords: nil, fontSize: 15.0, word: the, chords: nil, fontSize: 15.0, word: Bride:, chords: nil, fontSize: 15.0], [word: Do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0, word: oh,, chords: Optional(\"\"), fontSize: 15.0, word: do, chords: Optional(\"\"), fontSize: 15.0, word: come,, chords: Optional(\"\"), fontSize: 15.0], [word: Let, chords: nil, fontSize: 15.0, word: him, chords: nil, fontSize: 15.0, word: who, chords: nil, fontSize: 15.0, word: thirsts, chords: nil, fontSize: 15.0, word: and, chords: nil, fontSize: 15.0, word: will, chords: nil, fontSize: 15.0], [word: Take, chords: Optional(\"\"), fontSize: 15.0, word: freely, chords: Optional(\"\"), fontSize: 15.0, word: the, chords: Optional(\"\"), fontSize: 15.0, word: water, chords: Optional(\"\"), fontSize: 15.0, word: of, chords: Optional(\"\"), fontSize: 15.0, word: life!, chords: Optional(\"  \"), fontSize: 15.0], [word: , chords: nil, fontSize: 15.0]]"))
                }
                it("should have a nil transposition label") {
                    expect(target.transpositionLabelText).to(beNil())
                }
            }
        }
    }
}
