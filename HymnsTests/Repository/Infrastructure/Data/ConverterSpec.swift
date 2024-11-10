import Quick
import Nimble
@testable import Hymns

class ConverterSpec: QuickSpec {

    // Don't worry about force_try in tests.
    // swiftlint:disable force_try
    override func spec() {
        describe("Converter") {
            var target: Converter!
            beforeEach {
                target = ConverterImpl()
            }
            describe("toHymnEntity") {
                it("should convert to a valid hymn entity") {
                    expect(try! target.toHymnEntity(hymn: children_24_hymn)).to(equal(children_24_hymn_entity))
                }
            }
            describe("toUiHymn") {
                context("nil entity") {
                    it("should return nil") {
                        expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nil)).to(beNil())
                    }
                }
                describe("inline chords") {
                    context("single line, chords not found") {
                        let hymnEntity = HymnEntity.with { builder in
                            builder.id = 2
                            builder.title = "Hymn: title"
                            builder.inlineChords = InlineChordsEntity([ChordLineEntity([ChordWordEntity("no chords found")])])!
                        }
                        let expected
                            = UiHymn(hymnIdentifier: classic1151, title: "Hymn: title")
                        it("should not set the chords field") {
                            expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: hymnEntity)).to(equal(expected))
                        }
                    }
                    context("single line, chords found") {
                        let hymnEntity = HymnEntity.with { builder in
                            builder.id = 2
                            builder.title = "Hymn: title"
                            builder.inlineChords = InlineChordsEntity([ChordLineEntity([
                                ChordWordEntity("yes"),
                                ChordWordEntity("chords", chords: "G"),
                                ChordWordEntity("found")
                            ])])!
                        }
                        it("should set the chords field") {
                            let actual = try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: hymnEntity)!.inlineChords!
                            expect(actual).to(haveCount(1))
                            expect(actual[0].hasChords).to(beTrue())
                            expect(actual[0].chordWords).to(haveCount(3))
                            expect(actual[0].chordWords[0].chords).to(equal(""))
                            expect(actual[0].chordWords[0].word).to(equal("yes"))
                            expect(actual[0].chordWords[1].chords).to(equal("G"))
                            expect(actual[0].chordWords[1].word).to(equal("chords"))
                            expect(actual[0].chordWords[2].chords).to(equal(""))
                            expect(actual[0].chordWords[2].word).to(equal("found"))
                        }
                    }
                    context("multiple lines, chords not found") {
                        let hymnEntity = HymnEntity.with { builder in
                            builder.id = 2
                            builder.title = "Hymn: title"
                            builder.inlineChords = InlineChordsEntity([ChordLineEntity([
                                ChordWordEntity("no"),
                                ChordWordEntity("chords"),
                                ChordWordEntity("found"),
                                ChordWordEntity("\n"),
                                ChordWordEntity("definitely"),
                                ChordWordEntity("not")
                            ])])!
                        }
                        let expected
                            = UiHymn(hymnIdentifier: classic1151, title: "Hymn: title")
                        it("should not set the chords field") {
                            expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: hymnEntity)).to(equal(expected))
                        }
                    }
                    context("multiple lines, chords found") {
                        let hymnEntity = HymnEntity.with { builder in
                            builder.id = 2
                            builder.title = "Hymn: title"
                            builder.inlineChords = InlineChordsEntity(
                                [ChordLineEntity([
                                    ChordWordEntity("chords", chords: "G"),
                                    ChordWordEntity("found"),
                                    ChordWordEntity("line2")]),
                                 ChordLineEntity([
                                     ChordWordEntity("")
                                 ]),
                                 ChordLineEntity([
                                     ChordWordEntity("line2")
                                 ])])!
                        }
                        it("should set the chords field") {
                            let actual = try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: hymnEntity)!.inlineChords!
                            expect(actual).to(haveCount(3))
                            expect(actual[0].hasChords).to(beTrue())
                            expect(actual[0].chordWords).to(haveCount(3))
                            expect(actual[0].chordWords[0].chords).to(equal("G"))
                            expect(actual[0].chordWords[0].word).to(equal("chords"))
                            expect(actual[0].chordWords[1].chords).to(equal(""))
                            expect(actual[0].chordWords[1].word).to(equal("found"))

                            expect(actual[1].chordWords).to(haveCount(1))
                            expect(actual[1].chordWords[0].word).to(equal(""))
                            expect(actual[1].chordWords[0].hasChords).to(beFalse())

                            expect(actual[2].chordWords).to(haveCount(1))
                            expect(actual[2].chordWords[0].word).to(equal("line2"))
                            expect(actual[2].chordWords[0].hasChords).to(beFalse())
                        }
                    }
                }
                context("filled hymn") {
                    let filledHymn = HymnEntity.with { builder in
                        builder.id = 2
                        builder.title = "title"
                        builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["line 1", "line 2"])])
                        builder.category = ["This is my category"]
                        builder.subcategory = ["This is my subcategory"]
                        builder.author = ["This is the author"]
                        builder.composer = ["This is the composer"]
                        builder.key = ["This is the key"]
                        builder.time = ["This is the time"]
                        builder.meter = ["This is the meter"]
                        builder.scriptures = ["This is the scriptures"]
                        builder.hymnCode = ["This is the hymnCode"]
                        builder.pdfSheet = PdfSheetEntity(["Piano": "/en/hymn/h/1151/f=ppdf", "Guitar": "/en/hymn/h/1151/f=pdf",
                                                           "Text": "/en/hymn/h/1151/f=gtpdf"])!
                        builder.languages = LanguagesEntity([HymnIdentifier(hymnType: .cebuano, hymnNumber: "1151"),
                                                             HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                                                             HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151")])!
                        builder.relevants = RelevantsEntity([HymnIdentifier(hymnType: .classic, hymnNumber: "152"),
                                                             HymnIdentifier(hymnType: .newTune, hymnNumber: "152"),
                                                             HymnIdentifier(hymnType: .classic, hymnNumber: "152b")])!
                    }
                    let expected
                        = UiHymn(hymnIdentifier: classic1151,
                                 title: "title",
                                 lyrics: [VerseEntity(verseType: .verse, lineStrings: ["line 1", "line 2"])],
                                 pdfSheet: ["Piano": "/en/hymn/h/1151/f=ppdf",
                                            "Guitar": "/en/hymn/h/1151/f=pdf",
                                            "Text": "/en/hymn/h/1151/f=gtpdf"],
                                 category: "This is my category",
                                 subcategory: "This is my subcategory",
                                 author: "This is the author",
                                 composer: "This is the composer",
                                 key: "This is the key",
                                 time: "This is the time",
                                 meter: "This is the meter",
                                 scriptures: "This is the scriptures",
                                 hymnCode: "This is the hymnCode",
                                 languages: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "1151"),
                                             HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "216"),
                                             HymnIdentifier(hymnType: .tagalog, hymnNumber: "1151")],
                                 relevant: [HymnIdentifier(hymnType: .classic, hymnNumber: "152"),
                                            HymnIdentifier(hymnType: .newTune, hymnNumber: "152"),
                                            HymnIdentifier(hymnType: .classic, hymnNumber: "152b")])
                    it("should correctly convert to a UiHymn") {
                        expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: filledHymn)).to(equal(expected))
                    }
                }
            }
            describe("toSongResultEntities") {
                let classic594 = SongResult(name: "classic594", path: "/en/hymn/h/594?query=3")
                let classic595 = SongResult(name: "classic595", path: "/en/hymn/h/595?gb=1&query=3")
                let noHymnType = SongResult(name: "noHymnType", path: "")
                let newTune7 = SongResult(name: "newTune7", path: "/en/hymn/nt/7")
                let noHymnNumber = SongResult(name: "noHymnNumber", path: "/en/hymn/h/a")
                context("valid and invalid song results") {
                    it("convert the valid results and drop the invalid ones") {
                        let expectedEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "594", title: "classic594"),
                                                SongResultEntity(hymnType: .newTune, hymnNumber: "7", title: "newTune7")]
                        let (entities, hasMorePages) = target.toSongResultEntities(songResultsPage: SongResultsPage(results: [classic594, classic595,
                                                                                                                              noHymnType, newTune7, noHymnNumber],
                                                                                                                    hasMorePages: false))
                        expect(entities).to(equal(expectedEntities))
                        expect(hasMorePages).to(beFalse())
                    }
                }
            }
            describe("toUiSongResultsPage") {
                let classic594 = SongResultEntity(hymnType: .classic, hymnNumber: "594", title: "classic594")
                let newTune7 = SongResultEntity(hymnType: .newTune, hymnNumber: "7", title: "newTune7")
                it("should convert to a valid UiSongResultsPage") {
                    let expectedPage
                        = UiSongResultsPage(results: [UiSongResult(name: "classic594", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "594")),
                                                      UiSongResult(name: "newTune7", identifier: HymnIdentifier(hymnType: .newTune, hymnNumber: "7"))], hasMorePages: true)
                    let page = target.toUiSongResultsPage(songResultsEntities: [classic594, newTune7], hasMorePages: true)
                    expect(page).to(equal(expectedPage))
                }
            }
        }
    }
}
