// swiftlint:disable file_length
import Combine
import Mockingbird
import Nimble
import Quick
import RealmSwift
import Resolver
import SwiftUI
@testable import Hymns

// swiftlint:disable:next type_body_length
class BrowseResultsListViewModelSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("BrowseResultsListViewModel") {
            let testQueue = DispatchQueue(label: "test_queue")
            var dataStore: HymnDataStoreMock!
            var songbaseStore: SongbaseStoreMock!
            var tagStore: TagStoreMock!
            var target: BrowseResultsListViewModel!
            beforeEach {
                dataStore = mock(HymnDataStore.self)
                songbaseStore = mock(SongbaseStore.self)
                tagStore = mock(TagStore.self)

                let test = Resolver(child: .mock)
                test.register(name: "main") { testQueue }
                test.register(name: "background") { testQueue }
                test.register { dataStore as HymnDataStore }
                test.register { songbaseStore as SongbaseStore }
                test.register { tagStore as TagStore }
                Resolver.root = test
            }
            afterEach {
                Resolver.root = .mock
            }
            describe("getting results by category") {
                context("only category") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category")) ~> { _  in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target = BrowseResultsListViewModel(category: "category")
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
                context("category and hymn type") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", hymnType: .classic)) ~> { _, _  in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target = BrowseResultsListViewModel(category: "category", hymnType: .classic)
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
                context("category and hymn type and subcategory") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", subcategory: "subcategory", hymnType: .classic)) ~> { _, _, _  in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target = BrowseResultsListViewModel(category: "category", subcategory: "subcategory", hymnType: .classic)
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
                context("category and subcategory") {
                    beforeEach {
                        given(dataStore.getResultsBy(category: "category", subcategory: "subcategory")) ~>
                        Just([SongResultEntity(hymnType: .classic, hymnNumber: "44", queryParams: nil, title: "classic44"),
                              SongResultEntity(hymnType: .newSong, hymnNumber: "99", queryParams: nil, title: "newSong99")])
                        .mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                        target = BrowseResultsListViewModel(category: "category", subcategory: "subcategory", hymnType: nil)
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
                        given(dataStore.getResultsBy(category: "category", subcategory: "subcategory", hymnType: .newTune)) ~>
                        Just([SongResultEntity]())
                            .tryMap({ _ -> [SongResultEntity] in
                                throw URLError(.badServerResponse)
                            })
                            .mapError({ _ -> ErrorType in
                                ErrorType.data(description: "forced data error")
                            }).eraseToAnyPublisher()
                        target = BrowseResultsListViewModel(category: "category", subcategory: "subcategory", hymnType: .newTune)
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
            describe("getting results by subcategory") {
                context("only subcategory") {
                    beforeEach {
                        given(dataStore.getResultsBy(subcategory: "subcategory")) ~> { _  in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target = BrowseResultsListViewModel(subcategory: "subcategory")
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
                context("subcategory and hymn type") {
                    beforeEach {
                        given(dataStore.getResultsBy(subcategory: "subcategory", hymnType: .classic)) ~> { _, _  in
                            Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target = BrowseResultsListViewModel(subcategory: "subcategory", hymnType: .classic)
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
            describe("getting results by author") {
                beforeEach {
                    given(dataStore.getResultsBy(author: "author")) ~> { _  in
                        Just([SongResultEntity(hymnType: .classic, hymnNumber: "993", title: "Song title")]).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(author: "author")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the author") {
                    expect(target.title).to(equal("Songs written by \"author\""))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(haveCount(1))
                    expect(target.songResults![0].stableId).to(equal("hymnType: h, hymnNumber: 993"))
                    expect(target.songResults![0].title).to(equal("Song title"))
                    expect(target.songResults![0].label).to(equal("Hymn 993"))
                }
            }
            describe("getting results by composer") {
                beforeEach {
                    given(dataStore.getResultsBy(composer: "composer")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(composer: "composer")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the composer") {
                    expect(target.title).to(equal("Songs composed by \"composer\""))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
                }
            }
            describe("getting results by key") {
                beforeEach {
                    given(dataStore.getResultsBy(key: "key")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(key: "key")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the key") {
                    expect(target.title).to(equal("Songs with the key \"key\""))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
                }
            }
            describe("getting results by time") {
                beforeEach {
                    given(dataStore.getResultsBy(time: "time")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(time: "time")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the time") {
                    expect(target.title).to(equal("Songs with the time \"time\""))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
                }
            }
            describe("getting results by meter") {
                beforeEach {
                    given(dataStore.getResultsBy(meter: "meter")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(meter: "meter")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the meter") {
                    expect(target.title).to(equal("Songs with the meter \"meter\""))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
                }
            }
            describe("getting results by scriptures") {
                beforeEach {
                    given(dataStore.getResultsBy(scriptures: "scriptures")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(scriptures: "scriptures")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the scriptures") {
                    expect(target.title).to(equal("scriptures"))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
                }
            }
            describe("getting results by hymn code") {
                beforeEach {
                    given(dataStore.getResultsBy(hymnCode: "hymn code")) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target = BrowseResultsListViewModel(hymnCode: "hymn code")
                    target.fetchResults()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should set the title using the hymn code") {
                    expect(target.title).to(equal("hymn code"))
                }
                it("should have an empty result list") {
                    expect(target.songResults).to(beEmpty())
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
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none))
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("Songs tagged with \"FanIntoFlames\""))
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
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none))
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("Songs tagged with \"FanIntoFlames\""))
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
                        target = BrowseResultsListViewModel(tag: UiTag(title: "FanIntoFlames", color: .none))
                        target.fetchResults()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should set the title to the tag") {
                        expect(target.title).to(equal("Songs tagged with \"FanIntoFlames\""))
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
                        target = BrowseResultsListViewModel(hymnType: .classic)
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
                                      SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "-9", queryParams: nil, title: "negative hymn numbers should be filtered out"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", queryParams: nil, title: "should not be filtered out")])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .chinese)
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
                            target = BrowseResultsListViewModel(hymnType: .cebuano)
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
                            target = BrowseResultsListViewModel(hymnType: .german)
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
                    context("fetch songbase") {
                        beforeEach {
                            given(songbaseStore.getAllSongs()) ~> {
                                Just([SongbaseResultEntity(bookId: 1, bookIndex: 1, title: "First Songbase song"),
                                      SongbaseResultEntity(bookId: 1, bookIndex: 2, title: "Second Songbase song")])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .songbase)
                            target.fetchResults()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should set the title to the hymn type") {
                            expect(target.title).to(equal(HymnType.songbase.displayTitle))
                        }
                        it("should set the correct results") {
                            expect(target.songResults).toNot(beNil())
                            expect(target.songResults!).to(haveCount(2))
                            expect(target.songResults![0].title).to(equal("1. First Songbase song"))
                            expect(target.songResults![1].title).to(equal("2. Second Songbase song"))
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
                        target = BrowseResultsListViewModel(hymnType: .newTune)
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
