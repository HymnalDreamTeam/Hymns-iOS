// swiftlint:disable file_length
import GRDB
import Quick
import Mockingbird
import Nimble
@testable import Hymns

// swiftlint:disable:next type_body_length
class HymnDataStoreGrdbImplSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("using an in-memory database queue") {
            var firebaseLogger: FirebaseLoggerMock!
            let testQueue = DispatchQueue(label: "test_queue")
            var inMemoryDBQueue: DatabaseQueue!
            var target: HymnDataStoreGrdbImpl!
            beforeEach {
                // https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
                inMemoryDBQueue = DatabaseQueue()
                firebaseLogger = mock(FirebaseLogger.self)
                target = HymnDataStoreGrdbImpl(databaseQueue: inMemoryDBQueue, firebaseLogger: firebaseLogger, initializeTables: true)
            }
            afterEach {
                verify(firebaseLogger.logError(any())).wasNeverCalled()
                verify(firebaseLogger.logError(any(), message: any())).wasNeverCalled()
                verify(firebaseLogger.logError(any(), extraParameters: any())).wasNeverCalled()
                verify(firebaseLogger.logError(any(), message: any(), extraParameters: any())).wasNeverCalled()
            }
            describe("the database") {
                it("should have been initialized successfully") {
                    expect(target.databaseInitializedProperly).to(beTrue())
                }
            }
            describe("save a few songs") {
                beforeEach {
                    var songId = target.saveHymn(classic_1151_hymn_reference.hymnEntity)
                    target.saveHymn(HymnIdEntityBuilder(classic_1151_hymn_reference.hymnIdEntity)!.songId(songId!).build())

                    songId = target.saveHymn(HymnEntityBuilder(id: 5).title("new song 145").hymnCode("171214436716555").build())
                    target.saveHymn(HymnIdEntity(hymnIdentifier: newSong145, songId: songId!))

                    songId = target.saveHymn(HymnEntityBuilder(id: 4).title("cebuano 123").build())
                    target.saveHymn(HymnIdEntity(hymnIdentifier: cebuano123, songId: songId!))

                    // saving another cebuano123 should replace the old one.
                    songId = target.saveHymn(HymnEntityBuilder(id: 3).title("new cebuano title").build())
                    target.saveHymn(HymnIdEntity(hymnIdentifier: cebuano123, songId: songId!))

                    // this one should be a whole new song in the db
                    songId = target.saveHymn(HymnEntityBuilder(id: 1).title("chinese simplified 123").hymnCode("171214436716555").build())
                    target.saveHymn(HymnIdEntity(hymnIdentifier: chineseSimplified123, songId: songId!))

                    songId = target.saveHymn(HymnEntityBuilder(id: 6).title("songbase 1").inlineChords("chords").build())
                    target.saveHymn(HymnIdEntity(hymnIdentifier: songbase1, songId: songId!))
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
                                expect(entity).to(equal(HymnReference(hymnIdEntity: HymnIdEntity(hymnIdentifier: cebuano123, songId: 3),
                                                                      hymnEntity: HymnEntityBuilder(id: 3).title("new cebuano title").build())))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("getting a simplified chinese song") {
                    it("should return the stored song") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getHymn(chineseSimplified123)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entity in
                                value.fulfill()
                                expect(entity).to(equal(
                                    HymnReference(
                                        hymnIdEntity: HymnIdEntity(hymnIdentifier: chineseSimplified123, songId: 1),
                                        hymnEntity: HymnEntityBuilder(id: 1).title("chinese simplified 123").hymnCode("171214436716555").build())))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("getting a songbase song") {
                    it("should return the stored song") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getHymn(songbase1)
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entity in
                                value.fulfill()
                                expect(entity).to(equal(
                                    HymnReference(
                                        hymnIdEntity: HymnIdEntity(hymnIdentifier: songbase1, songId: 6),
                                        hymnEntity: HymnEntityBuilder(id: 6).title("songbase 1").inlineChords("chords").build())))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
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
                                expect(state).to(equal(.failure(.data(description: "SQLite error 1 with statement `SELECT * FROM SONG_DATA JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID WHERE HYMN_TYPE = ? AND HYMN_NUMBER = ?`: no such table: SONG_DATA"))))
                            }, receiveValue: { _ in
                                value.fulfill()
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting by hymn number") {
                    beforeEach {
                        var hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "3")
                        var songId = target.saveHymn(HymnEntityBuilder(id: 7).title("classic 3").build())
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "4")
                        songId = target.saveHymn(HymnEntityBuilder(id: 8).title("classic 4").build())
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "5")
                        songId = target.saveHymn(HymnEntityBuilder(id: 9).title("classic 5").build())
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))
                    }
                    context("hymn type exists") {
                        it("should return hymn numbers of that type") {
                            let completion = XCTestExpectation(description: "completion received")
                            let value = XCTestExpectation(description: "value received")
                            let publisher = target.getHymnNumbers(by: .classic)
                                .print(self.description)
                                .receive(on: testQueue)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.finished))
                                }, receiveValue: { entities in
                                    value.fulfill()
                                    expect(entities).to(equal(["1151", "3", "4", "5"]))
                                })
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            await self.fulfillment(of: [completion, value], timeout: testTimeout)
                            publisher.cancel()
                        }
                    }
                    context("hymn type does not exist") {
                        it("should return empty list") {
                            let completion = XCTestExpectation(description: "completion received")
                            let value = XCTestExpectation(description: "value received")
                            let publisher = target.getHymnNumbers(by: .liederbuch)
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
                            await self.fulfillment(of: [completion, value], timeout: testTimeout)
                            publisher.cancel()
                        }
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
                    await self.fulfillment(of: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
            context("search parameter is found") {
                let jennysSongId = HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "321")
                let jennysSong = HymnEntityBuilder().title("Jenny's Song").lyrics([VerseEntity(verseType: .verse, lineStrings: ["winter is coming"])]).build()

                let rainsOfCastamereId = HymnIdentifier(hymnType: .chinese, hymnNumber: "123")
                let rainsOfCastamere = HymnEntityBuilder().title("The Rains of Castamere").lyrics([VerseEntity(verseType: .verse, lineStrings: ["summer is coming"])]).build()

                let matchInTitleId = HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")
                let matchInTitle = HymnEntityBuilder().title("summer is coming").build()

                let matchInTitleReplacementId = HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")
                let matchInTitleReplacement = HymnEntityBuilder().title("summer is coming!!").build()

                let noMatchId = HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "noMatch")
                let noMatch = HymnEntityBuilder().title("no match").lyrics([VerseEntity(verseType: .verse, lineStrings: ["at all"])]).build()

                let matchInBothId = HymnIdentifier(hymnType: .korean, hymnNumber: "matchInBoth")
                let matchInBoth = HymnEntityBuilder().title("summer coming").lyrics([VerseEntity(verseType: .verse, lineStrings: ["no, really. summer is!"])]).build()

                let missingId = HymnEntityBuilder().title("missing id").lyrics([VerseEntity(verseType: .verse, lineStrings: ["summer is coming"])]).build()

                var searchResults = [SearchResultEntity]()
                beforeEach {
                    var songId = target.saveHymn(jennysSong)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: jennysSongId, songId: songId!))

                    songId = target.saveHymn(rainsOfCastamere)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: rainsOfCastamereId, songId: songId!))

                    songId = target.saveHymn(matchInTitle)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: matchInTitleId, songId: songId!))

                    songId = target.saveHymn(noMatch)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: noMatchId, songId: songId!))

                    songId = target.saveHymn(matchInBoth)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: matchInBothId, songId: songId!))

                    // Should replace matchInTitle that was previously stored
                    songId = target.saveHymn(matchInTitleReplacement)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: matchInTitleReplacementId, songId: songId!))

                    // Dangling song that's missing the HymnIdEntity. This shouldn't happen in the wild, but if it does, it should
                    // just be skipped.
                    _ = target.saveHymn(missingId)

                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.searchHymn("summer is coming")
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { entities in
                            value.fulfill()
                            searchResults = entities
                        })
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    await self.fulfillment(of: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
                it("should return three results") {
                    expect(searchResults).to(haveCount(4))
                }
                describe("first result") {
                    it("should be Jenny's Song") {
                        let searchResult = searchResults[0]
                        expect(searchResult.hymnType).to(equal(jennysSongId.hymnType))
                        expect(searchResult.hymnNumber).to(equal(jennysSongId.hymnNumber))
                        expect(searchResult.title).to(equal(jennysSong.title))
                    }
                    it("should match lyrics and title") {
                        let searchResult = searchResults[0]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([0, 0, 0, 0, 2, 0, 0, 0])) // Match of length-2 in lyrics.
                    }
                }
                describe("second result") {
                    it("should be Rains of Castamere") {
                        let searchResult = searchResults[1]
                        expect(searchResult.hymnType).to(equal(rainsOfCastamereId.hymnType))
                        expect(searchResult.hymnNumber).to(equal(rainsOfCastamereId.hymnNumber))
                        expect(searchResult.title).to(equal(rainsOfCastamere.title))
                    }
                    it("should match lyrics but not title") {
                        let searchResult = searchResults[1]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([0, 0, 0, 0, 3, 0, 0, 0])) // Match of length-3 in lyrics.
                    }
                }
                describe("third result") {
                    it("should be matchInTitle") {
                        let searchResult = searchResults[2]
                        expect(searchResult.hymnType).to(equal(matchInBothId.hymnType))
                        expect(searchResult.hymnNumber).to(equal(matchInBothId.hymnNumber))
                        expect(searchResult.title).to(equal(matchInBoth.title))
                    }
                    it("should match title but not lyrics") {
                        let searchResult = searchResults[2]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([1, 0, 0, 0, 2, 0, 0, 0])) // Match of length-1 in title and match of length-2 in lyrics.
                    }
                }
                describe("fourth result") {
                    it("should be matchInTitle") {
                        let searchResult = searchResults[3]
                        expect(searchResult.hymnType).to(equal(matchInTitleReplacementId.hymnType))
                        expect(searchResult.hymnNumber).to(equal(matchInTitleReplacementId.hymnNumber))
                        expect(searchResult.title).to(equal(matchInTitleReplacement.title))
                    }
                    it("should match title but not lyrics") {
                        let searchResult = searchResults[3]
                        let matchInfo = searchResult.matchInfo
                        let byteArray = [UInt8](matchInfo)
                        expect(byteArray).to(haveCount(8))
                        expect(byteArray).to(equal([3, 0, 0, 0, 0, 0, 0, 0])) // Match of length-3 in title.
                    }
                }
            }
            describe("search by author") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").author("Michelle Obama").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").author("Pete Buttigieg").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("author not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(author: "Barack Obama")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("author found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(author: "Michelle Obama")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by composer") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").composer("Michelle Obama").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").composer("Pete Buttigieg").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("composer not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(composer: "Barack Obama")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("composer found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(composer: "Michelle Obama")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by key") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").key("A").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").key("A#").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("key not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(key: "F")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("key found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(key: "A")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by time") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").time("4/4").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").time("3/4").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("time not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(time: "2/4")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("time found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(time: "4/4")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by meter") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").meter("8.8.8.8").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").meter("Peculiar Meter").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("meter not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(meter: "4.4.4.4")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("meter found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(meter: "8.8.8.8")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by scriptures") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").scriptures("Gen. 12").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").scriptures("Gen. 2").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                context("scriptures not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(scriptures: "Gen. 1")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                context("scriptures found") {
                    it("should return results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(scriptures: "Gen. 12")
                            .print(self.description)
                            .receive(on: testQueue)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("search by hymn code") {
                let becomingId = HymnIdentifier(hymnType: .classic, hymnNumber: "1")
                let becoming = HymnEntityBuilder().title("Becoming").hymnCode("33829223232").build()

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntityBuilder().title("Shortest Way Home").hymnCode("436716").build()
                beforeEach {
                    var songId = target.saveHymn(becoming)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: becomingId, songId: songId!))

                    songId = target.saveHymn(shortestWayHome)
                     target.saveHymn(HymnIdEntity(hymnIdentifier: shortestWayHomeId, songId: songId!))
                }
                describe("hymn code not found") {
                    it("should return empty results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(hymnCode: "3")
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
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "Shortest Way Home")]))
                            })
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
        }
    }
}
