import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

// swiftlint:disable type_body_length function_body_length
/**
 * Tests cases where the `SearchViewModel` performs a search request.
 */
class SearchViewModelSearchingSpec: QuickSpec {

    override func spec() {
        describe("searching") {
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
                target = SearchViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                         mainQueue: testQueue, repository: songResultsRepository)
                target.setUp()

                target.searchActive = true
                testQueue.sync {}

                // clear the invocations made during the setup step
                clearInvocations(on: historyStore)
                clearInvocations(on: hymnsRepository)
                clearInvocations(on: songResultsRepository)
            }
            describe("with alphanumeric search parameter") {
                let searchParameter = "Wakanda Forever"
                context("with empty results") {
                    let results = [UiSongResult]()
                    context("search complete") {
                        beforeEach {
                            given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                                expect(target.state).to(equal(HomeResultState.loading))
                                return Just(UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target.searchParameter = "\(searchParameter) \n  "
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should not still be loading") {
                            expect(target.state).to(equal(HomeResultState.empty))
                        }
                        it("song results should be empty") {
                            expect(target.songResults).to(beEmpty())
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should fetch the first page") {
                            verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                        }
                    }
                    context("search incomplete") {
                        var response: CurrentValueSubject<UiSongResultsPage, ErrorType>!
                        beforeEach {
                            given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                                expect(target.state).to(equal(HomeResultState.loading))
                                return response.eraseToAnyPublisher()
                            }
                            target.searchParameter = "\(searchParameter) \n  "
                            response = CurrentValueSubject<UiSongResultsPage, ErrorType>(UiSongResultsPage(results: results, hasMorePages: false))
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should still be loading") {
                            expect(target.state).to(equal(HomeResultState.loading))
                        }
                        it("song results should be empty") {
                            expect(target.songResults).to(beEmpty())
                        }
                        context("search finishes") {
                            beforeEach {
                                response.send(completion: .finished)
                                testQueue.sync {}
                            }
                            it("no label should be showing") {
                                expect(target.label).to(beNil())
                            }
                            it("should not still be loading") {
                                expect(target.state).to(equal(HomeResultState.empty))
                            }
                            it("song results should be empty") {
                                expect(target.songResults).to(beEmpty())
                            }
                            it("should not fetch the recent songs from the history store") {
                                verify(historyStore.recentSongs()).wasNeverCalled()
                            }
                            it("should fetch the first page") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                            }
                        }
                        context("search fails") {
                            beforeEach {
                                response.send(completion: .failure(.parsing(description: "some parsing error")))
                                testQueue.sync {}
                            }
                            it("no label should be showing") {
                                expect(target.label).to(beNil())
                            }
                            it("should not still be loading") {
                                expect(target.state).to(equal(HomeResultState.empty))
                            }
                            it("song results should be empty") {
                                expect(target.songResults).to(beEmpty())
                            }
                            it("should not fetch the recent songs from the history store") {
                                verify(historyStore.recentSongs()).wasNeverCalled()
                            }
                            it("should fetch the first page") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                            }
                        }
                    }
                }
                context("with a single page of results") {
                    let classic594 = UiSongResult(name: "classic594",
                                                  identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "594")])
                    let newTune7 = UiSongResult(name: "newTune7",
                                                identifiers: [HymnIdentifier(hymnType: .newTune, hymnNumber: "7"),
                                                              HymnIdentifier(hymnType: .newSong, hymnNumber: "3")])
                    beforeEach {
                        given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                            expect(target.state).to(equal(HomeResultState.loading))
                            let page = UiSongResultsPage(results: [classic594, newTune7], hasMorePages: false)
                            return Just(page).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target.searchParameter = searchParameter
                        sleep(1) // allow time for the debouncer to trigger.
                    }
                    it("no label should be showing") {
                        expect(target.label).to(beNil())
                    }
                    it("should not still be loading") {
                        expect(target.state).to(equal(HomeResultState.results))
                    }
                    it("should have two results") {
                        expect(target.songResults).to(haveCount(2))
                    }
                    it("should group results by song id") {
                        expect(target.songResults[0].multiSongResultViewModel!.title).to(equal("classic594"))
                        expect(target.songResults[0].multiSongResultViewModel!.labels).to(equal(["Hymn 594"]))
                        expect(target.songResults[1].multiSongResultViewModel!.title).to(equal("newTune7"))
                        expect(target.songResults[1].multiSongResultViewModel!.labels).to(equal(["New tune 7", "New song 3"]))
                    }
                    it("should not fetch the recent songs from the history store") {
                        verify(historyStore.recentSongs()).wasNeverCalled()
                    }
                    it("should fetch the first page") {
                        verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                    }
                    describe("re-enter same search parameter") {
                        beforeEach {
                            clearInvocations(on: historyStore, songResultsRepository)
                            target.searchParameter = searchParameter
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("nothing should change") {
                            expect(target.label).to(beNil())
                            expect(target.state).to(equal(HomeResultState.results))
                            expect(target.songResults).to(haveCount(2))
                            expect(target.songResults[0].multiSongResultViewModel!.title).to(equal("classic594"))
                            expect(target.songResults[0].multiSongResultViewModel!.labels).to(equal(["Hymn 594"]))
                            expect(target.songResults[1].multiSongResultViewModel!.title).to(equal("newTune7"))
                            expect(target.songResults[1].multiSongResultViewModel!.labels).to(equal(["New tune 7", "New song 3"]))
                            verify(historyStore.recentSongs()).wasNeverCalled()
                            verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
                        }
                    }
                    let recentHymns = "Recent hymns"
                    context("search parameter cleared") {
                        beforeEach {
                            given(historyStore.recentSongs()) ~> {
                                Just(recentSongs).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target.searchParameter = ""
                            sleep(1) // allow time for the debouncer to trigger.
                            testQueue.sync {}
                        }
                        it("\"\(recentHymns)\" label should be showing") {
                            testQueue.sync {}

                            expect(target.label).toNot(beNil())
                            expect(target.label).to(equal(recentHymns))
                        }
                        it("should not still be loading") {
                            testQueue.sync {}

                            expect(target.state).to(equal(HomeResultState.results))

                            testQueue.sync {}
                        }
                        it("should fetch the recent songs from the history store") {
                            testQueue.sync {}

                            verify(historyStore.recentSongs()).wasCalled(exactly(1))

                            testQueue.sync {}
                        }
                        it("should display recent songs") {
                            testQueue.sync {}

                            expect(target.songResults).to(haveCount(2))
                            expect(target.songResults[0].singleSongResultViewModel!.title).to(equal(recentSongs[0].songTitle))
                            expect(target.songResults[0].singleSongResultViewModel!.label).to(equal("Hymn 1151"))
                            expect(target.songResults[1].singleSongResultViewModel!.title).to(equal(recentSongs[1].songTitle))
                            expect(target.songResults[1].singleSongResultViewModel!.label).to(equal("Cebuano 123"))

                            testQueue.sync {}
                        }
                    }
                    context("deactivate search") {
                        beforeEach {
                            target.searchActive = false
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("\"\(recentHymns)\" label should be showing") {
                            expect(target.label).toNot(beNil())
                            expect(target.label).to(equal(recentHymns))
                        }
                        it("should not still be loading") {
                            expect(target.state).to(equal(HomeResultState.results))
                        }
                        it("should fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasCalled(exactly(1))
                        }
                        it("should display recent songs") {
                            expect(target.songResults).to(haveCount(2))
                            expect(target.songResults[0].singleSongResultViewModel!.title).to(equal(recentSongs[0].songTitle))
                            expect(target.songResults[0].singleSongResultViewModel!.label).to(equal("Hymn 1151"))
                            expect(target.songResults[1].singleSongResultViewModel!.title).to(equal(recentSongs[1].songTitle))
                            expect(target.songResults[1].singleSongResultViewModel!.label).to(equal("Cebuano 123"))
                        }
                    }
                }
                context("with two pages of results") {
                    let page1 = Array(1...10).map { int -> UiSongResult in
                        return UiSongResult(name: "classic\(int)", identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "\(int)")])
                    }
                    let page2 = Array(20...23).map { int -> UiSongResult in
                        return UiSongResult(name: "classic\(int)", identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "\(int)")])
                    }
                    // add a few results from page1 to ensure that they are deduped.
                    + [UiSongResult(name: "classic1", identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "1")]),
                       UiSongResult(name: "classic2", identifiers: [HymnIdentifier(hymnType: .classic, hymnNumber: "2")])]
                    context("first page complete successfully") {
                        beforeEach {
                            given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                                expect(target.state).to(equal(HomeResultState.loading))
                                let page = UiSongResultsPage(results: page1, hasMorePages: true)
                                return Just(page).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)) ~> { _, _ in
                                expect(target.state).to(equal(HomeResultState.results))
                                let page = UiSongResultsPage(results: page2, hasMorePages: false)
                                return Just(page).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                            target.searchParameter = searchParameter
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("should have the first page of results") {
                            expect(target.songResults).to(haveCount(10))
                            for (index, num) in Array(1...10).enumerated() {
                                expect(target.songResults[index].multiSongResultViewModel!.title).to(equal("classic\(num)"))
                            }
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should fetch the first page") {
                            verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                        }
                        describe("load on nonexistent result") {
                            beforeEach {
                                target.loadMore(at:
                                        .multi(MultiSongResultViewModel(stableId: "empty does not exist view", title: "does not exist",
                                                                        destinationView: EmptyView().eraseToAnyView())))
                            }
                            it("should not fetch the next page") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                            }
                        }
                        describe("load more does not reach threshold") {
                            beforeEach {
                                target.loadMore(at:
                                        .single(SingleSongResultViewModel(stableId: "hymnType: h, hymnNumber: 6", title: "classic6", label: "Hymn 6",
                                                                          destinationView: EmptyView().eraseToAnyView())))
                            }
                            it("should not fetch the next page") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                            }
                        }
                        describe("load more meets threshold") {
                            beforeEach {
                                target.loadMore(at:
                                        .multi(MultiSongResultViewModel(stableId: "[hymnType: h, hymnNumber: 7]", title: "classic7", labels: ["Hymn 7"],
                                                                        destinationView: EmptyView().eraseToAnyView())))
                                testQueue.sync {}
                                testQueue.sync {}
                                testQueue.sync {}
                            }
                            it("should append the second page onto the first page") {
                                let sr = target.songResults
                                expect(target.songResults).to(haveCount(14))
                                for (index, num) in (Array(1...10) + Array(20...23)).enumerated() {
                                    expect(target.songResults[index].multiSongResultViewModel!.title).to(equal("classic\(num)"))
                                }
                            }
                            it("should not fetch the recent songs from the history store") {
                                verify(historyStore.recentSongs()).wasNeverCalled()
                            }
                            it("should fetch the next page") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasCalled(exactly(1))
                            }
                            describe("no more pages to load") {
                                beforeEach {
                                    target.loadMore(at:
                                            .single(SingleSongResultViewModel(stableId: "hymnType: h, hymnNumber: 23", title: "classic23", label: "Hymn 23",
                                                                              destinationView: EmptyView().eraseToAnyView())))
                                }
                                it("should not fetch the next page") {
                                    verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 3)).wasNeverCalled()
                                }
                            }
                        }
                    }
                    context("first page incomplete") {
                        var response: CurrentValueSubject<UiSongResultsPage, ErrorType>!
                        beforeEach {
                            given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                                expect(target.state).to(equal(HomeResultState.loading))
                                return response.eraseToAnyPublisher()
                            }
                            response = CurrentValueSubject<UiSongResultsPage, ErrorType>(UiSongResultsPage(results: page1, hasMorePages: true))
                            target.searchParameter = searchParameter
                            sleep(1) // allow time for the debouncer to trigger.
                        }
                        it("no label should be showing") {
                            expect(target.label).to(beNil())
                        }
                        it("should not still be loading") {
                            expect(target.state).to(equal(HomeResultState.results))
                        }
                        it("should have the first page of results") {
                            expect(target.songResults).to(haveCount(10))
                            for (index, num) in Array(1...10).enumerated() {
                                expect(target.songResults[index].multiSongResultViewModel!.title).to(equal("classic\(num)"))
                            }
                        }
                        it("should not fetch the recent songs from the history store") {
                            verify(historyStore.recentSongs()).wasNeverCalled()
                        }
                        it("should fetch the first page") {
                            verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                        }
                        describe("try to load more") {
                            beforeEach {
                                target.loadMore(at:
                                        .single(SingleSongResultViewModel(stableId: "hymnType: h, hymnNumber: 7", title: "classic7", label: "Hymn 7",
                                                                          destinationView: EmptyView().eraseToAnyView())))
                                testQueue.sync {}
                            }
                            it("not fetch the next page since previous call is still loading") {
                                verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                            }
                        }
                        context("search fails") {
                            beforeEach {
                                response.send(completion: .failure(.data(description: "some network error")))
                                testQueue.sync {}
                            }
                            it("should show existing results") {
                                expect(target.state).to(equal(HomeResultState.results))
                                expect(target.songResults).to(haveCount(10))
                                for (index, num) in Array(1...10).enumerated() {
                                    expect(target.songResults[index].multiSongResultViewModel!.title).to(equal("classic\(num)"))
                                }
                            }
                            describe("loading more") {
                                beforeEach {
                                    target.loadMore(at:
                                            .single(SingleSongResultViewModel(stableId: "hymnType: h, hymnNumber: 7", title: "classic7", label: "Hymn 7",
                                                                              destinationView: EmptyView().eraseToAnyView())))
                                    testQueue.sync {}
                                    testQueue.sync {}
                                    testQueue.sync {}
                                }
                                it("not fetch the next page since previous call failed") {
                                    verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                                }
                            }
                        }
                    }
                }
            }
            describe("with long numeric search parameter") {
                let searchParameter = "171214436716555"
                context("with empty results") {
                    beforeEach {
                        given(songResultsRepository.search(hymnCode: "171214436716555")) ~> { _ in
                            return Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target.searchParameter = "\(searchParameter) \n  "
                        sleep(1) // allow time for the debouncer to trigger.
                    }
                    it("no label should be showing") {
                        expect(target.label).to(beNil())
                    }
                    it("should not still be loading") {
                        expect(target.state).to(equal(HomeResultState.empty))
                    }
                    it("song results should be empty") {
                        expect(target.songResults).to(beEmpty())
                    }
                    it("should not fetch the recent songs from the history store") {
                        verify(historyStore.recentSongs()).wasNeverCalled()
                    }
                    it("should fetch the hymn code") {
                        verify(songResultsRepository.search(hymnCode: "171214436716555")).wasCalled(exactly(1))
                    }
                }
                context("with results") {
                    beforeEach {
                        given(songResultsRepository.search(hymnCode: "171214436716555")) ~> { _ in
                            Just([SongResultEntity(hymnType: .german, hymnNumber: "93", title: "title", songId: 1),
                                  SongResultEntity(hymnType: .chineseSupplement, hymnNumber: "933", title: "title 2", songId: 2),
                                  SongResultEntity(hymnType: .classic, hymnNumber: "8993", title: "title 2", songId: 2)])
                                .mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                        }
                        target.searchParameter = "\(searchParameter) \n  "
                        sleep(1) // allow time for the debouncer to trigger.
                    }
                    it("no label should be showing") {
                        expect(target.label).to(beNil())
                    }
                    it("should show results") {
                        expect(target.state).to(equal(HomeResultState.results))
                    }
                    it("should show two results") {
                        expect(target.songResults).to(haveCount(2))
                    }
                    it("song results should be grouped by song id") {
                        expect(target.songResults[0].multiSongResultViewModel!.title).to(equal("title"))
                        expect(target.songResults[0].multiSongResultViewModel!.labels).to(equal(["German 93"]))
                        expect(target.songResults[1].multiSongResultViewModel!.title).to(equal("title 2"))
                        expect(target.songResults[1].multiSongResultViewModel!.labels).to(equal(["Chinese Supplement 933 (Trad.)", "Hymn 8993"]))
                    }
                    it("should not fetch the recent songs from the history store") {
                        verify(historyStore.recentSongs()).wasNeverCalled()
                    }
                    it("should fetch the hymn code") {
                        verify(songResultsRepository.search(hymnCode: "171214436716555")).wasCalled(exactly(1))
                    }
                }
            }
        }
    }
}
