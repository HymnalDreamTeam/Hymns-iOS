import Combine
import Mockingbird
import Nimble
import Quick
import RealmSwift
import SwiftUI
@testable import Hymns

class BrowseResultsListViewModelSpec: QuickSpec {
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
                                .data(description: "This will never get called")
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
                                    .data(description: "This will never get called")
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
                                .data(description: "This will never get called")
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
                                  SongResultEntity(hymnType: .scripture, hymnNumber: "55", queryParams: nil, title: "scripture55")])
                                .mapError({ _ -> ErrorType in
                                    .data(description: "This will never get called")
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
                        expect(target.songResults![1].title).to(equal("scripture55"))
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
                                .data(description: "This will never get called")
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
                        expect(target.title).to(equal(HymnType.classic.displayValue))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
                context("has results") {
                    beforeEach {
                        given(dataStore.getAllSongs(hymnType: .classic)) ~> { _ in
                            Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", queryParams: nil, title: "classic123"),
                                  SongResultEntity(hymnType: .scripture, hymnNumber: "55", queryParams: nil, title: "scripture55")]).mapError({ _ -> ErrorType in
                                    .data(description: "This will never get called")
                                  }).eraseToAnyPublisher()
                        }
                        target = BrowseResultsListViewModel(hymnType: .classic, backgroundQueue: testQueue,
                                                            dataStore: dataStore, mainQueue: testQueue, tagStore: tagStore)
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the hymn type") {
                        expect(target.title).to(equal(HymnType.classic.displayValue))
                    }
                    it("should set the correct results") {
                        expect(target.songResults).toNot(beNil())
                        expect(target.songResults!).to(haveCount(2))
                        expect(target.songResults![0].title).to(equal("55. scripture55"))
                        expect(target.songResults![1].title).to(equal("123. classic123"))
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
                        expect(target.title).to(equal(HymnType.newTune.displayValue))
                    }
                    it("should have no results") {
                        expect(target.songResults).to(beEmpty())
                    }
                }
            }
        }
    }
}
