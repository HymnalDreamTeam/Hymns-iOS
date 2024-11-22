import GRDB
import Quick
import Mockingbird
import Nimble
@testable import Hymns

// swiftlint:disable:next type_body_length
class HymnDataStoreGrdbImpl_BrowseSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("using an in-memory database queue") {
            var firebaseLogger: FirebaseLoggerMock!
            var inMemoryDBQueue: DatabaseQueue!
            var target: HymnDataStoreGrdbImpl!
            beforeEach {
                // https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
                inMemoryDBQueue = DatabaseQueue()
                firebaseLogger = mock(FirebaseLogger.self)
                target = HymnDataStoreGrdbImpl(databaseQueue: inMemoryDBQueue, firebaseLogger: firebaseLogger, initializeTables: true)
            }
            describe("save songs with categories") {
                beforeEach {
                    var songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 1151"
                        builder.category = ["category 1"]
                        builder.subcategory = ["subcategory 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: classic1151, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "new song 145"
                        builder.category = ["category 1"]
                        builder.subcategory = ["subcategory 2"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: newSong145, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "songbase 1"
                        builder.category = ["category 2"]
                        builder.subcategory = ["subcategory 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: songbase1, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 500"
                        builder.category = ["category 1"]
                        builder.subcategory = ["subcategory 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: classic500, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 501"
                        builder.category = ["category 2"]
                        builder.subcategory = ["subcategory 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: classic501, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 1109"
                        builder.category = ["category 2"]
                        builder.subcategory = ["subcategory 2"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: classic1109, songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 2"
                        builder.category = ["category 1"]
                        builder.subcategory = ["subcategory 5"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "2"), songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "spanish 1"
                        builder.category = ["category 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .spanish, hymnNumber: "1"), songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "spanish 2"
                    })
                    target.saveHymn(HymnIdEntity(hymnType: .spanish, hymnNumber: "2", songId: songId!))
                    
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "spanish 3"
                        builder.category = ["category 1"]
                        builder.subcategory = ["subcategory 1"]
                    })
                    target.saveHymn(HymnIdEntity(hymnType: .spanish, hymnNumber: "3", songId: songId!))
                }
                afterEach {
                    verify(firebaseLogger.logError(any())).wasNeverCalled()
                    verify(firebaseLogger.logError(any(), message: any())).wasNeverCalled()
                    verify(firebaseLogger.logError(any(), extraParameters: any())).wasNeverCalled()
                    verify(firebaseLogger.logError(any(), message: any(), extraParameters: any())).wasNeverCalled()
                }
                describe("getting all classic categories") {
                    it("should contain categories with their counts") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getCategories(by: .classic)
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { categories in
                                value.fulfill()
                                expect(categories).to(haveCount(4))
                                expect(categories[0]).to(equal(CategoryEntity(category: "category 1", subcategory: "subcategory 1", count: 2)))
                                expect(categories[1]).to(equal(CategoryEntity(category: "category 1", subcategory: "subcategory 5", count: 1)))
                                expect(categories[2]).to(equal(CategoryEntity(category: "category 2", subcategory: "subcategory 1", count: 1)))
                                expect(categories[3]).to(equal(CategoryEntity(category: "category 2", subcategory: "subcategory 2", count: 1)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by category") {
                    it("should contain song results in that category") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(category: "category 1")
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(6))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .newSong, hymnNumber: "145", title: "new song 145", songId: 2)))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                                expect(results[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "classic 2", songId: 7)))
                                expect(results[4]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "1", title: "spanish 1", songId: 8)))
                                expect(results[5]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", title: "spanish 3", songId: 10)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by category and hymn type") {
                    it("should contain song results in that category and hymn type") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(category: "category 1", hymnType: .classic)
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(3))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "classic 2", songId: 7)))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by category and subcategory") {
                    it("should contain song results in that category and subcategory") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(category: "category 1", subcategory: "subcategory 1")
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(3))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", title: "spanish 3", songId: 10)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by category and hymn type and subcategory") {
                    it("should contain song results in that category and hymn type and subcategory") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(category: "category 1", subcategory: "subcategory 1", hymnType: .classic)
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(2))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by category that does not exist") {
                    it("should contain empty song results") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(category: "nonexistent category")
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(beEmpty())
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by subcategory") {
                    it("should contain song results in that subcategory") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(subcategory: "subcategory 1")
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(5))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .songbaseOther, hymnNumber: "1", title: "songbase 1", songId: 3)))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                                expect(results[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", title: "classic 501", songId: 5)))
                                expect(results[4]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", title: "spanish 3", songId: 10)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting results by subcategory and hymn type") {
                    it("should contain song results in that subcategory and hymn type") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getResultsBy(subcategory: "subcategory 1", hymnType: .classic)
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { results in
                                value.fulfill()
                                expect(results).to(haveCount(3))
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", title: "classic 501", songId: 5)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
                describe("getting all clasic songs") {
                    it("should contain all the classic songs") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getAllSongs(hymnType: .classic)
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { songs in
                                value.fulfill()
                                expect(songs).to(haveCount(5))
                                expect(songs[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1109", title: "classic 1109", songId: 6)))
                                expect(songs[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151", songId: 1)))
                                expect(songs[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "classic 2", songId: 7)))
                                expect(songs[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "classic 500", songId: 4)))
                                expect(songs[4]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", title: "classic 501", songId: 5)))
                            })
                        await self.fulfillment(of: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("save some scripture songs") {
                beforeEach {
                    var songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 1"
                        builder.scriptures = ["scripture"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1"), songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 1"
                        builder.scriptures = ["scripture"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1"), songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 2"
                        builder.scriptures = ["scripture"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "2"), songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 3"
                        builder.scriptures = ["scripture"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "3"), songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.scriptures = ["scripture"]
                    })
                    // songId is nil because there's no title
                    expect(songId).to(beNil())
                    verify(firebaseLogger.logError(
                        any(), message: "Save entity failed",
                        extraParameters: ["hymn": String(describing: HymnEntity.with { builder in
                            builder.scriptures = ["scripture"]
                        })]))
                    .wasCalled(1)

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "children 1"
                        builder.scriptures = ["scripture"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "1"), songId: songId!))

                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "classic 1"
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "no scripture"), songId: songId!))

                    // replaces the previous children1 song
                    songId = target.saveHymn(HymnEntity.with { builder in
                        builder.title = "children 1"
                        builder.scriptures = ["scripture 2"]
                    })
                    print(songId!)
                    target.saveHymn(HymnIdEntity(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "1"), songId: songId!))
                }
                afterEach {
                    verify(firebaseLogger.logError(any())).wasNeverCalled()
                    verify(firebaseLogger.logError(any(), message: any())).wasNeverCalled()
                    verify(firebaseLogger.logError(any(), extraParameters: any())).wasNeverCalled()
                }
                let expected = [ScriptureEntity(title: "classic 1", hymnType: .classic, hymnNumber: "1", scriptures: "scripture"),
                                ScriptureEntity(title: "classic 2", hymnType: .classic, hymnNumber: "2", scriptures: "scripture"),
                                ScriptureEntity(title: "classic 3", hymnType: .classic, hymnNumber: "3", scriptures: "scripture"),
                                ScriptureEntity(title: "children 1", hymnType: .children, hymnNumber: "1", scriptures: "scripture 2")
                ]
                it("should fetch songs with scripture references") {
                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.getScriptureSongs()
                        .print(self.description)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { scriptures in
                            value.fulfill()
                            expect(scriptures).to(equal(expected))
                        })
                    await self.fulfillment(of: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
        }
    }
}
