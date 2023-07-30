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
                var lyrics = [ChordLine]()
                beforeEach {
                    lyrics = [
                        // Verse 1
                        ChordLine("1"),
                        ChordLine("[G]Drink! A river pure and clear"),
                        ChordLine("That’s [G7]flowing from the throne;"),
                        ChordLine("[C#m7]Eat! The tree of life with fruits"),
                        ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
                        ChordLine(""),
                        // Chorus
                        ChordLine(""),
                        ChordLine("  Do come, oh, do come,"),
                        ChordLine("  Says [G7]Spirit and the Bride:"),
                        ChordLine("  []Do come, oh, do come,"),
                        ChordLine("  Let [B7]him who thirsts and [Em]will"),
                        ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
                        ChordLine("")
                    ]
                    target = InlineChordsViewModel(chords: lyrics)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
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
                                ChordLine("1"),
                                ChordLine("[A]Drink! A river pure and clear"),
                                ChordLine("That’s [A7]flowing from the throne;"),
                                ChordLine("[D#m7]Eat! The tree of life with fruits"),
                                ChordLine("[A]Here there [E7]is no [A-D-A]night!"),
                                ChordLine(""),
                                // Chorus
                                ChordLine(""),
                                ChordLine("  Do come, oh, do come,"),
                                ChordLine("  Says [A7]Spirit and the Bride:"),
                                ChordLine("  []Do come, oh, do come,"),
                                ChordLine("  Let [C#7]him who thirsts and [F#m]will"),
                                ChordLine("  Take [A]freely the [E]water of [A]l[D]i[A]fe!"),
                                ChordLine("")
                            ]
                            zip(transposedLyrics, target.chords).forEach { (expectedLine, actualLine) in
                                zip(expectedLine.words, actualLine.words).forEach { (expectedWord, actualWord) in
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
                                expect(target.chords).to(equal(lyrics))
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
                                ChordLine("1"),
                                ChordLine("[E]Drink! A river pure and clear"),
                                ChordLine("That’s [E7]flowing from the throne;"),
                                ChordLine("[Bbm7]Eat! The tree of life with fruits"),
                                ChordLine("[E]Here there [B7]is no [E-A-E]night!"),
                                ChordLine(""),
                                // Chorus
                                ChordLine(""),
                                ChordLine("  Do come, oh, do come,"),
                                ChordLine("  Says [E7]Spirit and the Bride:"),
                                ChordLine("  []Do come, oh, do come,"),
                                ChordLine("  Let [Ab7]him who thirsts and [Dbm]will"),
                                ChordLine("  Take [E]freely the [B]water of [E]l[A]i[E]fe!"),
                                ChordLine("")
                            ]
                            zip(transposedLyrics, target.chords).forEach { (expectedLine, actualLine) in
                                zip(expectedLine.words, actualLine.words).forEach { (expectedWord, actualWord) in
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
                                expect(target.chords).to(equal(lyrics))
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
                let lyrics = [
                    // Verse 1
                    ChordLine("1"),
                    ChordLine("Drink! A river pure and clear"),
                    ChordLine("That’s flowing from the throne;"),
                    ChordLine("Eat! The tree of life with fruits"),
                    ChordLine("Here there is no night!"),
                    ChordLine(""),
                    // Chorus
                    ChordLine(""),
                    ChordLine("  Do come, oh, do come,"),
                    ChordLine("  Says Spirit and the Bride:"),
                    ChordLine("  []Do come, oh, do come,"),
                    ChordLine("  Let him who thirsts and will"),
                    ChordLine("  Take []freely the []water of []l[]i[]fe!"),
                    ChordLine("")
                ]
                beforeEach {
                    target = InlineChordsViewModel(chords: lyrics)
                }
                it("should set the chords to the passed-in chords") {
                    expect(target.chords).to(equal(lyrics))
                }
                it("should have a nil transposition label") {
                    expect(target.transpositionLabelText).to(beNil())
                }
            }
        }
    }
}
