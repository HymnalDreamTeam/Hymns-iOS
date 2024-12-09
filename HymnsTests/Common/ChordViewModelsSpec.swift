import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

class ChordViewModelSpec: QuickSpec {

    override class func spec() {
        describe("ChordLineViewModel") {
            var target: ChordLineViewModel!
            describe("init") {
                context("has one chord") {
                    let chordLine = ChordLineEntity([ChordWordEntity("word 1"), 
                                                     ChordWordEntity("word 2", chords: "C"),
                                                     ChordWordEntity("word 3")])
                    beforeEach {
                        target = ChordLineViewModel(chordLine: chordLine)
                    }
                    it("should have chords") {
                        expect(target.hasChords).to(beTrue())
                    }
                    it("should set chords correctly") {
                        expect(target.chordWords.map {$0.chords}).to(equal(["", "C", ""]))
                    }
                }
                context("has two chord") {
                    let chordLine = ChordLineEntity([ChordWordEntity("word 1", chords: "D"), 
                                                     ChordWordEntity("word 2", chords: "C"),
                                                     ChordWordEntity("word 3")])
                    beforeEach {
                        target = ChordLineViewModel(chordLine: chordLine)
                    }
                    it("should have chords") {
                        expect(target.hasChords).to(beTrue())
                    }
                    it("should set chords correctly") {
                        expect(target.chordWords.map {$0.chords}).to(equal(["D", "C", ""]))
                    }
                }
                context("does not have chords") {
                    let chordLine = ChordLineEntity([ChordWordEntity("word 1"), 
                                                     ChordWordEntity("word 2"),
                                                     ChordWordEntity("word 3")])
                    beforeEach {
                        target = ChordLineViewModel(chordLine: chordLine)
                    }
                    it("should not have chords") {
                        expect(target.hasChords).to(beFalse())
                    }
                    it("should set chords correctly") {
                        expect(target.chordWords.map {$0.chords}).to(equal([nil, nil, nil]))
                    }
                }
                describe("transpose") {
                    let chordLine = ChordLineEntity([ChordWordEntity("word 1", chords: "D"), 
                                                     ChordWordEntity("word 2", chords: "C"),
                                                     ChordWordEntity("word 3")])
                    beforeEach {
                        target = ChordLineViewModel(chordLine: chordLine)
                    }
                    describe("transpose up") {
                        beforeEach {
                            target.transpose(1)
                        }
                        it("should transpose correctly") {
                            expect(target.chordWords).to(haveCount(3))

                            expect(target.chordWords[0].word).to(equal("word 1"))
                            expect(target.chordWords[0].chords).to(equal("D#"))

                            expect(target.chordWords[1].word).to(equal("word 2"))
                            expect(target.chordWords[1].chords).to(equal("C#"))

                            expect(target.chordWords[2].word).to(equal("word 3"))
                            expect(target.chordWords[2].chords).to(equal(""))
                        }
                    }
                    describe("transpose down") {
                        beforeEach {
                            target.transpose(-1)
                        }
                        it("should transpose correctly") {
                            expect(target.chordWords).to(haveCount(3))

                            expect(target.chordWords[0].word).to(equal("word 1"))
                            expect(target.chordWords[0].chords).to(equal("Db"))

                            expect(target.chordWords[1].word).to(equal("word 2"))
                            expect(target.chordWords[1].chords).to(equal("B"))

                            expect(target.chordWords[2].word).to(equal("word 3"))
                            expect(target.chordWords[2].chords).to(equal(""))
                        }
                    }
                }
            }
        }
        describe("ChordWordViewModel") {
            let chordWord = ChordWordEntity("word", chords: "[D]")
            let userDefaultsManager = UserDefaultsManager()
            var initialFontSize: Float = 0
            var target: ChordWordViewModel!
            describe("init") {
                context("does not have chords") {
                    let chordWord = ChordWordEntity("word")
                    beforeEach {
                        target = ChordWordViewModel(chordWord)
                    }
                    it("should have nil chords") {
                        expect(target.chords).to(beNil())
                    }
                }
            }
            describe("reading font size") {
                beforeEach {
                    initialFontSize = userDefaultsManager.fontSize
                    userDefaultsManager.fontSize = 1
                    target = ChordWordViewModel(chordWord, userDefaultsManager: userDefaultsManager)
                }
                afterEach {
                    userDefaultsManager.fontSize = initialFontSize
                }
                it ("should read from user defaults") {
                    expect(target.fontSize).to(equal(1))
                }
                context("font size updated") {
                    beforeEach {
                        userDefaultsManager.fontSize = 10
                    }
                    it ("should update font size") {
                        expect(target.fontSize).to(equal(10))
                    }
                }
            }
            describe("transpose") {
                beforeEach {
                    target = ChordWordViewModel(chordWord)
                }
                describe("transpose up") {
                    beforeEach {
                        target.transpose(1)
                    }
                    it("should transpose correctly") {
                        expect(target.chords).to(equal("[D#]"))
                    }
                }
                describe("transpose down") {
                    beforeEach {
                        target.transpose(-1)
                    }
                    it("should transpose correctly") {
                        expect(target.chords).to(equal("[Db]"))
                    }
                }
            }
        }
    }
}
