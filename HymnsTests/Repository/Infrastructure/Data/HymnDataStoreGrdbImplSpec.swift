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
                    target.saveHymn(HymnIdEntityBuilder(classic_1151_hymn_reference.hymnIdEntity).songId(songId!).build())

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.id = 5
                        builder.title = "new song 145"
                        builder.hymnCode = ["171214436716555"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: newSong145, songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.id = 4
                        builder.title = "cebuano 123"
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: cebuano123, songId: songId!))

                    // saving another cebuano123 should replace the old one.
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.id = 3
                        builder.title = "new cebuano title"
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: cebuano123, songId: songId!))

                    // this one should be a whole new song in the db
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.id = 1
                        builder.title = "chinese simplified 123"
                        builder.hymnCode = ["171214436716555"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: chineseSimplified123, songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.id = 6
                        builder.title = "songbase 1"
                        builder.inlineChords = InlineChordsEntity([ChordLineEntity([ChordWordEntity("chords")])])!
                    })
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
                                                                      hymnEntity: HymnEntity.with { builder in
                                    builder.id = 3
                                    builder.title = "new cebuano title"
                                })))
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
                                        hymnEntity: HymnEntity.with { builder in
                                            builder.id = 1
                                            builder.title = "chinese simplified 123"
                                            builder.hymnCode = ["171214436716555"]
                                        })))
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
                                        hymnEntity: HymnEntity.with { builder in
                                            builder.id = 6
                                            builder.title = "songbase 1"
                                            builder.inlineChords = InlineChordsEntity([ChordLineEntity([ChordWordEntity("chords")])])!
                                        })))
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
                        var songId = target.saveHymn(HymnEntity.with { builder in
                            builder.id = 7
                            builder.title = "classic 3"
                        })
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "4")
                        songId = target.saveHymn(HymnEntity.with { builder in
                            builder.id = 8
                            builder.title = "classic 4"
                        })
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .classic, hymnNumber: "5")
                        songId = target.saveHymn(HymnEntity.with { builder in
                            builder.id = 9
                            builder.title = "classic 5"
                        })
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: "3")
                        songId = target.saveHymn(HymnEntity.with { builder in
                            builder.id =  10
                            builder.title = "chineseSupplementSimplified 3"
                        })
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))

                        hymnIdentifier = HymnIdentifier(hymnType: .tagalog, hymnNumber: "2")
                        songId = target.saveHymn(HymnEntity.with { builder in
                            builder.id = 11
                            builder.title = "tagalog 2"
                        })
                        target.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId!))
                    }
                    context("hymn type exists") {
                        it("should return hymn numbers of that type") {
                            let completion = XCTestExpectation(description: "completion received")
                            let value = XCTestExpectation(description: "value received")
                            let publisher = target.getHymns(by: .classic)
                                .print(self.description)
                                .receive(on: testQueue)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.finished))
                                }, receiveValue: { entities in
                                    value.fulfill()
                                    expect(entities).to(equal([
                                        SongResultEntity(hymnType: .classic, hymnNumber: "1151",
                                                         title: "Hymn: Drink! A river pure and clear that\'s flowing from the throne"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "3", title: "classic 3"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "4", title: "classic 4"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "5", title: "classic 5")]))
                                })
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            await self.fulfillment(of: [completion, value], timeout: testTimeout)
                            publisher.cancel()
                        }
                    }
                    context("hymn types exists") {
                        it("should return hymn numbers of those types") {
                            let completion = XCTestExpectation(description: "completion received")
                            let value = XCTestExpectation(description: "value received")
                            let publisher = target.getHymns(by: [.classic, .chineseSupplementSimplified])
                                .print(self.description)
                                .receive(on: testQueue)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.finished))
                                }, receiveValue: { entities in
                                    value.fulfill()
                                    expect(entities).to(equal([
                                        SongResultEntity(hymnType: .classic, hymnNumber: "1151",
                                                         title: "Hymn: Drink! A river pure and clear that\'s flowing from the throne"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "3", title: "classic 3"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "4", title: "classic 4"),
                                        SongResultEntity(hymnType: .classic, hymnNumber: "5", title: "classic 5"),
                                        SongResultEntity(hymnType: .chineseSupplementSimplified, hymnNumber: "3", title: "chineseSupplementSimplified 3") ]))
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
                            let publisher = target.getHymns(by: .liederbuch)
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
                let jennysSong = HymnEntity.with { builder in
                    builder.title = "Jenny's Song"
                    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["winter is coming"])])
                }

                let rainsOfCastamereId = HymnIdentifier(hymnType: .chinese, hymnNumber: "123")
                let rainsOfCastamere = HymnEntity.with { builder in
                    builder.title = "The Rains of Castamere"
                    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["summer is coming"])])
                }

                let matchInTitleId = HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")
                let matchInTitle = HymnEntity.with { builder in
                    builder.title = "summer is coming"
                }

                let matchInTitleReplacementId = HymnIdentifier(hymnType: .howardHigashi, hymnNumber: "matchInTitle")
                let matchInTitleReplacement = HymnEntity.with { builder in
                    builder.title = "summer is coming!!"
                }

                let noMatchId = HymnIdentifier(hymnType: .chineseSupplement, hymnNumber: "noMatch")
                let noMatch = HymnEntity.with { builder in
                    builder.title = "no match"
                    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["at all"])])
                }
                
                let matchInBothId = HymnIdentifier(hymnType: .korean, hymnNumber: "matchInBoth")
                let matchInBoth = HymnEntity.with { builder in
                    builder.title = "summer coming"
                    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["no, really. summer is!"])])
                }

                let missingId = HymnEntity.with { builder in
                    builder.title = "missing id"
                    builder.lyrics = LyricsEntity([VerseEntity(verseType: .verse, lineStrings: ["summer is coming"])])
                }

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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.author = ["Michelle Obama"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.author = ["Pete Buttigieg"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.composer = ["Michelle Obama"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.composer = ["Pete Buttigieg"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.key = ["A"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.key = ["A#"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.time = ["4/4"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.time = ["3/4"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.meter = ["8.8.8.8"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.meter = ["Peculiar Meter"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.scriptures = ["Gen. 12"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.scriptures = ["Gen. 2"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "Becoming", songId: 1)]))
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
                let becoming = HymnEntity.with { builder in
                    builder.title = "Becoming"
                    builder.hymnCode = ["33829223232"]
                }

                let shortestWayHomeId = HymnIdentifier(hymnType: .classic, hymnNumber: "2")
                let shortestWayHome = HymnEntity.with { builder in
                    builder.title = "Shortest Way Home"
                    builder.hymnCode = ["436716"]
                }
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
                                expect(entities).to(equal([SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "Shortest Way Home", songId: 2)]))
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
