import Quick
import Nimble
import SwiftUI
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
                let classic594 = SongResultEntity(hymnType: .classic, hymnNumber: "594", title: "classic594", songId: 1)
                let newTune7 = SongResultEntity(hymnType: .newTune, hymnNumber: "7", title: "newTune7", songId: 1)
                let newTune8 = SongResultEntity(hymnType: .newTune, hymnNumber: "8", title: "newTune8", songId: 3)
                var convertedPage: UiSongResultsPage!
                beforeEach {
                    convertedPage = target.toUiSongResultsPage(songResultEntities: [classic594, newTune7, newTune8], hasMorePages: true)
                }
                it("should group entities with the same id") {
                    expect(convertedPage.results).to(haveCount(2))
                }
                let expectedPage = UiSongResultsPage(results: [UiSongResult(name: "classic594",
                                                                            identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "594"),
                                                                                          HymnIdentifier(hymnType: .newTune, hymnNumber: "7")]),
                                                               UiSongResult(name: "newTune8",
                                                                            identifiers: [HymnIdentifier(hymnType: .newTune, hymnNumber: "8")])],
                                                     hasMorePages: true)
                it("should convert correctly") {
                    expect(convertedPage).to(equal(expectedPage))
                }
            }
            describe("toSingleSongResultViewModels") {
                let songResultEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "594", title: "c594", songId: 1),
                                          SongResultEntity(hymnType: .newTune, hymnNumber: "7", title: "nt7", songId: 1),
                                          SongResultEntity(hymnType: .newTune, hymnNumber: "8", title: "nt8", songId: 1),
                                          SongResultEntity(hymnType: .newTune, hymnNumber: "9", title: "nt9", songId: 4),
                                          SongResultEntity(hymnType: .newTune, hymnNumber: "10", title: "nt10", songId: 1)]
                var convertedResults: [SingleSongResultViewModel]!
                beforeEach {
                    convertedResults = target.toSingleSongResultViewModels(songResultEntities: songResultEntities, storeInHistoryStore: true)
                }
                it("should convert each song result") {
                    expect(convertedResults).to(haveCount(5))
                }
                it("should convert each title") {
                    expect(convertedResults.map({ $0.title })).to(equal(["c594", "nt7", "nt8", "nt9", "nt10"]))
                }
                it("should convert each label") {
                    expect(convertedResults.map({ $0.label })).to(equal(["Hymn 594", "New tune 7", "New tune 8", "New tune 9", "New tune 10"]))
                }
                let expectedResults = [SingleSongResultViewModel(stableId: "hymnType: h, hymnNumber: 594", title: "", destinationView: EmptyView().eraseToAnyView()),
                                       SingleSongResultViewModel(stableId: "hymnType: nt, hymnNumber: 7", title: "" , destinationView: EmptyView().eraseToAnyView()),
                                       SingleSongResultViewModel(stableId: "hymnType: nt, hymnNumber: 8", title: "" , destinationView: EmptyView().eraseToAnyView()),
                                       SingleSongResultViewModel(stableId: "hymnType: nt, hymnNumber: 9", title: "" , destinationView: EmptyView().eraseToAnyView()),
                                       SingleSongResultViewModel(stableId: "hymnType: nt, hymnNumber: 10", title: "" , destinationView: EmptyView().eraseToAnyView())]
                it("should convert the stable ids correctly") {
                    expect(convertedResults).to(equal(expectedResults))
                }
            }
            describe("toMultiSongResultViewModels") {
                describe("from UiSongResultsPage") {
                    let uiSongResultsPage = UiSongResultsPage(results: [UiSongResult(name: "classic594",
                                                                                     identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "594"),
                                                                                                   HymnIdentifier(hymnType: .newTune, hymnNumber: "7"),
                                                                                                   HymnIdentifier(hymnType: .newTune, hymnNumber: "8"),
                                                                                                   HymnIdentifier(hymnType: .newTune, hymnNumber: "9"),
                                                                                                   HymnIdentifier(hymnType: .newTune, hymnNumber: "10")]),
                                                                        UiSongResult(name: "newTune8",
                                                                                     identifiers: [HymnIdentifier(hymnType: .newTune, hymnNumber: "8")])],
                                                              hasMorePages: true)
                    var convertedResults: ([MultiSongResultViewModel], Bool)!
                    beforeEach {
                        convertedResults = target.toMultiSongResultViewModels(songResultsPage: uiSongResultsPage)
                    }
                    it("should convert each song result") {
                        expect(convertedResults.0).to(haveCount(2))
                    }
                    it("should just pipe hasMorePages through") {
                        expect(convertedResults.1).to(beTrue())
                    }
                    it("should only use the first three identifiers in the label") {
                        expect(convertedResults.0[0].labels).to(equal(["Hymn 594", "New tune 7", "New tune 8"]))
                    }
                    it("should convert the title correctly") {
                        expect(convertedResults.0.map({ $0.title })).to(equal(["classic594", "newTune8"]))
                    }
                    it("should convert the labels correctly") {
                        expect(convertedResults.0.map({ $0.labels })).to(equal([["Hymn 594", "New tune 7", "New tune 8"], ["New tune 8"]]))
                    }
                    let expectedResults = [MultiSongResultViewModel(stableId: "[hymnType: h, hymnNumber: 594, hymnType: nt, hymnNumber: 7, hymnType: nt, hymnNumber: 8, hymnType: nt, hymnNumber: 9, hymnType: nt, hymnNumber: 10]",
                                                                    title: "", destinationView: EmptyView().eraseToAnyView()),
                                           MultiSongResultViewModel(stableId: "[hymnType: nt, hymnNumber: 8]", title: "" , destinationView: EmptyView().eraseToAnyView())]
                    it("should convert the stable ids correctly") {
                        expect(convertedResults.0).to(equal(expectedResults))
                    }
                    context("nil hasMorePages") {
                        let nilHasMorePages = UiSongResultsPage(results: [UiSongResult(name: "classic594",
                                                                                       identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "594"),
                                                                                                     HymnIdentifier(hymnType: .newTune, hymnNumber: "7"),
                                                                                                     HymnIdentifier(hymnType: .newTune, hymnNumber: "8"),
                                                                                                     HymnIdentifier(hymnType: .newTune, hymnNumber: "9"),
                                                                                                     HymnIdentifier(hymnType: .newTune, hymnNumber: "10")]),
                                                                          UiSongResult(name: "newTune8",
                                                                                       identifiers: [HymnIdentifier(hymnType: .newTune, hymnNumber: "8")])],
                                                                hasMorePages: nil)
                        beforeEach {
                            convertedResults = target.toMultiSongResultViewModels(songResultsPage: nilHasMorePages)
                        }
                        it("should default hasMorePages to false") {
                            expect(convertedResults.1).to(beFalse())
                        }
                    }
                }
                describe("from SongResultEntities") {
                    let songResultEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "594", title: "c594", songId: 1),
                                              SongResultEntity(hymnType: .newTune, hymnNumber: "7", title: "nt7", songId: 1),
                                              SongResultEntity(hymnType: .newTune, hymnNumber: "8", title: "nt8", songId: 1),
                                              SongResultEntity(hymnType: .farsi, hymnNumber: "8", title: "farsi8"),
                                              SongResultEntity(hymnType: .newTune, hymnNumber: "9", title: "nt9", songId: 4),
                                              SongResultEntity(hymnType: .newTune, hymnNumber: "10", title: "nt10", songId: 1),
                                              SongResultEntity(hymnType: .farsi, hymnNumber: "9", title: "farsi9"),]
                    var convertedResults: [MultiSongResultViewModel]!
                    beforeEach {
                        convertedResults = target.toMultiSongResultViewModels(songResultEntities: songResultEntities, storeInHistoryStore: true)
                    }
                    it("should group results with the same song id") {
                        expect(convertedResults).to(haveCount(4))
                    }
                    it("should use the first title") {
                        expect(convertedResults.map({ $0.title })).to(equal(["c594", "farsi8", "nt9", "farsi9"]))
                    }
                    it("should only use the first three identifiers in the label") {
                        expect(convertedResults[0].labels).to(equal(["Hymn 594", "New tune 7", "New tune 8"]))
                    }
                    it("should convert the labels correctly") {
                        expect(convertedResults.map({ $0.labels })).to(equal([["Hymn 594", "New tune 7", "New tune 8"], ["Farsi 8"], ["New tune 9"], ["Farsi 9"]]))
                    }
                    let expectedResults = [MultiSongResultViewModel(stableId: "[hymnType: h, hymnNumber: 594, hymnType: nt, hymnNumber: 7, hymnType: nt, hymnNumber: 8, hymnType: nt, hymnNumber: 10]",
                                                                    title: "", destinationView: EmptyView().eraseToAnyView()),
                                           MultiSongResultViewModel(stableId: "[hymnType: F, hymnNumber: 8]",
                                                                    title: "", destinationView: EmptyView().eraseToAnyView()),
                                           MultiSongResultViewModel(stableId: "[hymnType: nt, hymnNumber: 9]", title: "" , destinationView: EmptyView().eraseToAnyView()),
                                           MultiSongResultViewModel(stableId: "[hymnType: F, hymnNumber: 9]",
                                                                    title: "", destinationView: EmptyView().eraseToAnyView())]
                    it("should convert the stable ids correctly") {
                        expect(convertedResults).to(equal(expectedResults))
                    }
                }
            }
        }
    }
}
