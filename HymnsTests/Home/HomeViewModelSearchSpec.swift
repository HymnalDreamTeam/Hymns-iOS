import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

// swiftlint:disable type_body_length function_body_length
/**
 * Tests cases where the `HomeViewModel` performs a search request.
 */
class HomeViewModelSearchSpec: QuickSpec {

    override func spec() {
        let searchParameter = "Wakanda Forever"
        describe("with search parameter \(searchParameter)") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var historyStore: HistoryStoreMock!
            var songResultsRepository: SongResultsRepositoryMock!
            var target: HomeViewModel!

            let recentSongs = [RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                               RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]
            beforeEach {
                historyStore = mock(HistoryStore.self)
                given(historyStore.recentSongs()) ~> {
                    Just(recentSongs).mapError({ _ -> ErrorType in
                        .data(description: "forced data error")
                    }).eraseToAnyPublisher()
                }
                songResultsRepository = mock(SongResultsRepository.self)
                target = HomeViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                                       mainQueue: testQueue, repository: songResultsRepository)

                target.searchActive = true
                testQueue.sync {}

                // clear the invocations made during the setup step
                clearInvocations(on: historyStore)
                clearInvocations(on: songResultsRepository)
            }
            context("with empty results") {
                let results = [UiSongResult]()
                context("search complete") {
                    beforeEach {
                        given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { _, _ in
                            expect(target.state).to(equal(HomeResultState.loading))
                            return Just(UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)).mapError({ _ -> ErrorType in
                                .data(description: "This will never get called")
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
                let classic594 = UiSongResult(name: "classic594", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "594", queryParams: ["gb": "1", "query": "3"]))
                let newTune7 = UiSongResult(name: "newTune7", identifier: HymnIdentifier(hymnType: .newTune, hymnNumber: "7"))
                beforeEach {
                    given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { searchInput, pageNumber in
                        expect(target.state).to(equal(HomeResultState.loading))
                        let page = UiSongResultsPage(results: [classic594, newTune7], hasMorePages: false)
                        return Just(page).mapError({ _ -> ErrorType in
                            .data(description: "This will never get called")
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
                    expect(target.songResults[0].title).to(equal("classic594"))
                    expect(target.songResults[1].title).to(equal("newTune7"))
                }
                it("should not fetch the recent songs from the history store") {
                    verify(historyStore.recentSongs()).wasNeverCalled()
                }
                it("should fetch the first page") {
                    verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)).wasCalled(exactly(1))
                }
                let recentHymns = "Recent hymns"
                context("search parameter cleared") {
                    beforeEach {
                        given(historyStore.recentSongs()) ~> {
                            Just(recentSongs).mapError({ _ -> ErrorType in
                                .data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        }
                        target.searchParameter = ""
                        sleep(1) // allow time for the debouncer to trigger.
                        testQueue.sync {}
                    }
                    it("\"\(recentHymns)\" label should be showing") {
                        print("sync 1")
                        testQueue.sync {}
                        print("sync 1 done")
                        print("Asserting '\(recentHymns) label should be showing' on \(Thread.current)")

                        expect(target.label).toNot(beNil())
                        expect(target.label).to(equal(recentHymns))

                        print("sync 2")
                        testQueue.sync {}
                        print("sync 2 done")
                    }
                    it("should not still be loading") {
                        print("sync 1")
                        testQueue.sync {}
                        print("sync 1 done")
                        print("Asserting 'should not still be loading' on \(Thread.current)")

                        expect(target.state).to(equal(HomeResultState.results))

                        print("sync 2")
                        testQueue.sync {}
                        print("sync 2 done")
                    }
                    it("should fetch the recent songs from the history store") {
                        print("sync 1")
                        testQueue.sync {}
                        print("sync 1 done")
                        print("Asserting 'should fetch the recent songs from the history store' on \(Thread.current)")

                        verify(historyStore.recentSongs()).wasCalled(exactly(1))

                        print("sync 2")
                        testQueue.sync {}
                        print("sync 2 done")
                    }
                    it("should display recent songs") {
                        print("sync 1")
                        testQueue.sync {}
                        print("sync 1 done")
                        print("Asserting 'should display recent songs' on \(Thread.current)")

                        expect(target.songResults).to(haveCount(2))
                        expect(target.songResults[0].title).to(equal(recentSongs[0].songTitle))
                        expect(target.songResults[1].title).to(equal(recentSongs[1].songTitle))

                        print("sync 2")
                        testQueue.sync {}
                        print("sync 2 done")
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
                        expect(target.songResults[0].title).to(equal(recentSongs[0].songTitle))
                        expect(target.songResults[1].title).to(equal(recentSongs[1].songTitle))
                    }
                }
            }
            context("with two pages of results") {
                let page1 = Array(1...10).map { int -> UiSongResult in
                    return UiSongResult(name: "classic\(int)", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "\(int)"))
                }
                let page2 = Array(20...23).map { int -> UiSongResult in
                    return UiSongResult(name: "classic\(int)", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "\(int)"))
                    }
                    // add a few results from page1 to ensure that they are deduped.
                    + [UiSongResult(name: "classic1", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1")),
                       UiSongResult(name: "classic2", identifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1"))]
                context("first page complete successfully") {
                    beforeEach {
                        given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { searchInput, pageNumber in
                            expect(target.state).to(equal(HomeResultState.loading))
                            let page = UiSongResultsPage(results: page1, hasMorePages: true)
                            return Just(page).mapError({ _ -> ErrorType in
                                .data(description: "This will never get called")
                            }).eraseToAnyPublisher()
                        }
                        given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)) ~> { searchInput, pageNumber in
                            expect(target.state).to(equal(HomeResultState.results))
                            let page = UiSongResultsPage(results: page2, hasMorePages: false)
                            return Just(page).mapError({ _ -> ErrorType in
                                .data(description: "This will never get called")
                            }).eraseToAnyPublisher()
                        }
                        target.searchParameter = searchParameter
                        sleep(1) // allow time for the debouncer to trigger.
                    }
                    it("should have the first page of results") {
                        expect(target.songResults).to(haveCount(10))
                        for (index, num) in Array(1...10).enumerated() {
                            expect(target.songResults[index].title).to(equal("classic\(num)"))
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
                            target.loadMore(at: SongResultViewModel(title: "does not exist", destinationView: EmptyView().eraseToAnyView()))
                        }
                        it("should not fetch the next page") {
                            verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                        }
                    }
                    describe("load more does not reach threshold") {
                        beforeEach {
                            target.loadMore(at: SongResultViewModel(title: "classic6", destinationView: EmptyView().eraseToAnyView()))
                        }
                        it("should not fetch the next page") {
                            verify(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 2)).wasNeverCalled()
                        }
                    }
                    describe("load more meets threshold") {
                        beforeEach {
                            target.loadMore(at: SongResultViewModel(title: "classic7", destinationView: EmptyView().eraseToAnyView()))
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should append the second page onto the first page") {
                            expect(target.songResults).to(haveCount(14))
                            for (index, num) in (Array(1...10) + Array(20...23)).enumerated() {
                                expect(target.songResults[index].title).to(equal("classic\(num)"))
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
                                target.loadMore(at: SongResultViewModel(title: "classic23", destinationView: EmptyView().eraseToAnyView()))
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
                        given(songResultsRepository.search(searchParameter: searchParameter, pageNumber: 1)) ~> { searchInput, pageNumber in
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
                            expect(target.songResults[index].title).to(equal("classic\(num)"))
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
                            target.loadMore(at: SongResultViewModel(title: "classic7", destinationView: EmptyView().eraseToAnyView()))
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
                                expect(target.songResults[index].title).to(equal("classic\(num)"))
                            }
                        }
                        describe("loading more") {
                            beforeEach {
                                target.loadMore(at: SongResultViewModel(title: "classic7", destinationView: EmptyView().eraseToAnyView()))
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
    }
}
