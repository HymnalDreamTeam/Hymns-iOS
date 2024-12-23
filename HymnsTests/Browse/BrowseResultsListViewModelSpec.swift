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
    override class func spec() {
        describe("BrowseResultsListViewModel") {
            let testQueue = DispatchQueue(label: "test_queue")
            var dataStore: HymnDataStoreMock!
            var tagStore: TagStoreMock!
            var target: BrowseResultsListViewModel!
            beforeEach {
                dataStore = mock(HymnDataStore.self)
                tagStore = mock(TagStore.self)

                let test = Resolver(child: .mock)
                test.register(name: "main") { testQueue }
                test.register(name: "background") { testQueue }
                test.register { dataStore as HymnDataStore }
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
                        Just([SongResultEntity(hymnType: .classic, hymnNumber: "44", title: "classic44"),
                              SongResultEntity(hymnType: .newSong, hymnNumber: "99", title: "newSong99")])
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
                            Just([SongResultEntity(hymnType: .classic, hymnNumber: "123", title: "classic123"),
                                  SongResultEntity(hymnType: .dutch, hymnNumber: "55", title: "dutch55")])
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
                                Just([SongResultEntity(hymnType: .chinese, hymnNumber: "11b", title: "non numeric number"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "5", title: "5th song"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "12", title: "Twelve"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "-9", title: "negative hymn number"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "3", title: "Third song"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "abcd333", title: "No leading numbers"),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "300", title: nil),
                                      SongResultEntity(hymnType: .chinese, hymnNumber: "11", title: "11")])
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
                        it("sort the results") {
                            expect(target.songResults).toNot(beNil())
                            expect(target.songResults!).to(haveCount(8))
                            expect(target.songResults![0].title).to(equal("3. Third song"))
                            expect(target.songResults![1].title).to(equal("5. 5th song"))
                            expect(target.songResults![2].title).to(equal("11. 11"))
                            expect(target.songResults![3].title).to(equal("11b. non numeric number"))
                            expect(target.songResults![4].title).to(equal("12. Twelve"))
                            expect(target.songResults![5].title).to(equal("Chinese 300 (Trad.)"))
                            expect(target.songResults![6].title).to(equal("-9. negative hymn number"))
                            expect(target.songResults![7].title).to(equal("abcd333. No leading numbers"))
                        }
                    }
                    context("fetch songbase") {
                        beforeEach {
                            given(dataStore.getAllSongs(hymnType: .blueSongbook)) ~> { _ in
                                Just([SongResultEntity(hymnType: .blueSongbook, hymnNumber: "1", title: "First Songbase song"),
                                      SongResultEntity(hymnType: .blueSongbook, hymnNumber: "2", title: "Second Songbase song")])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target = BrowseResultsListViewModel(hymnType: .blueSongbook)
                            target.fetchResults()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should set the title to the hymn type") {
                            expect(target.title).to(equal(HymnType.blueSongbook.displayTitle))
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
