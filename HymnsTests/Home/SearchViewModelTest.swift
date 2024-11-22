import Combine
import SwiftUI
import Mockingbird
import Nimble
import XCTest
@testable import Hymns

class SearchViewModelTest: XCTestCase {

    let recentHymns = "Recent hymns"
    let recentSongs = [RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                       RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]

    // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
    let testQueue = DispatchQueue(label: "test_queue")
    var dataStore: HymnDataStoreMock!
    var historyStore: HistoryStoreMock!
    var songResultsRepository: SongResultsRepositoryMock!
    var target: SearchViewModel!

    override func setUp() {
        super.setUp()
        dataStore = mock(HymnDataStore.self)
        historyStore = mock(HistoryStore.self)
        given(historyStore.recentSongs()) ~> {
            Just(self.recentSongs).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        songResultsRepository = mock(SongResultsRepository.self)
        target = SearchViewModel(backgroundQueue: testQueue, dataStore: dataStore,
                                 historyStore: historyStore, mainQueue: testQueue,
                                 repository: songResultsRepository)
        target.setUp()
        testQueue.sync {}
        testQueue.sync {}
    }

    func test_defaultState() {
        expect(self.target.label).toNot(beNil())
        expect(self.target.label).to(equal(recentHymns))
        expect(self.target.state).to(equal(HomeResultState.results))
        verify(historyStore.recentSongs()).wasCalled(exactly(1))
        expect(self.target.songResults).to(haveCount(2))
        expect(self.target.songResults[0].singleSongResultViewModel!.title).to(equal(recentSongs[0].songTitle))
        expect(self.target.songResults[1].singleSongResultViewModel!.title).to(equal(recentSongs[1].songTitle))
    }

    func test_defaultState_withoutRecentSongs() {
        clearInvocations(on: historyStore)
        reset(historyStore)
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

        expect(self.target.label).to(beNil())
        expect(self.target.state).to(equal(HomeResultState.results))
        verify(historyStore.recentSongs()).wasCalled(exactly(1))
        expect(self.target.songResults).to(beEmpty())
    }

    func test_searchActive_emptySearchParameter() {
        target.searchActive = true

        expect(self.target.label).toNot(beNil())
        expect(self.target.label).to(equal(recentHymns))
        expect(self.target.state).to(equal(HomeResultState.results))
        verify(historyStore.recentSongs()).wasCalled(exactly(1))
        expect(self.target.songResults).toEventually(haveCount(2))
        expect(self.target.songResults[0].singleSongResultViewModel!.title).to(equal(recentSongs[0].songTitle))
        expect(self.target.songResults[1].singleSongResultViewModel!.title).to(equal(recentSongs[1].songTitle))
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }

    func test_searchActive_numericSearchParameter() {
        givenSwift(dataStore.getHymns(by: [.classic])) ~> self.createNumbers(.classic)

        target.searchActive = true
        clearInvocations(on: historyStore) // clear invocations called from activating search
        target.searchParameter = "198 "
        sleep(1) // allow time for the debouncer to trigger.

        expect(self.target.label).to(beNil())
        expect(self.target.state).to(equal(HomeResultState.results))
        expect(self.target.songResults).to(haveCount(2))
        expect(self.target.songResults[0].singleSongResultViewModel!.title).to(equal("Hymn 198"))
        expect(self.target.songResults[1].singleSongResultViewModel!.title).to(equal("Hymn 1198"))
        verify(historyStore.recentSongs()).wasNeverCalled()
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }

    func test_searchActive_invalidNumericSearchParameter() {
        givenSwift(dataStore.getHymns(by: [.classic])) ~> self.createNumbers(.classic)

        target.searchActive = true
        clearInvocations(on: historyStore) // clear invocations called from activating search
        target.searchParameter = "2000 " // number is larger than any valid song
        sleep(1) // allow time for the debouncer to trigger.

        expect(self.target.label).to(beNil())
        expect(self.target.state).to(equal(HomeResultState.empty))
        expect(self.target.songResults).to(beEmpty())
        verify(historyStore.recentSongs()).wasNeverCalled()
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }

    private func createNumbers(_ hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        return Just([1...1360].flatMap { range in
            range.map { number in
                SongResultEntity(hymnType: hymnType, hymnNumber: String(number))
            }
        }).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }
}
