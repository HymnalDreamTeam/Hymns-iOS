import GRDB
import Quick
import Nimble
@testable import Hymns

// swiftlint:disable:next type_body_length
class HymnDataStoreGrdbImpl_BrowseSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("using an in-memory database queue") {
            var inMemoryDBQueue: DatabaseQueue!
            var target: HymnDataStoreGrdbImpl!
            beforeEach {
                // https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
                inMemoryDBQueue = DatabaseQueue()
                target = HymnDataStoreGrdbImpl(databaseQueue: inMemoryDBQueue, initializeTables: true)
            }
            describe("save songs with categories") {
                beforeEach {
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: classic1151).title("classic 1151").category("category 1").subcategory("subcategory 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: newSong145).title("new song 145").category("category 1").subcategory("subcategory 2").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: songbase1).title("songbase 1").category("category 2").subcategory("subcategory 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: classic500).title("classic 500").category("category 1").subcategory("subcategory 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: classic501).title("classic 501").category("category 2").subcategory("subcategory 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: classic1109).title("classic 1109").category("category 2").subcategory("subcategory 2").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "2", queryParams: ["q1": "v1", "q2": "v2"])).title("classic 2").category("category 1").subcategory("subcategory 5").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .spanish, hymnNumber: "1")).title("spanish 1").category("category 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .spanish, hymnNumber: "2")).title("spanish 2").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .spanish, hymnNumber: "3")).title("spanish 3").category("category 1").subcategory("subcategory 1").build())
                }
                describe("getting all categories") {
                    it("should contain categories with their counts") {
                        let completion = XCTestExpectation(description: "completion received")
                        let value = XCTestExpectation(description: "value received")
                        let publisher = target.getAllCategories()
                            .print(self.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { categories in
                                value.fulfill()
                                expect(categories).to(haveCount(5))
                                expect(categories[0]).to(equal(CategoryEntity(category: "category 1", subcategory: "subcategory 1", count: 3)))
                                expect(categories[1]).to(equal(CategoryEntity(category: "category 1", subcategory: "subcategory 2", count: 1)))
                                expect(categories[2]).to(equal(CategoryEntity(category: "category 1", subcategory: "subcategory 5", count: 1)))
                                expect(categories[3]).to(equal(CategoryEntity(category: "category 2", subcategory: "subcategory 1", count: 2)))
                                expect(categories[4]).to(equal(CategoryEntity(category: "category 2", subcategory: "subcategory 2", count: 1)))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
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
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .newSong, hymnNumber: "145", queryParams: nil, title: "new song 145")))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                                expect(results[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", queryParams: ["q1": "v1", "q2": "v2"], title: "classic 2")))
                                expect(results[4]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "1", queryParams: nil, title: "spanish 1")))
                                expect(results[5]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", queryParams: nil, title: "spanish 3")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", queryParams: ["q1": "v1", "q2": "v2"], title: "classic 2")))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", queryParams: nil, title: "spanish 3")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .songbase, hymnNumber: "1", queryParams: nil, title: "songbase 1")))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                                expect(results[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", queryParams: nil, title: "classic 501")))
                                expect(results[4]).to(equal(SongResultEntity(hymnType: .spanish, hymnNumber: "3", queryParams: nil, title: "spanish 3")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(results[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(results[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                                expect(results[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", queryParams: nil, title: "classic 501")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
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
                                expect(songs[0]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1109", queryParams: nil, title: "classic 1109")))
                                expect(songs[1]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151")))
                                expect(songs[2]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "2", queryParams: ["q2": "v2", "q1": "v1"], title: "classic 2")))
                                expect(songs[3]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "500", queryParams: nil, title: "classic 500")))
                                expect(songs[4]).to(equal(SongResultEntity(hymnType: .classic, hymnNumber: "501", queryParams: nil, title: "classic 501")))
                            })
                        self.wait(for: [completion, value], timeout: testTimeout)
                        publisher.cancel()
                    }
                }
            }
            describe("save some scripture songs") {
                beforeEach {
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1")).title("classic 1").scriptures("scripture").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "2")).title("classic 2").scriptures("scripture").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "3")).title("classic 3").scriptures("scripture").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "no title")).scriptures("scripture").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "1")).title("children 1").scriptures("scripture").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "no scripture")).title("classic 1").build())
                    target.saveHymn(HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .children, hymnNumber: "1")).title("children 1").scriptures("scripture 2").build()) // replaces the previous children1 song
                }
                let expected = [ScriptureEntity(title: "classic 1", hymnType: .classic, hymnNumber: "1", queryParams: nil, scriptures: "scripture"),
                                ScriptureEntity(title: "classic 2", hymnType: .classic, hymnNumber: "2", queryParams: nil, scriptures: "scripture"),
                                ScriptureEntity(title: "classic 3", hymnType: .classic, hymnNumber: "3", queryParams: nil, scriptures: "scripture"),
                                ScriptureEntity(title: "children 1", hymnType: .children, hymnNumber: "1", queryParams: nil, scriptures: "scripture 2")]
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
                    self.wait(for: [completion, value], timeout: testTimeout)
                    publisher.cancel()
                }
            }
        }
    }
}
