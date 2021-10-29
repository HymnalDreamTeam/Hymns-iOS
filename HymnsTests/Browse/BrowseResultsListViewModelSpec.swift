import Combine
import Mockingbird
import Nimble
import Quick
import RealmSwift
import SwiftUI
@testable import Hymns

// swiftlint:disable:next type_body_length
class BrowseResultsListViewModelSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("BrowseResultsListViewModel") {
            let testQueue = DispatchQueue(label: "test_queue")
            var dataStore: HymnDataStoreMock!
            var tagStore: TagStoreMock!
            var target: BrowseResultsListViewModel!
            beforeEach {
                dataStore = mock(HymnDataStore.self)
                tagStore = mock(TagStore.self)
            }
            describe("getting results by category") {
                context("only category") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", hymnType: nil, subcategory: nil)) ~> { _, _, _ in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(category: "category", subcategory: nil, hymnType: nil,
                                                            backgroundQueue: testQueue, dataStore: dataStore,
                                                            mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title using only the category") {
                        expect(target.title).to(equal("category"))
                    }
                    it("should have an empty result list") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
                context("has subcategory") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", hymnType: nil, subcategory: "subcategory")) ~>
                            Just([SongResultEntity(hymnType: .classic, hymnNumber: "44", queryParams: nil, title: "classic44"),
                                  SongResultEntity(hymnType: .newSong, hymnNumber: "99", queryParams: nil, title: "newSong99")])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                        target = BrowseResultsListViewModel(category: "category", subcategory: "subcategory", hymnType: nil,
                                                            backgroundQueue: testQueue, dataStore: dataStore,
                                                            mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title using only the subcategory") {
                        expect(target.title).to(equal("subcategory"))
                    }
                    it("should have the appropriate result list") {
                        expect(target.songResults).toNot(beNil())
                        expect(target.songResults!).to(haveCount(2))
                        expect(target.songResults![0].title).to(equal("classic44"))
                        expect(target.songResults![1].title).to(equal("newSong99"))
                    }
                }
                context("data store error") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", hymnType: .newTune, subcategory: "subcategory")) ~>
                            Just([SongResultEntity]())
                                .tryMap({ _ -> [SongResultEntity] in
                                    throw URLError(.badServerResponse)
                                })
                                .mapError({ _ -> ErrorType in
                                    ErrorType.data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        target = BrowseResultsListViewModel(category: "category", subcategory: "subcategory", hymnType: .newTune,
                                                            backgroundQueue: testQueue, dataStore: dataStore,
                                                            mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title using only the subcategory") {
                        expect(target.title).to(equal("subcategory"))
                    }
                    it("should have an empty result list") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
            }
            describe("getting results by tag") {
                context("empty results") {
                    beforeEach {
                        given(tagStore.getSongsByTag(UiTag(title: "FanIntoFlames", color: .none))) ~> { _ in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none),
                                                            backgroundQueue: testQueue, mainQueue: testQueue,
                                                            tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("FanIntoFlames"))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
                context("has results") {
                    beforeEach {
                        given(tagStore.getSongsByTag(UiTag(title: "FanIntoFlames", color: .none))) ~> { _ in
                            Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", queryParams: nil, title: "classic123"),
                                  SongResultEntity(hymnType: .dutch, hymnNumber: "55", queryParams: nil, title: "dutch55")])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none),
                                                            backgroundQueue: testQueue, dataStore: dataStore,
                                                            mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("FanIntoFlames"))
                    }
                    it("should set the correct results") {
                        expect(target.songResults).toNot(beNil())
                        expect(target.songResults!).to(haveCount(2))
                        expect(target.songResults![0].title).to(equal("classic123"))
                        expect(target.songResults![1].title).to(equal("dutch55"))
                    }
                }
                context("data store error") {
                    beforeEach {
                        given(tagStore.getSongsByTag(UiTag(title: "FanIntoFlames", color: .none))) ~> { _ in
                            Just([SongResultEntity]())
                                .tryMap({ _ -> [SongResultEntity] in
                                    throw URLError(.badServerResponse)
                                })
                                .mapError({ _ -> ErrorType in
                                    .data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none),
                                                            backgroundQueue: testQueue, dataStore: dataStore,
                                                            mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("FanIntoFlames"))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
            }
            describe("getting results by hymn type") {
                context("empty results") {
                    beforeEach {
                        given(dataStore.getAllSongs(hymnType: .classic)) ~> { _ in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(hymnType: .classic, backgroundQueue: testQueue,
                                                            dataStore: dataStore, mainQueue: testQueue,
                                                            tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the hymn type") {
                        expect(target.title).to(equal(HymnType.classic.displayTitle))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
                context("has results") {
                    context("fetch chinese") {
                        beforeEach {
                            given(dataStore.getAllSongs(hymnType: .chinese)) ~> { _ in
                                Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", queryParams: nil, title: "classic123"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .dutch, hymnNumber: "55", queryParams: nil, title: "dutch55"),
                                      SongResultEntity(hymnType: .classic, hymnNumber: "11b", queryParams: nil, title: "non numeric number"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: nil, title: "should not be filtered out"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: nil, title: "should not be filtered out")])
                                    .mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .chinese, backgroundQueue: testQueue,
                                                                dataStore: dataStore, mainQueue: testQueue, tagStore: tagStore)
                            target.fetchResults()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should set the title to the hymn type") {
                            expect(target.title).to(equal(HymnType.chinese.displayTitle))
                        }
                        it("should set the correct results") {
                            expect(target.songResults).toNot(beNil())
                            expect(target.songResults!).to(haveCount(4))
                            expect(target.songResults![0].title).to(equal("3. should not be filtered out"))
                            expect(target.songResults![1].title).to(equal("5. should not be filtered out"))
                            expect(target.songResults![2].title).to(equal("55. dutch55"))
                            expect(target.songResults![3].title).to(equal("123. classic123"))
                        }
                    }
                    context("fetch cebuano") {
                        beforeEach {
                            given(dataStore.getAllSongs(hymnType: .cebuano)) ~> { _ in
                                Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", queryParams: nil, title: "classic123"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .dutch, hymnNumber: "55", queryParams: nil, title: "dutch55"),
                                      SongResultEntity(hymnType: .classic, hymnNumber: "11b", queryParams: nil, title: "non numeric number"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: nil, title: "should not be filtered out"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: nil, title: "should not be filtered out")])
                                    .mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .cebuano, backgroundQueue: testQueue,
                                                                dataStore: dataStore, mainQueue: testQueue, tagStore: tagStore)
                            target.fetchResults()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should not show the hymn number") {
                            expect(target.songResults).toNot(beNil())
                            expect(target.songResults!).to(haveCount(4))
                            expect(target.songResults![0].title).to(equal("should not be filtered out"))
                            expect(target.songResults![1].title).to(equal("should not be filtered out"))
                            expect(target.songResults![2].title).to(equal("dutch55"))
                            expect(target.songResults![3].title).to(equal("classic123"))
                        }
                    }
                    context("fetch german") {
                        beforeEach {
                            given(dataStore.getAllSongs(hymnType: .german)) ~> { _ in
                                Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", queryParams: nil, title: "classic123"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .dutch, hymnNumber: "55", queryParams: nil, title: "dutch55"),
                                      SongResultEntity(hymnType: .classic, hymnNumber: "11b", queryParams: nil, title: "non numeric number"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: [String: String](), title: "should be filtered out"),
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "5", queryParams: nil, title: "should not be filtered out"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: nil, title: "should not be filtered out")])
                                    .mapError({ _ -> ErrorType in
                                        // This will never be triggered.
                                    }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .german, backgroundQueue: testQueue,
                                                                dataStore: dataStore, mainQueue: testQueue, tagStore: tagStore)
                            target.fetchResults()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should not show the hymn number") {
                            expect(target.songResults).toNot(beNil())
                            expect(target.songResults!).to(haveCount(4))
                            expect(target.songResults![0].title).to(equal("should not be filtered out"))
                            expect(target.songResults![1].title).to(equal("should not be filtered out"))
                            expect(target.songResults![2].title).to(equal("dutch55"))
                            expect(target.songResults![3].title).to(equal("classic123"))
                        }
                    }
                }
                context("data store error") {
                    beforeEach {
                        given(dataStore.getAllSongs(hymnType: .newTune)) ~>
                            Just([SongResultEntity]())
                                .tryMap({ _ -> [SongResultEntity] in
                                    throw URLError(.badServerResponse)
                                })
                                .mapError({ _ -> ErrorType in
                                    ErrorType.data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        target = BrowseResultsListViewModel(hymnType: .newTune, backgroundQueue: testQueue,
                                                            dataStore: dataStore, mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the hymn type") {
                        expect(target.title).to(equal(HymnType.newTune.displayTitle))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
            }
        }
    }
}
