import GRDB
import Quick
import Nimble
@testable import Hymns

// swiftlint:disable:next type_body_length
class HymnDataStoreGrdbImplSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("using an in-memory database queue") {
            let testQueue = DispatchQueue(label: "test_queue")
            var inMemoryDBQueue: DatabaseQueue!
            var target: HymnDataStoreGrdbImpl!
            beforeEach {
                // https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
                inMemoryDBQueue = DatabaseQueue()
                target = HymnDataStoreGrdbImpl(databaseQueue: inMemoryDBQueue, initializeTables: true)
            }
            describe("the database") {
                it("should have been initialized successfully") {
                    expect(target.databaseInitializedProperly).to(beTrue())
                }
            }
            describe("save a few songs") {
                beforeEach {
                    target.saveHymn(classic_1151_hymn_entity)
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: newSong145).title("new song 145").hymnCode("171214436716555").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: cebuano123).title("cebuano 123").build())
                    // saving another cebuano123 should replace the old one.
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: cebuano123).title("new cebuano title").build())
                    // this one should be a whole new song in the db
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: cebuano123QueryParams).title("cebuano 123 with query params").hymnCode("171214436716555").build())
                }
                context("getting a stored song") {
                    it("should return the stored song") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getHymn(cebuano123)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entity in
                                value.fulfill()
                                expect(entity).to(equal(HymnEntityBuilder(hymnIdentifier: cebuano123).title("new cebuano title").build()))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("getting a stored song with query params") {
                    it("should return the stored song") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getHymn(cebuano123QueryParams)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entity in
                                value.fulfill()
                                expect(entity).to(equal(HymnEntityBuilder(hymnIdentifier: cebuano123QueryParams)
                                                            .title("cebuano 123 with query params")
                                                            .hymnCode("171214436716555")
                                                            .build()))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("getting an unstored song") {
                    it("should return a nil result") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getHymn(children24)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entity in
                                value.fulfill()
                                expect(entity).to(beNil())
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("database tables dropped") {
                    beforeEach {
                        inMemoryDBQueue.inDatabase { database in
                            // Don't worry about force_try in tests.
                            // swiftlint:disable:next force_try
                            try! database.drop(table: "SONG_DATA")
                        }
                    }
                    it("should trigger a completion failure") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        value.isInverted = true
                        let publisher = target.getHymn(children24)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.failure(.data(description: "SQLite error 1 with statement `SELECT * FROM SONG_DATA WHERE HYMN_TYPE = ? AND HYMN_NUMBER = ? AND QUERY_PARAMS = ?`: no such table: SONG_DATA"))))
                            }, receiveValue: { _ in
                                value.fulfill()
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            context("search parameter not found") {
                it("should return empty results") {
                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.searchHymn("Obama")
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { entities in
                            value.fulfill()
                            expect(entities).to(beEmpty())
                        })
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    self.wait(for: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
            context("search parameter is found") {
                let jennysSong = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "321")).title("Jenny's Song").lyricsJson("winter is coming").build()
                let rainsOfCastamere = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .chinese, hymnNumber: "123")).title("The Rains of Castamere").lyricsJson("summer is coming").build()
                let matchInTitle = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")).title("summer is coming").build()
                let matchInTitleReplacement = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")).title("summer is coming!!").build()
                let noMatch = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "noMatch")).title("no match").lyricsJson("at all").build()
                let matchInBoth = HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .korean, hymnNumber: "matchInBoth", queryParams: ["key1": "value1", "key2": "value2"])).title("summer coming").lyricsJson("no, really. summer is!").build()
                var searchResults = [SearchResultEntity]()
                beforeEach {
                    target.saveHymn(jennysSong)
                    target.saveHymn(rainsOfCastamere)
                    target.saveHymn(matchInTitle)
                    target.saveHymn(noMatch)
                    target.saveHymn(matchInBoth)
                    // Should replace matchInTitle that was previously stored
                    target.saveHymn(matchInTitleReplacement)

                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.searchHymn("summer is coming")
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            print("completion fulfilled on \(Thread.current)")
                            expect(state).to(equal(.finished))
                        }, receiveValue: { entities in
                            value.fulfill()
                            print("value fulfilled on \(Thread.current)")
                            searchResults = entities
                        })
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    self.wait(for: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
                it("should return three results") {
                    expect(searchResults).to(haveCount(3))
                }
                describe("first result") {
                    it("should be Rains of Castamere") {
                        let searchResult = searchResults[0]
                        expect(searchResult.hymnType).to(equal(HymnType.fromAbbreviatedValue(rainsOfCastamere.hymnType)!))
                        expect(searchResult.hymnNumber).to(equal(rainsOfCastamere.hymnNumber))
                        expect(searchResult.queryParams).to(beNil())
                        expect(searchResult.title).to(equal(rainsOfCastamere.title))
                    }
                    it("should match lyrics but not title") {
                        let searchResult = searchResults[0]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([0, 0, 0, 0, 3, 0, 0, 0])) // Match of length-3 in lyrics.
                    }
                }
                describe("second result") {
                    it("should be matchInBoth") {
                        let searchResult = searchResults[1]
                        expect(searchResult.hymnType).to(equal(HymnType.fromAbbreviatedValue(matchInBoth.hymnType)!))
                        expect(searchResult.hymnNumber).to(equal(matchInBoth.hymnNumber))
                        expect(searchResult.queryParams).to(equal(["key1": "value1", "key2": "value2"]))
                        expect(searchResult.title).to(equal(matchInBoth.title))
                    }
                    it("should match lyrics and title") {
                        let searchResult = searchResults[1]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([1, 0, 0, 0, 2, 0, 0, 0])) // Match of length-1 in title and match of length-2 in lyrics.
                    }
                }
                describe("third result") {
                    it("should be matchInTitle") {
                        let searchResult = searchResults[2]
                        expect(searchResult.hymnType).to(equal(HymnType.fromAbbreviatedValue(matchInTitleReplacement.hymnType)!))
                        expect(searchResult.hymnNumber).to(equal(matchInTitleReplacement.hymnNumber))
                        expect(searchResult.queryParams).to(beNil())
                        expect(searchResult.title).to(equal(matchInTitleReplacement.title))
                    }
                    it("should match title but not lyrics") {
                        let searchResult = searchResults[2]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([3, 0, 0, 0, 0, 0, 0, 0])) // Match of length-3 in title.
                    }
                }
            }
            describe("hymn code not found") {
                it("should return empty results") {
                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.getResultsBy(hymnCode: "Obama")
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { entities in
                            value.fulfill()
                            expect(entities).to(beEmpty())
                        })
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    self.wait(for: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
            describe("hymn code found") {
                it("should return results") {
                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.getResultsBy(hymnCode: "436716")
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { entities in
                            value.fulfill()
                            expect(entities).to(beEmpty())
                        })
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    self.wait(for: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
        }
    }
}
