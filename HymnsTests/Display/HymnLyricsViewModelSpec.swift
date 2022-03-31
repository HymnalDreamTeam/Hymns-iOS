import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class HymnLyricsViewModelSpec: QuickSpec {

    override func spec() {
        describe("HymnLyricsViewModel initialized") {
            var target: HymnLyricsViewModel!
            context("with nil lyrics") {
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: nil)
                }
                it("should return nil view model") {
                    expect(target).to(beNil())
                }
            }
            context("with empty lyrics") {
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: [Verse]())
                }
                it("should return nil view model") {
                    expect(target).to(beNil())
                }
            }
            context("without transliterable lyrics") {
                let verses = [Verse(verseType: .verse, verseContent: ["line 1", "line 2"]), Verse(verseType: .chorus, verseContent: ["chorus 1", "chorus 2"])]
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: verses)!
                }
                it("should display lyrics") {
                    expect(target.lyrics).to(equal([VerseViewModel(verseNumber: "1", verseLines: ["line 1", "line 2"]),
                                                    VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"])]))
                }
                describe("formatted string") {
                    context("do not include transliteration") {
                        it("should not include transliteration") {
                            let formattedString = target.lyrics.map { $0.createFormattedString(includeTransliteration: false) }
                            expect(formattedString).to(equal(["line 1\nline 2\n", "chorus 1\nchorus 2\n"]))
                        }
                    }
                    context("include transliteration") {
                        it("should not include transliteration since it doesn't exist") {
                            let formattedString = target.lyrics.map { $0.createFormattedString(includeTransliteration: true) }
                            expect(formattedString).to(equal(["line 1\nline 2\n", "chorus 1\nchorus 2\n"]))
                        }
                    }
                }
                it("should not show transliteration button") {
                    expect(target!.showTransliterationButton).to(beFalse())
                }
            }
            context("with transliterable lyrics") {
                let verses = [Verse(verseType: .verse, verseContent: ["line 1", "line 2"], transliteration: ["transliteration 1", "transliteration 2"]),
                              Verse(verseType: .chorus, verseContent: ["chorus 1", "chorus 2"], transliteration: ["chorus transliteration 1", "chorus transliteration 2"])]
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: verses)!
                }
                it("should display lyrics") {
                    expect(target.lyrics).to(equal([VerseViewModel(verseNumber: "1", verseLines: ["line 1", "line 2"],
                                                                   transliteration: ["transliteration 1", "transliteration 2"]),
                                                    VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"],
                                                                   transliteration: ["chorus transliteration 1", "chorus transliteration 2"])]))
                }
                describe("formatted string") {
                    context("do not include transliteration") {
                        it("should not include transliteration") {
                            let formattedString = target.lyrics.map { $0.createFormattedString(includeTransliteration: false) }
                            expect(formattedString).to(equal(["line 1\nline 2\n", "chorus 1\nchorus 2\n"]))
                        }
                    }
                    context("include transliteration") {
                        it("should include transliteration") {
                            let formattedString = target.lyrics.map { $0.createFormattedString(includeTransliteration: true) }
                            expect(formattedString).to(equal(["transliteration 1\nline 1\ntransliteration 2\nline 2\n",
                                                              "chorus transliteration 1\nchorus 1\nchorus transliteration 2\nchorus 2\n"]))
                        }
                    }
                }
                it("should show transliteration button") {
                    expect(target.showTransliterationButton).to(beTrue())
                }
            }
            context("repeat chorus") {
                beforeEach {
                    UserDefaults.standard.set(true, forKey: "repeat_chorus")
                }
                context("no chorus") {
                    let verses: [Verse] = [
                        Verse(verseType: .verse, verseContent: ["line 1", "line 2"]),
                        Verse(verseType: .other, verseContent: ["other 1", "other 2"]),
                        Verse(verseType: .verse, verseContent: ["line 3", "line 4"])]
                    beforeEach {
                        target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: verses)!
                    }
                    it("should not repeat choruses") {
                        expect(target.lyrics).to(equal([
                            VerseViewModel(verseNumber: "1", verseLines: ["line 1", "line 2"]),
                            VerseViewModel(verseNumber: "Other", verseLines: ["other 1", "other 2"]),
                            VerseViewModel(verseNumber: "2", verseLines: ["line 3", "line 4"])
                        ]))
                    }
                }
                context("one chorus") {
                    let verses: [Verse] = [Verse(verseType: .verse, verseContent: ["line 1", "line 2"]),
                                           Verse(verseType: .other, verseContent: ["other 1", "other 2"]),
                                           Verse(verseType: .verse, verseContent: ["line 3", "line 4"]),
                                           Verse(verseType: .verse, verseContent: ["line 5", "line 6"]),
                                           Verse(verseType: .chorus, verseContent: ["chorus 1", "chorus 2"])]
                    beforeEach {
                        target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: verses)
                    }
                    it("should repeat the chorus") {
                        expect(target.lyrics).to(equal([
                            VerseViewModel(verseNumber: "1", verseLines: ["line 1", "line 2"]),
                            VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"]),
                            VerseViewModel(verseNumber: "Other", verseLines: ["other 1", "other 2"]),
                            VerseViewModel(verseNumber: "2", verseLines: ["line 3", "line 4"]),
                            VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"]),
                            VerseViewModel(verseNumber: "3", verseLines: ["line 5", "line 6"]),
                            VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"])
                        ]))
                    }
                }
                context("multiple choruses") {
                    let verses: [Verse] = [Verse(verseType: .verse, verseContent: ["line 1", "line 2"]),
                                           Verse(verseType: .chorus, verseContent: ["chorus 1", "chorus 2"]),
                                           Verse(verseType: .chorus, verseContent: ["chorus 3", "chorus 4"]),
                                           Verse(verseType: .other, verseContent: ["other 1", "other 2"]),
                                           Verse(verseType: .verse, verseContent: ["line 3", "line 4"])]
                    beforeEach {
                        target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: verses)
                    }
                    it("should not repeat choruses") {
                        expect(target.lyrics).to(equal([
                            VerseViewModel(verseNumber: "1", verseLines: ["line 1", "line 2"]),
                            VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 1", "chorus 2"]),
                            VerseViewModel(verseNumber: "Chorus", verseLines: ["chorus 3", "chorus 4"]),
                            VerseViewModel(verseNumber: "Other", verseLines: ["other 1", "other 2"]),
                            VerseViewModel(verseNumber: "2", verseLines: ["line 3", "line 4"])
                        ]))
                    }
                }
            }
        }
    }
}
