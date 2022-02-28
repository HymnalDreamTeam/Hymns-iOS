import GRDB
import Quick
import Nimble
@testable import Hymns

class SongbaseStoreGrdbImplSpec: QuickSpec {

    let oldMacdonald = SongbaseSong(bookId: 1, bookIndex: 1, title: "Old Macdonald", language: "english",
                                    lyrics: "Old Macdonald had a farm", chords: "[G]Old Macdonald had a farm")
    let gotsFarm = SongbaseSong(bookId: 1, bookIndex: 2, title: "I gots a farm", language: "english",
                                lyrics: "I had a farm, how are you?",
                                chords: "[G]I had a farm, how are you?")
    let hadFarmx2 = SongbaseSong(bookId: 1, bookIndex: 3, title: "I had a farm x2", language: "english",
                                 lyrics: "I had a farm, hard a farm",
                                 chords: "[G]I had a farm, [C]hard a farm")
    let hadFarmx3 = SongbaseSong(bookId: 1, bookIndex: 4, title: "I had a farm x3", language: "english",
                                 lyrics: "I had a farm, had a farm, had a farm",
                                 chords: "[G]I had a farm, [C]hard a farm, [F]hard a farm,")

    override func spec() {
        describe("using an in-memory database queue") {
            let testQueue = DispatchQueue(label: "test_queue")
            var inMemoryDBQueue: DatabaseQueue!
            var target: SongbaseStoreGrdbImpl!
            beforeEach {
                // https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
                inMemoryDBQueue = DatabaseQueue()
                target = SongbaseStoreGrdbImpl(databaseQueue: inMemoryDBQueue, initializeTables: true)
                // Seed database with a few values
                inMemoryDBQueue.inDatabase { database in
                    // swiftlint:disable:next force_try
                    try! self.oldMacdonald.insert(database)
                    // swiftlint:disable:next force_try
                    try! self.gotsFarm.insert(database)
                    // swiftlint:disable:next force_try
                    try! self.hadFarmx2.insert(database)
                    // swiftlint:disable:next force_try
                    try! self.hadFarmx3.insert(database)
                    // swiftlint:disable:next force_try
                    try! SongbaseSong(bookId: 2, bookIndex: 1, title: "Book2Song1", language: "english",
                                      lyrics: "Book2Song1 lyrics", chords: "[G]Book2Song1 lyrics").insert(database)
                    // swiftlint:disable:next force_try
                    try! SongbaseSong(bookId: 2, bookIndex: 2, title: "Book2Song2", language: "english",
                                      lyrics: "Book2Song2 lyrics", chords: "[G]Book2Song2 lyrics").insert(database)
                    // swiftlint:disable:next force_try
                    try! SongbaseSong(bookId: 3, bookIndex: 1, title: "der Book3Song1", language: "german",
                                      lyrics: "der Book3Song1 lyrics", chords: "[G]der Book3Song1 lyrics").insert(database)
                }
            }
            describe("the database") {
                it("should have been initialized successfully") {
                    expect(target.databaseInitializedProperly).to(beTrue())
                }
            }
            describe("perform a search") {
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
                    var searchResults = [SongbaseSearchResultEntity]()
                    beforeEach {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.searchHymn("had a farm")
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
                    it("should return four results") {
                        expect(searchResults).to(haveCount(4))
                    }
                    describe("first result") {
                        it("should be \(oldMacdonald.title)") {
                            let searchResult = searchResults[0]
                            expect(searchResult.bookId).to(equal(self.oldMacdonald.bookId))
                            expect(searchResult.bookIndex).to(equal(self.oldMacdonald.bookIndex))
                            expect(searchResult.title).to(equal(self.oldMacdonald.title))
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
                        it("should be \(gotsFarm.title)") {
                            let searchResult = searchResults[1]
                            expect(searchResult.bookId).to(equal(self.gotsFarm.bookId))
                            expect(searchResult.bookIndex).to(equal(self.gotsFarm.bookIndex))
                            expect(searchResult.title).to(equal(self.gotsFarm.title))
                        }
                        it("should match lyrics and title") {
                            let searchResult = searchResults[1]
                            let matchInfo = searchResult.matchInfo
                            let byteArray = [UInt8](matchInfo)
                            expect(byteArray).to(haveCount(8))
                            expect(byteArray).to(equal([2, 0, 0, 0, 3, 0, 0, 0])) // Match of length-2 in title and length-3 in lyrics.
                        }
                    }
                    describe("third result") {
                        it("should be \(hadFarmx2.title)") {
                            let searchResult = searchResults[2]
                            expect(searchResult.bookId).to(equal(self.hadFarmx2.bookId))
                            expect(searchResult.bookIndex).to(equal(self.hadFarmx2.bookIndex))
                            expect(searchResult.title).to(equal(self.hadFarmx2.title))
                        }
                        it("should match lyrics and title") {
                            let searchResult = searchResults[2]
                            let matchInfo = searchResult.matchInfo
                            let byteArray = [UInt8](matchInfo)
                            expect(byteArray).to(haveCount(8))
                            expect(byteArray).to(equal([3, 0, 0, 0, 3, 0, 0, 0])) // Match of length-3 in title and length-6 in lyrics.
                        }
                    }
                    describe("fourth result") {
                        it("should be \(hadFarmx3.title)") {
                            let searchResult = searchResults[3]
                            expect(searchResult.bookId).to(equal(self.hadFarmx3.bookId))
                            expect(searchResult.bookIndex).to(equal(self.hadFarmx3.bookIndex))
                            expect(searchResult.title).to(equal(self.hadFarmx3.title))
                        }
                        it("should match lyrics and title") {
                            let searchResult = searchResults[3]
                            let matchInfo = searchResult.matchInfo
                            let byteArray = [UInt8](matchInfo)
                            expect(byteArray).to(haveCount(8))
                            expect(byteArray).to(equal([3, 0, 0, 0, 3, 0, 0, 0])) // Match of length-3 in title and length-3 in lyrics.
                        }
                    }
                }
            }
            describe("get all the songs") {
                it("should return all the songbase songs") {
                    let completion = XCTestExpectation(description: "completion received")
                    let value = XCTestExpectation(description: "value received")
                    let publisher = target.getAllSongs()
                        .print(self.description)
                        .receive(on: testQueue)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { allResults in
                            value.fulfill()
                            expect(allResults).to(equal(
                                [SongbaseResultEntity(bookId: 1, bookIndex: 1, title: "Old Macdonald"),
                                 SongbaseResultEntity(bookId: 1, bookIndex: 2, title: "I had a farm"),
                                 SongbaseResultEntity(bookId: 1, bookIndex: 3, title: "I had a farm x2"),
                                 SongbaseResultEntity(bookId: 1, bookIndex: 4, title: "I had a farm x3")]))
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

extension SongbaseSong: PersistableRecord, MutablePersistableRecord {

    // https://github.com/groue/GRDB.swift/blob/master/README.md#conflict-resolution
    public static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    // Define database columns from CodingKeys
    private enum Columns {
        static let bookId = Column(CodingKeys.bookId)
        static let bookIndex = Column(CodingKeys.bookIndex)
        static let title = Column(CodingKeys.title)
        static let language = Column(CodingKeys.language)
        static let lyrics = Column(CodingKeys.lyrics)
        static let chords = Column(CodingKeys.chords)
    }
}
