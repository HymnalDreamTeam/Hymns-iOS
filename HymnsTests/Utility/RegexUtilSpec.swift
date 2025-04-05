import Quick
import Nimble
import XCTest
@testable import Hymns

// swiftlint:disable identifier_name type_body_length
class RegexUtilSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("getting from search query") {
            let mapping: [String: (hymnType: HymnType?, hymnNumber: String?)]
                = ["ch1": (.chinese, "1"), "ch 1": (.chinese, "1"), "S1": (.spanish, "1"), "S 1": (.spanish, "1"),
                   "new song1": (.newSong, "1"), "new tune 1": (.newTune, "1"), "spanish": (nil, nil),
                   "334": (nil, nil), "Cup of Chirst": (nil, nil), "xx1": (nil, "1")]

            describe("getting the hymn type") {
                it("should get the correct hymn type") {
                    for (searchQuery, pair) in mapping {
                        let hymnType = RegexUtil.getHymnType(searchQuery: searchQuery)
                        XCTAssertTrue(hymnType == pair.hymnType,
                                      "\(searchQuery) maps to \(String(describing: hymnType)) while it should map to \(String(describing: pair.hymnType))")
                    }
                }
            }
            describe("getting the hymn number") {
                it("should get the correct hymn number") {
                    for (searchQuery, pair) in mapping {
                        let hymnNumber = RegexUtil.getHymnNumber(searchQuery: searchQuery)
                        XCTAssertTrue(hymnNumber == pair.hymnNumber,
                                      "\(searchQuery) maps to \(String(describing: hymnNumber)) while it should map to \(String(describing: pair.hymnNumber))")
                    }
                }
            }
        }
        describe("getting hymn type from path") {
            let classic = "/en/hymn/h/594"
            context("from \(classic)") {
                it("should be classic") {
                    expect(RegexUtil.getHymnType(path: classic)).to(equal(HymnType.classic))
                }
            }
            let newTune = "/en/hymn/nt/594"
            context("from \(newTune)") {
                it("should be new tune") {
                    expect(RegexUtil.getHymnType(path: newTune)).to(equal(HymnType.newTune))
                }
            }
            let newSong = "/en/hymn/ns/594"
            context("from \(newSong)") {
                it("should be new song") {
                    expect(RegexUtil.getHymnType(path: newSong)).to(equal(HymnType.newSong))
                }
            }
            let children = "/en/hymn/c/594"
            context("from \(children)") {
                it("should be children") {
                    expect(RegexUtil.getHymnType(path: children)).to(equal(HymnType.children))
                }
            }
            let longBeach = "/en/hymn/lb/594"
            context("from \(longBeach)") {
                it("should be long beach") {
                    expect(RegexUtil.getHymnType(path: longBeach)).to(equal(HymnType.howardHigashi))
                }
            }
            let letterBefore = "/en/hymn/h/c333"
            context("from \(letterBefore)") {
                it("should be classic") {
                    expect(RegexUtil.getHymnType(path: letterBefore)).to(equal(HymnType.classic))
                }
            }
            let letterBeforeAndAfter = "/en/hymn/h/c333f"
            context("from \(letterBeforeAndAfter)") {
                it("should be classic") {
                    expect(RegexUtil.getHymnType(path: letterBeforeAndAfter)).to(equal(HymnType.classic))
                }
            }
            let letterAfter = "/en/hymn/h/13f"
            context("from \(letterAfter)") {
                it("should be classic") {
                    expect(RegexUtil.getHymnType(path: letterAfter)).to(equal(HymnType.classic))
                }
            }
            let noMatch = ""
            context("from \(noMatch)") {
                it("should be nil") {
                    expect(RegexUtil.getHymnType(path: noMatch)).to(beNil())
                }
            }
            let manyLetters = "/en/hymn/h/13fasdf"
            context("from \(manyLetters)") {
                it("should be classic") {
                    expect(RegexUtil.getHymnType(path: manyLetters)).to(equal(HymnType.classic))
                }
            }
            let chinese = "/en/hymn/ch/13"
            context("from \(chinese)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(path: chinese)).to(equal(HymnType.chinese))
                }
            }
            let chineseSimplified = "/en/hymn/ch/13?gb=1"
            context("from \(chineseSimplified)") {
                it("should be chinese simplified") {
                    expect(RegexUtil.getHymnType(path: chineseSimplified)).to(equal(HymnType.chineseSimplified))
                }
            }
            let chineseSupplement = "/en/hymn/ts/1"
            context("from \(chineseSupplement)") {
                it("should be chinese supplement") {
                    expect(RegexUtil.getHymnType(path: chineseSupplement)).to(equal(HymnType.chineseSupplement))
                }
            }
            let chineseSupplementSimplified = "/en/hymn/ts/1?gb=1"
            context("from \(chineseSupplementSimplified)") {
                it("should be chinese simplified") {
                    expect(RegexUtil.getHymnType(path: chineseSupplementSimplified)).to(equal(HymnType.chineseSupplementSimplified))
                }
            }
            let multipleQueryParams = "/en/hymn/ts/1?q1=4&q2=abc&gb=1"
            context("from \(multipleQueryParams)") {
                it("should be chinese simplified") {
                    expect(RegexUtil.getHymnType(path: multipleQueryParams)).to(equal(HymnType.chineseSupplementSimplified))
                }
            }
            let nonChineseQueryParams = "/en/hymn/h/594?gb=1&query=3"
            context("from \(nonChineseQueryParams)") {
                it("should be nil") {
                    expect(RegexUtil.getHymnType(path: nonChineseQueryParams)).to(beNil())
                }
            }
            let unrecognizedQueryParams = "/en/hymn/h/594?q1=2&q2=abc&&query=3"
            context("from \(unrecognizedQueryParams)") {
                it("should ignore the unrecognized query params") {
                    expect(RegexUtil.getHymnType(path: unrecognizedQueryParams)).to(equal(HymnType.classic))
                }
            }
        }
        describe("getting hymn number from search query") {
            let ch1 = "ch1"
            context("from \(ch1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: ch1)).to(equal(HymnType.chinese))
                }
            }
            let ch_1 = "ch 1"
            context("from \(ch_1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: ch_1)).to(equal(HymnType.chinese))
                }
            }
            let S1 = "S1"
            context("from \(S1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: S1)).to(equal(HymnType.spanish))
                }
            }
            let S_1 = "S 1"
            context("from \(S_1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: S_1)).to(equal(HymnType.spanish))
                }
            }
            let new_song1 = "new song1"
            context("from \(new_song1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: new_song1)).to(equal(HymnType.newSong))
                }
            }
            let new_tune_1 = "new tune 1"
            context("from \(new_tune_1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: new_tune_1)).to(equal(HymnType.newTune))
                }
            }
            let spanish = "spanish"
            context("from \(spanish)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: spanish)).to(beNil())
                }
            }
            let numberOnly = "334"
            context("from \(numberOnly)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: numberOnly)).to(beNil())
                }
            }
            let searchQuery = "Cup of Christ"
            context("from \(searchQuery)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: searchQuery)).to(beNil())
                }
            }
            let xx1 = "xx1"
            context("from \(xx1)") {
                it("should be chinese") {
                    expect(RegexUtil.getHymnType(searchQuery: xx1)).to(beNil())
                }
            }
        }
        describe("getting hymn number from path") {
            let classic = "/en/hymn/h/594"
            context("from \(classic)") {
                it("should be '594'") {
                    expect(RegexUtil.getHymnNumber(path: classic)).to(equal("594"))
                }
            }
            let letterBefore = "/en/hymn/h/c333"
            context("from \(letterBefore)") {
                it("should be 'c333'") {
                    expect(RegexUtil.getHymnNumber(path: letterBefore)).to(equal("c333"))
                }
            }
            let letterBeforeAndAfter = "/en/hymn/h/c333f"
            context("from \(letterBeforeAndAfter)") {
                it("should be 'c333f'") {
                    expect(RegexUtil.getHymnNumber(path: letterBeforeAndAfter)).to(equal("c333f"))
                }
            }
            let letterAfter = "/en/hymn/h/13f"
            context("from \(letterAfter)") {
                it("should be '13f'") {
                    expect(RegexUtil.getHymnNumber(path: letterAfter)).to(equal("13f"))
                }
            }
            let noMatch = ""
            context("from \(noMatch)") {
                it("should be nil") {
                    expect(RegexUtil.getHymnNumber(path: noMatch)).to(beNil())
                }
            }
            let manyLetters = "/en/hymn/h/13fasdf"
            context("from \(manyLetters)") {
                it("should be '13fasdf'") {
                    expect(RegexUtil.getHymnNumber(path: manyLetters)).to(equal("13fasdf"))
                }
            }
            let chordPdf = "/en/hymn/h/13f/f=pdf"
            context("from \(chordPdf)") {
                it("should be '13f'") {
                    expect(RegexUtil.getHymnNumber(path: chordPdf)).to(equal("13f"))
                }
            }
            let guitarPdf = "/en/hymn/h/13f/f=pdf"
            context("from \(guitarPdf)") {
                it("should be '13f'") {
                    expect(RegexUtil.getHymnNumber(path: guitarPdf)).to(equal("13f"))
                }
            }
            let mp3 = "/en/hymn/h/13f/f=mp3"
            context("from \(mp3)") {
                it("should be '13f'") {
                    expect(RegexUtil.getHymnNumber(path: mp3)).to(equal("13f"))
                }
            }
            let manyLettersPdf = "/en/hymn/h/13fasdf/f=pdf"
            context("from \(manyLettersPdf)") {
                it("should be '13fasdf'") {
                    expect(RegexUtil.getHymnNumber(path: manyLettersPdf)).to(equal("13fasdf"))
                }
            }
            let lettersAfter = "/en/hymn/h/13f/f=333/asdf"
            context("from \(lettersAfter)") {
                it("should be nil") {
                    expect(RegexUtil.getHymnNumber(path: lettersAfter)).to(beNil())
                }
            }
            let noNumber = "/en/hymn/h/a"
            context("from \(noNumber)") {
                it("should be nil") {
                    expect(RegexUtil.getHymnNumber(path: noNumber)).to(beNil())
                }
            }
            let queryParams = "/en/hymn/h/594?gb=1&query=3"
            context("from \(queryParams)") {
                it("should be '594'") {
                    expect(RegexUtil.getHymnNumber(path: queryParams)).to(equal("594"))
                }
            }
        }
        describe("getting book from reference") {
            it("should be extract the right book") {
                expect(RegexUtil.getBookFromReference("2 Chronicles 15:45")).to(equal(.secondChronicles))
                expect(RegexUtil.getBookFromReference("Psalms 45")).to(equal(.psalms))
                expect(RegexUtil.getBookFromReference("cf. Psalms 45")).to(equal(.psalms))
                expect(RegexUtil.getBookFromReference("Psalms")).to(equal(.psalms))
                expect(RegexUtil.getBookFromReference("1 John 5:12")).to(equal(.firstJohn))
                expect(RegexUtil.getBookFromReference("3 John 5:1")).to(equal(.thirdJohn))
                expect(RegexUtil.getBookFromReference("Jude 1:12")).to(equal(.jude))
                expect(RegexUtil.getBookFromReference("Matthew 17:5-14")).to(equal(.matthew))
                expect(RegexUtil.getBookFromReference("Song of Songs 4:12")).to(equal(.songOfSongs))
                expect(RegexUtil.getBookFromReference("cf. Daniel 3:6-7")).to(equal(.daniel))
                expect(RegexUtil.getBookFromReference("6:19")).to(beNil())
                expect(RegexUtil.getBookFromReference("80")).to(beNil())
                expect(RegexUtil.getBookFromReference("cf. 80")).to(beNil())
            }
        }
        describe("getting chapter from reference") {
            it("should be extract the right chapter") {
                expect(RegexUtil.getChapterFromReference("2 Chronicles 15:45")).to(equal("15"))
                expect(RegexUtil.getChapterFromReference("Psalms 45")).to(equal("45"))
                expect(RegexUtil.getChapterFromReference("cf. Psalms 45")).to(equal("45"))
                expect(RegexUtil.getChapterFromReference("Psalms")).to(beNil())
                expect(RegexUtil.getChapterFromReference("1 John 5:12")).to(equal("5"))
                expect(RegexUtil.getChapterFromReference("3 John 5:1")).to(equal("5"))
                expect(RegexUtil.getChapterFromReference("Jude 1:12")).to(equal("1"))
                expect(RegexUtil.getChapterFromReference("Matthew 17:5-14")).to(equal("17"))
                expect(RegexUtil.getChapterFromReference("Song of Songs 4:12")).to(equal("4"))
                expect(RegexUtil.getChapterFromReference("cf. Daniel 3:6-7")).to(equal("3"))
                expect(RegexUtil.getChapterFromReference("6:19")).to(equal("6"))
                expect(RegexUtil.getChapterFromReference("80")).to(beNil())
                expect(RegexUtil.getChapterFromReference("cf. 80")).to(equal("80"))
            }
        }
        describe("getting verse from reference") {
            it("should be extract the right verse") {
                expect(RegexUtil.getVerseFromReference("2 Chronicles 15:45")).to(equal("45"))
                expect(RegexUtil.getVerseFromReference("Psalms 45")).to(beNil())
                expect(RegexUtil.getVerseFromReference("cf. Psalms 45")).to(beNil())
                expect(RegexUtil.getVerseFromReference("Psalms")).to(beNil())
                expect(RegexUtil.getVerseFromReference("1 John 5:12")).to(equal("12"))
                expect(RegexUtil.getVerseFromReference("3 John 5:1")).to(equal("1"))
                expect(RegexUtil.getVerseFromReference("Jude 1:12")).to(equal("12"))
                expect(RegexUtil.getVerseFromReference("Matthew 17:5-14")).to(equal("5-14"))
                expect(RegexUtil.getVerseFromReference("5-14")).to(equal("5-14"))
                expect(RegexUtil.getVerseFromReference("Jude 1:12")).to((equal("12")))
                expect(RegexUtil.getVerseFromReference("Song of Songs 4:12")).to(equal("12"))
                expect(RegexUtil.getVerseFromReference("cf. Daniel 3:6-7")).to(equal("6-7"))
                expect(RegexUtil.getVerseFromReference("6:19")).to(equal("19"))
                expect(RegexUtil.getVerseFromReference("80")).to(equal("80"))
                expect(RegexUtil.getVerseFromReference("cf. 80")).to(beNil())
            }
        }
        describe("replace Os") {
            it("notFound__doesNothing") {
                expect(RegexUtil.replaceOs("there is no match in this at all")).to(equal("there is no match in this at all"))
            }
            it("OFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("O Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
            it("oFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("o Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
            it("ohFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("oh Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
            it("oHFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("oH Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
            it("OhFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("Oh Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
            it("OHFound__replaceWithOOrOh") {
                expect(RegexUtil.replaceOs("OH Christ, He is the fountain")).to(equal("(O OR Oh) Christ, He is the fountain"))
            }
        }
        describe("replace apostrophe") {
            it("notFound__doesNothing") {
                expect(RegexUtil.replaceApostrophes("there is no match in this at all")).to(equal("there is no match in this at all"))
            }
            it("apostropheFound__replaceWithQuoteOrApostrophe") {
                expect(RegexUtil.replaceApostrophes("Christ’s the fountain")).to(equal("(Christ’s OR Christ's) the fountain"))
            }
            it("quoteFound__replaceWithQuoteOrApostrophe") {
                expect(RegexUtil.replaceApostrophes("Christ's the fountain")).to(equal("(Christ’s OR Christ's) the fountain"))
            }
            it("bothFound__replaceWithQuoteOrApostrophe") {
                expect(RegexUtil.replaceApostrophes("Christ's the founta’in")).to(equal("(Christ’s OR Christ's) the (founta’in OR founta'in)"))
            }
        }
        describe("remove punctuation") {
            it("should return an empty string for an empty input") {
                expect(RegexUtil.removePunctuation("")).to(beEmpty())
            }
            it("should return the same string if there is no punctuation") {
                let input = "HelloWorld"
                expect(RegexUtil.removePunctuation(input)).to(equal(input))
            }
            it("should remove basic punctuation marks") {
                let input = "Hello, World!"
                expect(RegexUtil.removePunctuation(input)).to(equal("Hello World"))
            }
            it("should remove multiple punctuation marks") {
                let input = "This is a test... with multiple!!! punctuation?? marks."
                expect(RegexUtil.removePunctuation(input)).to(equal("This is a test with multiple punctuation marks"))
            }
            it("should remove punctuation at the beginning and end") {
                let input = "!Hello World?"
                expect(RegexUtil.removePunctuation(input)).to(equal("Hello World"))
            }
            it("should return an empty string if the input contains only punctuation") {
                expect(RegexUtil.removePunctuation(",.!?")).to(beEmpty())
            }
            it("should remove punctuation while preserving mixed case") {
                let input = "Some TeSt W!.';iTh' $ pUnCtUaTiOn."
                expect(RegexUtil.removePunctuation(input)).to(equal("Some TeSt WiTh $ pUnCtUaTiOn"))
            }
            it("should remove a wider range of ASCII punctuation") {
                let input = "This string contains: #$%&'()*+,-./:;<=>?@[]^_`{|}~"
                expect(RegexUtil.removePunctuation(input)).to(equal("This string contains $+<=>^`|~"))
            }
            it("should remove international punctuation (based on the current pattern)") {
                let input = "你好，世界！" // Chinese with punctuation
                expect(RegexUtil.removePunctuation(input)).to(equal("你好世界"))

                let input2 = "café." // French with punctuation
                expect(RegexUtil.removePunctuation(input2)).to(equal("café"))
            }
        }
        describe("contains quote") {
            context("does not contain") {
                it("should be false") {
                    expect(RegexUtil.containsQuote("there is no match in this at all")).to(beFalse())
                }
            }
            context("does contain “") {
                it("should be true") {
                    expect(RegexUtil.containsQuote("th“ere is no match in this at all")).to(beTrue())
                }
            }
            context("does contain ”") {
                it("should be true") {
                    expect(RegexUtil.containsQuote("th”ere is no match in this at all")).to(beTrue())
                }
            }
            context("does contain \"") {
                it("should be true") {
                    expect(RegexUtil.containsQuote("th\"ere is no match in this at all")).to(beTrue())
                }
            }
            context("does contain all three") {
                it("should be true") {
                    expect(RegexUtil.containsQuote("“Christ he \"is”")).to(beTrue())
                }
            }
        }
        describe("replace curly quotes") {
            context("not found") {
                it("do nothing") {
                    expect(RegexUtil.replaceCurlyQuotes("there is no match in this at all")).to(equal("there is no match in this at all"))
                }
            }
            context("open quote found") {
                it("replace with straight quotes") {
                    expect(RegexUtil.replaceCurlyQuotes("“Chr“ist “he is“")).to(equal("\"Chr\"ist \"he is\""))
                }
            }
            context("close quote found") {
                it("replace with straight quotes") {
                    expect(RegexUtil.replaceCurlyQuotes("”Chr”ist ”he is”")).to(equal("\"Chr\"ist \"he is\""))
                }
            }
            context("both found") {
                it("replace with straight quotes") {
                    expect(RegexUtil.replaceCurlyQuotes("“Christ he is”")).to(equal("\"Christ he is\""))
                }
            }
        }
    }
}
// swiftlint:enable identifier_name type_body_length
