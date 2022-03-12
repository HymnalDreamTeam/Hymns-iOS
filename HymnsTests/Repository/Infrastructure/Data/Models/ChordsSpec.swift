import Quick
import Nimble
@testable import Hymns

class ChordsSpec: QuickSpec {

    override func spec() {
        describe("ChordLine") {
            var target: ChordLine!
            context("empty string") {
                beforeEach {
                    target = ChordLine("")
                }
                it("should be converted to empty ChordWord") {
                    expect(target.words).to(equal([ChordWord("", chords: nil)]))
                }
            }
            context("no chords found") {
                beforeEach {
                    target = ChordLine("With Christ in my vessel I will")
                }
                it("should be converted to chord words with empty chords") {
                    expect(target.words).to(equal([ChordWord("With", chords: nil), ChordWord("Christ", chords: nil),
                                                   ChordWord("in", chords: nil), ChordWord("my", chords: nil),
                                                   ChordWord("vessel", chords: nil), ChordWord("I", chords: nil),
                                                   ChordWord("will", chords: nil)]))
                }
            }
            context("empty chords found") {
                beforeEach {
                    target = ChordLine("[]With Christ in my vessel I will")
                }
                it("should extract the words out with empty chords (but not nil)") {
                    expect(target.words).to(equal([ChordWord("With", chords: [""]), ChordWord("Christ"), ChordWord("in"), ChordWord("my"),
                                                   ChordWord("vessel"), ChordWord("I"), ChordWord("will")]))
                }
            }
            context("chords found") {
                beforeEach {
                    target = ChordLine("Un[G]til we are [D]sailing [G]hom[C]e. [G]")
                }
                it("should extract the chords out into ChordWords") {
                    expect(target.words).to(equal([ChordWord("Until", chords: ["G"]), ChordWord("we"), ChordWord("are"),
                                                   ChordWord("sailing", chords: ["D"]), ChordWord("home.", chords: ["G", "C"]),
                                                   ChordWord("", chords: ["G"])]))
                }
            }
        }
        describe("ChordWord") {
            var target: ChordWord!
            context("default initializer") {
                beforeEach {
                    target = ChordWord("word")
                }
                it("should initialize chords with empty list") {
                    expect(target.word).to(equal("word"))
                    expect(target.chords).to(equal([String]()))
                    expect(target.chordString).to(equal(" "))
                }
            }
            context("empty chords array") {
                var target: ChordWord!
                beforeEach {
                    target = ChordWord("word", chords: [String]())
                }
                it("should have an empty space as chord string") {
                    expect(target.word).to(equal("word"))
                    expect(target.chords).to(equal([String]()))
                    expect(target.chordString).to(equal(" "))
                }
            }
            context("nil chords") {
                beforeEach {
                    target = ChordWord("word", chords: nil)
                }
                it("should have nil chord string") {
                    expect(target.word).to(equal("word"))
                    expect(target.chords).to(beNil())
                    expect(target.chordString).to(beNil())
                }
            }
            context("array of empty chords") {
                var target: ChordWord!
                beforeEach {
                    target = ChordWord("word", chords: ["", "", " "])
                }
                it("should have an empty space as chord string") {
                    expect(target.word).to(equal("word"))
                    expect(target.chords).to(equal(["", "", " "]))
                    expect(target.chordString).to(equal(" "))
                }
            }
            context("legitimate chords") {
                var target: ChordWord!
                beforeEach {
                    target = ChordWord("word", chords: ["G", "C", "G"])
                }
                it("should join chords with a space") {
                    expect(target.word).to(equal("word"))
                    expect(target.chords).to(equal(["G", "C", "G"]))
                    expect(target.chordString).to(equal("G C G"))
                }
            }
        }
    }
}
