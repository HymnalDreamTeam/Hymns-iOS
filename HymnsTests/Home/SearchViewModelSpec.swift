import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_body_length function_body_length
class SearchViewModelSpec: QuickSpec {

    override func spec() {
        describe("SearchViewModel") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var dataStore: HymnDataStoreMock!
            var historyStore: HistoryStoreMock!
            var songResultsRepository: SongResultsRepositoryMock!
            var target: SearchViewModel!

            let recentSongs = [RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                               RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]
            beforeEach {
                dataStore = mock(HymnDataStore.self)
                historyStore = mock(HistoryStore.self)
                given(historyStore.recentSongs()) ~> {
                    Just(recentSongs).mapError({ _ -> ErrorType in
                        // This will never be triggered.
                    }).eraseToAnyPublisher()
                }
                songResultsRepository = mock(SongResultsRepository.self)
            }
            let recentHymns = "Recent hymns"
            context("initial state") {
                beforeEach {
                    let initiallyInactiveQueue = DispatchQueue(label: "test_queue", attributes: .initiallyInactive)
                    target = SearchViewModel(backgroundQueue: initiallyInactiveQueue, dataStore: dataStore,
                                             historyStore: historyStore, mainQueue: initiallyInactiveQueue,
                                             repository: songResultsRepository)
                    target.setUp()
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
                        target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                                 historyStore: historyStore, mainQueue: testQueue,
                                                 repository: songResultsRepository)
                        target.setUp()
                    }
                    it("showSearchByTypeToolTip should be false") {
                        expect(target.showSearchByTypeToolTip).to(beFalse())
                    }
                }
                context("search-by-type not seen") {
                    beforeEach {
                        target.hasSeenSearchByTypeTooltip = false
                        target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                                 historyStore: historyStore, mainQueue: testQueue,
                                                 repository: songResultsRepository)
                        target.setUp()
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
                    target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                             historyStore: historyStore, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    target.setUp()
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
                    target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                             historyStore: historyStore, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    target.setUp()
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
                    target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                             historyStore: historyStore, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    target.setUp()
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
                    target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                             historyStore: historyStore, mainQueue: testQueue,
                                             repository: songResultsRepository)
                    target.setUp()
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
                        await expect {target.songResults}.toEventually(haveCount(2))
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
                        givenSwift(dataStore.getHymns(by: .classic)) ~> self.createNumbers(.classic)
                    }
                    describe("with numeric search parameter") {
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
                    describe("with invalid numeric search parameter") {
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
                    context("non-classic hymn type where numbers are found") {
                        beforeEach {
                            givenSwift(dataStore.getHymns(by: .chinese)) ~> self.createNumbers(.chinese)
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
                            expect(target.songResults[0].title).to(equal("Chinese 111 (Trad.)"))
                            expect(target.songResults[0].label).to(beNil())
                            expect(target.songResults[1].title).to(equal("Chinese 1110 (Trad.)"))
                            expect(target.songResults[1].label).to(beNil())
                            expect(target.songResults[2].title).to(equal("Chinese 1111 (Trad.)"))
                            expect(target.songResults[2].label).to(beNil())
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should not call songResultsRepository.search") {
                            verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                        }
                    }
                    context("numbers not found") {
                        beforeEach {
                            given(dataStore.getHymns(by: .newTune)) ~> { _  in
                                return Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target.searchParameter = "  Nt 111 "
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("state to be empty") {
                            expect(target.state).to(equal(.empty))
                        }
                        it("song results should be empty") {
                            expect(target.songResults).to(beEmpty())
                        }
                    }
                }
            }
        }
    }
    
    private func createNumbers(_ hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        switch hymnType {
        case .classic:
            return Just([1...1360].flatMap { range in
                range.map { number in
                    SongResultEntity(hymnType: hymnType, hymnNumber: String(number))
                }
            }).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        case .chinese:
            return Just(["1", "2", "3", "10", "11", "12",
                         "100", "110", "111", "112", "113",
                         "1000", "1001", "1010", "1100",
                         "1100", "1110", "1101", "1111"]
                .map {SongResultEntity(hymnType: .chinese, hymnNumber: $0)})
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        default:
            return Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
    }
}
