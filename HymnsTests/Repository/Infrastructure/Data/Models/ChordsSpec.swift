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
                    expect(target.words).to(haveCount(1))
                    expect(target.words[0].word).to(equal(""))
                    expect(target.words[0].chords).to(beNil())
                    expect(target.words[0].chordString).to(beNil())
                }
            }
            context("no chords found") {
                beforeEach {
                    target = ChordLine("With Christ in my vessel I will")
                }
                it("should be converted to chord words with empty chords") {
                    expect(target.words).to(haveCount(7))
                    expect(target.words.map { $0.word }).to(equal(["With", "Christ", "in", "my", "vessel", "I", "will"]))
                    expect(target.words.map { $0.chords }).to(equal([nil, nil, nil, nil, nil, nil, nil]))
                    expect(target.words.map { $0.chordString }).to(equal([nil, nil, nil, nil, nil, nil, nil]))
                }
            }
            context("empty chords found") {
                beforeEach {
                    target = ChordLine("[]With Christ in my vessel I will")
                }
                it("should extract the words out with empty chords (but not nil)") {
                    expect(target.words).to(haveCount(7))
                    expect(target.words.map { $0.word }).to(equal(["With", "Christ", "in", "my", "vessel", "I", "will"]))
                    expect(target.words.map { $0.chords }).to(equal([[""], [String](), [String](), [String](), [String](), [String](), [String]()]))
                    expect(target.words.map { $0.chordString }).to(equal([" ", " ", " ", " ", " ", " ", " "]))
                }
            }
            context("chords found") {
                beforeEach {
                    target = ChordLine("Un[G]til [Am - C]we are [D]sailing [G]hom[C]e. [G]")
                }
                it("should extract the chords out into ChordWords") {
                    expect(target.words).to(haveCount(6))
                    expect(target.words.map { $0.word }).to(equal(["Until", "we", "are", "sailing", "home.", ""]))
                    expect(target.words.map { $0.chords }).to(equal([["G"], ["Am - C"], [String](), ["D"], ["G", "C"], ["G"]]))
                    expect(target.words.map { $0.chordString }).to(equal(["G", "Am - C", " ", "D", "G C", "G"]))
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
