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
                    expect(try! target.toHymnEntity(hymnIdentifier: children24, hymn: children_24_hymn)).to(equal(children_24_hymn_entity))
                }
            }
            describe("toUiHymn") {
                context("nil entity") {
                    it("should return nil") {
                        expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nil)).to(beNil())
                    }
                }
                context("nil lyrics") {
                    let nilLyrics = HymnEntity(hymnIdentifier: classic1151)
                    it("should throw type conversion error") {
                        expect {
                            try target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nilLyrics)
                        }.to(throwError { (error: TypeConversionError) in
                            expect(error.triggeringError).to(matchError(ErrorType.parsing(description: "lyrics json was empty")))
                        })
                    }
                }
                context("empty lyrics") {
                    let nilLyrics = HymnEntity(hymnIdentifier: classic1151, lyricsJson: "")
                    it("should throw type conversion error") {
                        expect {
                            try target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nilLyrics)
                        }.to(throwError { (error: TypeConversionError) in
                            expect(error.triggeringError).to(matchError(ErrorType.parsing(description: "lyrics json was empty")))
                        })
                    }
                }
                context("nil title") {
                    let nilTitle = HymnEntity(hymnIdentifier: classic1151, lyricsJson: "[{\"verse_type\":\"verse\",\"verse_content\":[\"line 1\",\"line 2\"]}]")
                    it("should throw type conversion error") {
                        expect {
                            try target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nilTitle)
                        }.to(throwError { (error: TypeConversionError) in
                            expect(error.triggeringError).to(matchError(ErrorType.parsing(description: "title was empty")))
                        })
                    }
                }
                context("empty title") {
                    let nilTitle = HymnEntity(hymnIdentifier: classic1151, title: "", lyricsJson: "[{\"verse_type\":\"verse\",\"verse_content\":[\"line 1\",\"line 2\"]}]")
                    it("should throw type conversion error") {
                        expect {
                            try target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: nilTitle)
                        }.to(throwError { (error: TypeConversionError) in
                            expect(error.triggeringError).to(matchError(ErrorType.parsing(description: "title was empty")))
                        })
                    }
                }
                context("invalid json") {
                    let invalidJson = HymnEntity(hymnIdentifier: classic1151, title: "Hymn: title", lyricsJson: "invalid json")
                    // <TypeConversionError(triggeringError: Swift.DecodingError.dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Error Domain=NSCocoaErrorDomain Code=3840 "Invalid value around character 0." UserInfo={NSDebugDescription=Invalid value around character 0.}))))>
                    it("should throw type conversion error") {
                        expect {
                            try target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: invalidJson)
                        }.to(throwError { (error: TypeConversionError) in
                            expect(error.triggeringError).to(matchError(Swift.DecodingError.self))
                        })
                    }
                }
                context("filled hymn") {
                    let filledHymn
                        = HymnEntity(hymnIdentifier: classic1151,
                                     title: "Hymn: title",
                                     lyricsJson: "[{\"verse_type\":\"verse\",\"verse_content\":[\"line 1\",\"line 2\"]}]",
                                     category: "This is my category",
                                     subcategory: "This is my subcategory",
                                     author: "This is the author",
                                     composer: "This is the composer",
                                     key: "This is the key",
                                     time: "This is the time",
                                     meter: "This is the meter",
                                     scriptures: "This is the scriptures",
                                     hymnCode: "This is the hymnCode",
                                     pdfSheetJson: "{\"data\": [{\"path\": \"/en/hymn/h/1151/f=ppdf\", \"value\": \"Piano\"}, {\"path\": \"/en/hymn/h/1151/f=pdf\", \"value\": \"Guitar\"}, {\"path\": \"/en/hymn/h/1151/f=gtpdf\", \"value\": \"Text\"}], \"name\": \"Lead Sheet\"}",
                                     languagesJson: "{\"data\": [{\"path\": \"/en/hymn/cb/1151\", \"value\": \"Cebuano\"}, {\"path\": \"/en/hymn/ts/216?gb=1\", \"value\": \"诗歌(简)\"}, {\"path\": \"/en/hymn/ht/1151\", \"value\": \"Tagalog\"}], \"name\": \"Languages\"}",
                                     relevantJson: "{\"data\": [{\"path\": \"/en/hymn/h/152\", \"value\": \"Original Tune\"}, {\"path\": \"/en/hymn/nt/152\", \"value\": \"New Tune\"}, {\"path\": \"/en/hymn/h/152b\", \"value\": \"Alternate Tune\"}], \"name\": \"Relevant\"}")

                    let expected
                        = UiHymn(hymnIdentifier: classic1151,
                                 title: "title",
                                 lyrics: [Verse(verseType: .verse, verseContent: ["line 1", "line 2"])],
                                 pdfSheet: MetaDatum(name: "Lead Sheet",
                                                     data: [Datum(value: "Piano", path: "/en/hymn/h/1151/f=ppdf"),
                                                            Datum(value: "Guitar", path: "/en/hymn/h/1151/f=pdf"),
                                                            Datum(value: "Text", path: "/en/hymn/h/1151/f=gtpdf")]),
                                 category: "This is my category",
                                 subcategory: "This is my subcategory",
                                 author: "This is the author",
                                 composer: "This is the composer",
                                 key: "This is the key",
                                 time: "This is the time",
                                 meter: "This is the meter",
                                 scriptures: "This is the scriptures",
                                 hymnCode: "This is the hymnCode",
                                 languages: MetaDatum(name: "Languages",
                                                      data: [Datum(value: "Cebuano", path: "/en/hymn/cb/1151"),
                                                             Datum(value: "诗歌(简)", path: "/en/hymn/ts/216?gb=1"),
                                                             Datum(value: "Tagalog", path: "/en/hymn/ht/1151")]),
                                 relevant: MetaDatum(name: "Relevant",
                                                     data: [Datum(value: "Original Tune", path: "/en/hymn/h/152"),
                                                            Datum(value: "New Tune", path: "/en/hymn/nt/152"),
                                                            Datum(value: "Alternate Tune", path: "/en/hymn/h/152b")]))
                    it("should correctly convert to a UiHymn") {
                        expect(try! target.toUiHymn(hymnIdentifier: classic1151, hymnEntity: filledHymn)).to(equal(expected))
                    }
                }
            }
            describe("toSongResultEntities") {
                let classic594 = SongResult(name: "classic594", path: "/en/hymn/h/594?gb=1&query=3")
                let noHymnType = SongResult(name: "noHymnType", path: "")
                let newTune7 = SongResult(name: "newTune7", path: "/en/hymn/nt/7")
                let noHymnNumber = SongResult(name: "noHymnNumber", path: "/en/hymn/h/a")
                context("valid and invalid song results") {
                    it("convert the valid results and drop the invalid ones") {
                        let expectedEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "594", queryParams: ["gb": "1", "query": "3"], title: "classic594"),
                                                SongResultEntity(hymnType: .newTune, hymnNumber: "7", queryParams: nil, title: "newTune7")]
                        let (entities, hasMorePages) = target.toSongResultEntities(songResultsPage: SongResultsPage(results: [classic594, noHymnType, newTune7, noHymnNumber], hasMorePages: false))
                        expect(entities).to(equal(expectedEntities))
                        expect(hasMorePages).to(beFalse())
                    }
                }
            }
            describe("toUiSongResultsPage") {
                let classic594 = SongResultEntity(hymnType: .classic, hymnNumber: "594", queryParams: ["gb": "1", "query": "3"], title: "classic594")
                let newTune7 = SongResultEntity(hymnType: .newTune, hymnNumber: "7", queryParams: nil, title: "newTune7")
                it("should convert to a valid UiSongResultsPage") {
                    let expectedPage
                        = UiSongResultsPage(results: [UiSongResult(name: "classic594", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "594", queryParams: ["gb": "1", "query": "3"])),
                                                      UiSongResult(name: "newTune7", identifier: HymnIdentifier(hymnType: .newTune, hymnNumber: "7"))], hasMorePages: true)
                    let page = target.toUiSongResultsPage(songResultsEntities: [classic594, newTune7], hasMorePages: true)
                    expect(page).to(equal(expectedPage))
                }
            }
        }
    }
}
