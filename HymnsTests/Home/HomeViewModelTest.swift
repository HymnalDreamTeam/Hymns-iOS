import Combine
import Mockingbird
import Nimble
import XCTest
@testable import Hymns

class HomeViewModelTest: XCTestCase {

    let recentHymns = "Recent hymns"
    let recentSongs = [RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                       RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]

    // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
    let testQueue = DispatchQueue(label: "test_queue")
    var historyStore: HistoryStoreMock!
    var songResultsRepository: SongResultsRepositoryMock!
    var target: HomeViewModel!

    override func setUp() {
        super.setUp()
        historyStore = mock(HistoryStore.self)
        given(historyStore.recentSongs(onChanged: any())) ~> { onChanged in
            expect(self.target.state).to(equal(HomeResultState.loading))
            onChanged(self.recentSongs)
            return mock(Notification.self)
        }
        songResultsRepository = mock(SongResultsRepository.self)
        target = HomeViewModel(backgroundQueue: testQueue, historyStore: historyStore,
                               mainQueue: testQueue, repository: songResultsRepository)
    }

    func test_defaultState() {
        testQueue.sync {}

        expect(self.target.label).toNot(beNil())
        expect(self.target.label).to(equal(recentHymns))
        expect(self.target.state).to(equal(HomeResultState.results))
        verify(historyStore.recentSongs(onChanged: any())).wasCalled(exactly(1))
        expect(self.target.songResults).to(haveCount(2))
        expect(self.target.songResults[0].title).to(equal(recentSongs[0].songTitle))
        expect(self.target.songResults[1].title).to(equal(recentSongs[1].songTitle))
    }

    func test_searchActive_emptySearchParameter() {
        target.searchActive = true
        testQueue.sync {}

        expect(self.target.label).toNot(beNil())
        expect(self.target.label).to(equal(recentHymns))
        expect(self.target.state).to(equal(HomeResultState.results))
        verify(historyStore.recentSongs(onChanged: any())).wasCalled(exactly(1))
        expect(self.target.songResults).toEventually(haveCount(2))
        expect(self.target.songResults[0].title).to(equal(recentSongs[0].songTitle))
        expect(self.target.songResults[1].title).to(equal(recentSongs[1].songTitle))
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }

    func test_searchActive_numericSearchParameter() {
        target.searchActive = true
        testQueue.sync {}
        clearInvocations(on: historyStore) // clear invocations called from activating search
        target.searchParameter = "198 "
        sleep(1) // allow time for the debouncer to trigger.

        expect(self.target.label).to(beNil())
        expect(self.target.state).to(equal(HomeResultState.results))
        expect(self.target.songResults).to(haveCount(2))
        expect(self.target.songResults[0].title).to(equal("Hymn 198"))
        expect(self.target.songResults[1].title).to(equal("Hymn 1198"))
        verify(historyStore.recentSongs(onChanged: any())).wasNeverCalled()
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }

    func test_searchActive_invalidNumericSearchParameter() {
        target.searchActive = true
        testQueue.sync {}
        clearInvocations(on: historyStore) // clear invocations called from activating search
        target.searchParameter = "2000 " // number is larger than any valid song
        sleep(1) // allow time for the debouncer to trigger.

        expect(self.target.label).to(beNil())
        expect(self.target.state).to(equal(HomeResultState.empty))
        expect(self.target.songResults).to(beEmpty())
        verify(historyStore.recentSongs(onChanged: any())).wasNeverCalled()
        verify(songResultsRepository.search(searchParameter: any(), pageNumber: any())).wasNeverCalled()
    }
}
