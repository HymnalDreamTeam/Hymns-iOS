import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_body_length function_body_length
class SearchViewModelSpec: QuickSpec {

    override func spec() {
        describe("SearchViewModelSpec") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var historyStore: HistoryStoreMock!
            var hymnsRepository: HymnsRepositoryMock!
            var songResultsRepository: SongResultsRepositoryMock!
            var target: SearchViewModel!

            let recentSongs = [RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                               RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]
            beforeEach {
                historyStore = mock(HistoryStore.self)
                given(historyStore.recentSongs()) ~> {
                    Just(recentSongs).mapError({ _ -> ErrorType in
                        // This will never be triggered.
                    }).eraseToAnyPublisher()
                }
                hymnsRepository = mock(HymnsRepository.self)
                songResultsRepository = mock(SongResultsRepository.self)
            }
            let recentHymns = "Recent hymns"
            context("initial state") {
                beforeEach {
                    let initiallyInactiveQueue = DispatchQueue(label: "test_queue", attributes: .initiallyInactive)
                    target = SearchViewModel(backgroundQueue: initiallyInactiveQueue, historyStore: historyStore,
                                             hymnsRepository: hymnsRepository, mainQueue: initiallyInactiveQueue,
                                             repository: songResultsRepository)
                }
                it("searchActive should be false") {
                    expect(target.searchActive).to(beFalse())
                }
                it("searchParameter should be empty") {
                    expect(target.searchParameter).to(beEmpty())
                }
                context("search-by-type already seen") {
                    beforeEach {
                        target.hasSeenSearchByTypeTooltip = true
                        target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                                 hymnsRepository: hymnsRepository, mainQueue: testQueue,
                                                 repository: songResultsRepository)
                    }
                    it("showSearchByTypeToolTip should be false") {
                        expect(target.showSearchByTypeToolTip).to(beFalse())
                    }
                }
                context("search-by-type not seen") {
                    beforeEach {
                        target.hasSeenSearchByTypeTooltip = false
                        target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                                 hymnsRepository: hymnsRepository, mainQueue: testQueue,
                                                 repository: songResultsRepository)
                    }
                    it("showSearchByTypeToolTip should be true") {
                        expect(target.showSearchByTypeToolTip).to(beTrue())
                    }
                    describe("toggle hasSeenSearchByTypeTooltip") {
                        beforeEach {
                            target.hasSeenSearchByTypeTooltip = true
                        }
                        it("showSearchByTypeToolTip should be false") {
                            expect(target.showSearchByTypeToolTip).to(beFalse())
                        }                    }
                }
                it("songResults should be empty") {
                    expect(target.songResults).to(beEmpty())
                }
                it("label should be nil") {
                    expect(target.label).to(beNil())
                }
                it("state should be loading") {
                    expect(target.state).to(equal(.loading))
                }
            }
            context("data store error") {
                beforeEach {
                    given(historyStore.recentSongs()) ~> {
                        Just([RecentSong]())
                            .tryMap({ _ -> [RecentSong] in
                                throw URLError(.badServerResponse)
                            }).mapError({ _ -> ErrorType in
                                    .data(description: "forced data error")
                            }).eraseToAnyPublisher()
                    }
                    target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                             mainQueue: testQueue, repository: songResultsRepository)
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("\"\(recentHymns)\" label should not be showing") {
                    expect(target.label).to(beNil())
                }
                it("should display empty results") {
                    expect(target.state).to(equal(HomeResultState.results))
                    expect(target.songResults).to(beEmpty())
                }
                it("should fetch the recent songs from the history store") {
                    verify(historyStore.recentSongs()).wasCalled(exactly(1))
                }
            }
            context("data store empty") {
                beforeEach {
                    given(historyStore.recentSongs()) ~> {
                        Just([RecentSong]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                    target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                             hymnsRepository: hymnsRepository, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("\"\(recentHymns)\" label should not be showing") {
                    expect(target.label).to(beNil())
                }
                it("should display empty results") {
                    expect(target.state).to(equal(HomeResultState.results))
                    expect(target.songResults).to(beEmpty())
                }
                it("should fetch the recent songs from the history store") {
                    verify(historyStore.recentSongs()).wasCalled(exactly(1))
                }
            }
            context("recent songs") {
                beforeEach {
                    target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                             hymnsRepository: hymnsRepository, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("\"\(recentHymns)\" label should be showing") {
                    expect(target.label).toNot(beNil())
                }
                it("\"\(recentHymns)\" label should be \(recentHymns)") {
                    expect(target.label).to(equal(recentHymns))
                }
                it("should display results") {
                    expect(target.state).to(equal(HomeResultState.results))
                }
                it("should fetch the recent songs from the history store") {
                    verify(historyStore.recentSongs()).wasCalled(exactly(1))
                }
                it("should display recent songs") {
                    expect(target.songResults).to(haveCount(2))
                    expect(target.songResults[0].title).to(equal(recentSongs[0].songTitle))
                    expect(target.songResults[0].label).to(equal("Hymn 1151"))
                    expect(target.songResults[1].title).to(equal(recentSongs[1].songTitle))
                    expect(target.songResults[1].label).to(equal("Cebuano 123"))
                }
            }
            context("search active") {
                beforeEach {
                    target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                             hymnsRepository: hymnsRepository, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    target.searchActive = true
                    testQueue.sync {}
                    testQueue.sync {}
                }
                context("with empty search parameter") {
                    it("\"\(recentHymns)\" label should be showing") {
                        expect(target.label).toNot(beNil())
                        expect(target.label).to(equal(recentHymns))
                    }
                    it("should be showing results") {
                        expect(target.state).to(equal(HomeResultState.results))
                    }
                    it("should fetch the recent songs from the history store") {
                        verify(historyStore.recentSongs()).wasCalled(exactly(1))
                    }
                    it("should display recent songs") {
                        expect(target.songResults).toEventually(haveCount(2))
                        expect(target.songResults[0].title).to(equal(recentSongs[0].songTitle))
                        expect(target.songResults[0].label).to(equal("Hymn 1151"))
                        expect(target.songResults[1].title).to(equal(recentSongs[1].songTitle))
                        expect(target.songResults[0].label).to(equal("Hymn 1151"))
                    }
                    it("should not call songResultsRepository.search") {
                        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                    }
                }
                describe("clear mock invocations called from setup") {
                    beforeEach {
                        clearInvocations(on: historyStore)
                    }
                    context("with numeric search parameter") {
                        beforeEach {
                            target.searchParameter = "198 "
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should be showing results") {
                            expect(target.state).to(equal(HomeResultState.results))
                        }
                        it("song results should contain matching numbers") {
                            expect(target.songResults).to(haveCount(2))
                            expect(target.songResults[0].title).to(equal("Hymn 198"))
                            expect(target.songResults[0].label).to(beNil())
                            expect(target.songResults[1].title).to(equal("Hymn 1198"))
                            expect(target.songResults[1].label).to(beNil())
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should not call songResultsRepository.search") {
                            verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                        }
                    }
                    context("with invalid numeric search parameter") {
                        beforeEach {
                            target.searchParameter = "2000 " // number is larger than any valid song
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should be showing no results state") {
                            expect(target.state).to(equal(HomeResultState.empty))
                        }
                        it("song results should contain matching numbers") {
                            expect(target.songResults).to(beEmpty())
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should not call songResultsRepository.search") {
                            verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                        }
                    }
                    context("with continuous hymn type search") { // search by hymn type on a type that is continuous
                        beforeEach {
                            target.searchParameter = "ChINEsE 111 "
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should be showing results") {
                            expect(target.state).to(equal(HomeResultState.results))
                        }
                        it("song results should contain matching numbers") {
                            expect(target.songResults).to(haveCount(3))
                            expect(target.songResults[0].title).to(equal("Chinese 111"))
                            expect(target.songResults[0].label).to(beNil())
                            expect(target.songResults[1].title).to(equal("Chinese 1110"))
                            expect(target.songResults[1].label).to(beNil())
                            expect(target.songResults[2].title).to(equal("Chinese 1111"))
                            expect(target.songResults[2].label).to(beNil())
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should not call songResultsRepository.search") {
                            verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                        }
                    }
                    context("with noncontinuous hymn type search") { // search by hymn type on a type that is not continuous
                        let newTune111 = HymnIdentifier(hymnType: .newTune, hymnNumber: "111")
                        context("with nil result") {
                            context("search complete") {
                                beforeEach {
                                    given(hymnsRepository.getHymn(newTune111, makeNetworkRequest: false)) ~> { _, _ in
                                        Just(nil).assertNoFailure().eraseToAnyPublisher()
                                    }
                                    target.searchParameter = "  Nt 111 "
                                    sleep(1) // allow time for the debouncer to trigger.
                                }
                                it("no label should be showing") {
                                    expect(target.label).to(beNil())
                                }
                                it("should not still be loading") {
                                    expect(target.state).to(equal(.empty))
                                }
                                it("song results should be empty") {
                                    expect(target.songResults).to(beEmpty())
                                }
                                it("should try to fetch the song from hymnsRepository") {
                                    verify(hymnsRepository.getHymn(newTune111, makeNetworkRequest: false)).wasCalled(exactly(1))
                                }
                            }
                        }
                        context("with result") {
                            context("search complete") {
                                beforeEach {
                                    let hymn = UiHymn(hymnIdentifier: newTune111, title: "title", lyrics: [Verse]())
                                    given(hymnsRepository.getHymn(newTune111, makeNetworkRequest: false)) ~> { _, _ in
                                        Just(hymn).assertNoFailure().eraseToAnyPublisher()
                                    }
                                    target.searchParameter = "  new tune111 "
                                    sleep(1) // allow time for the debouncer to trigger.
                                }
                                it("no label should be showing") {
                                    expect(target.label).to(beNil())
                                }
                                it("should not still be loading") {
                                    expect(target.state).to(equal(.results))
                                }
                                it("song results should contain fetched hymn") {
                                    expect(target.songResults).to(haveCount(1))
                                    expect(target.songResults[0].title).to(equal("title"))
                                    expect(target.songResults[0].label).to(equal("New tune 111"))
                                }
                                it("should try to fetch the song from hymnsRepository") {
                                    verify(hymnsRepository.getHymn(newTune111, makeNetworkRequest: false)).wasCalled(exactly(1))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
