import Combine
import Mockingbird
import Nimble
import XCTest
@testable import Hymns

class SongRepositoryImplTest: XCTestCase {

    static let noMatchesSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "1", queryParams: nil,
                                                          title: "no matches in match info", matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))
    static let noMatches = SongResultEntity(hymnType: .classic, hymnNumber: "1", queryParams: nil, title: "no matches in match info")

    static let singleMatchInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "2", queryParams: nil,
                                                                    title: "Hymn: single match in lyrics", matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0]))
    static let singleMatchInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "2", queryParams: nil, title: "Hymn: single match in lyrics")

    static let singleMatchInTitleSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "3", queryParams: nil,
                                                                   title: "single match in title", matchInfo: Data([0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]))
    static let singleMatchInTitle = SongResultEntity(hymnType: .classic, hymnNumber: "3", queryParams: nil, title: "single match in title")

    static let twoMatchesInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "4", queryParams: nil,
                                                                   title: "Hymn: two matches in lyrics", matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0]))
    static let twoMatchesInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "4", queryParams: nil, title: "Hymn: two matches in lyrics")

    static let maxMatchesInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "5", queryParams: nil,
                                                                   title: "max matches in lyrics", matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0xff, 0xff, 0xff, 0xff]))
    static let maxMatchesInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "5", queryParams: nil, title: "max matches in lyrics")

    static let maxMatchesInTitleSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "6", queryParams: nil,
                                                                  title: "Hymn: max matches in title", matchInfo: Data([0xff, 0xff, 0xff, 0xff, 0x0, 0x0, 0x0, 0x0]))
    static let maxMatchesInTitle = SongResultEntity(hymnType: .classic, hymnNumber: "6", queryParams: nil, title: "Hymn: max matches in title")

    static let maxMatchesInBothSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "7", queryParams: nil,
                                                                 title: "max matches in both", matchInfo: Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    static let maxMatchesInBoth = SongResultEntity(hymnType: .classic, hymnNumber: "7", queryParams: nil, title: "max matches in both")

    let databaseResults = [noMatchesSearchResult, singleMatchInLyricsSearchResult, singleMatchInTitleSearchResult, twoMatchesInLyricsSearchResult,
                           maxMatchesInLyricsSearchResult, maxMatchesInTitleSearchResult, maxMatchesInBothSearchResult]
    let sortedDatabaseResults = [maxMatchesInBoth, maxMatchesInTitle, maxMatchesInLyrics, singleMatchInTitle, twoMatchesInLyrics, singleMatchInLyrics, noMatches]
    let networkResult = SongResultsPage(results: [SongResult(name: "classic 1151", path: "/en/hymn/h/1151"), SongResult(name: "Hymn 1", path: "/en/hymn/h/1")],
                                        hasMorePages: false)

    var backgroundQueue = DispatchQueue.init(label: "background test queue")
    var converter: ConverterMock!
    var dataStore: HymnDataStoreMock!
    var service: HymnalApiServiceMock!
    var systemUtil: SystemUtilMock!
    var target: SongResultsRepository!

    override func setUp() {
        super.setUp()
        converter = mock(Converter.self)
        dataStore = mock(HymnDataStore.self)
        service = mock(HymnalApiService.self)
        systemUtil = mock(SystemUtil.self)
        target = SongResultsRepositoryImpl(converter: converter, dataStore: dataStore, mainQueue: backgroundQueue, service: service, systemUtil: systemUtil)
    }

    func test_searchHymn_databaseError_noNetwork() {
        given(dataStore.getDatabaseInitializedProperly()) ~> false
        given(systemUtil.isNetworkAvailable()) ~> false

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.isInverted = true
        let cancellable = target.search(searchParameter: "param", pageNumber: 1)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.failure(.data(description: "database was not intialized properly"))))
            }, receiveValue: { _ in
                value.fulfill()
            })

        verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
        verify(dataStore.searchHymn(any())).wasNeverCalled()
        verify(service.search(for: any(), onPage: any())).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_searchHymn_databaseResults_noNetwork_sortResults() {
        given(dataStore.getDatabaseInitializedProperly()) ~> true
        given(systemUtil.isNetworkAvailable()) ~> false
        given(dataStore.searchHymn("Chenaniah")) ~> { _ in
            Just(self.databaseResults).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
        let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifier: classic1151)], hasMorePages: false)
        given(converter.toUiSongResultsPage(songResultsEntities: self.sortedDatabaseResults, hasMorePages: false)) ~> convertedResultPage

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.finished))
            }, receiveValue: { page in
                value.fulfill()
                expect(page).to(equal(convertedResultPage))
            })
        verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
        verify(dataStore.searchHymn("Chenaniah")).wasCalled(exactly(1))
        verify(service.search(for: any(), onPage: any())).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_searchHymn_databaseResults_networkResults() {
        given(dataStore.getDatabaseInitializedProperly()) ~> true
        given(systemUtil.isNetworkAvailable()) ~> true
        given(dataStore.searchHymn("Chenaniah")) ~> { _ in
            Just(self.databaseResults).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(service.search(for: "Chenaniah", onPage: 1)) ~> { _, _ in
            Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
        let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifier: classic1151)], hasMorePages: false)
        given(converter.toUiSongResultsPage(songResultsEntities: self.sortedDatabaseResults, hasMorePages: false)) ~> convertedResultPage

        let networkSongResultEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151 again"),
                                         SongResultEntity(hymnType: .cebuano, hymnNumber: "123", queryParams: nil, title: "cebuano 123")]
        given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
        let convertedNetworkResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151 again", identifier: classic1151),
                                                                     UiSongResult(name: "cebuano 123", identifier: cebuano123)], hasMorePages: false)
        given(converter.toUiSongResultsPage(songResultsEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.expectedFulfillmentCount = 2
        var valueCount = 0
        let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.finished))
            }, receiveValue: { page in
                value.fulfill()
                valueCount += 1
                if valueCount == 1 {
                    expect(page).to(equal(convertedResultPage))
                } else if valueCount == 2 {
                    expect(page).to(equal(convertedNetworkResultPage))
                } else {
                    XCTFail("receiveValue should only be called twice")
                }
            })
        verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
        verify(dataStore.searchHymn("Chenaniah")).wasCalled(exactly(1))
        verify(service.search(for: "Chenaniah", onPage: 1)).wasCalled(exactly(1))
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_searchHymns_databaseMiss_networkResults() {
        given(dataStore.getDatabaseInitializedProperly()) ~> true
        given(systemUtil.isNetworkAvailable()) ~> true
        given(dataStore.searchHymn("Chenaniah")) ~> { _ in
            Just([SearchResultEntity]()).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(service.search(for: "Chenaniah", onPage: 1)) ~> { _, _ in
            Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(converter.toUiSongResultsPage(songResultsEntities: [SongResultEntity](), hasMorePages: false)) ~> UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
        let networkSongResultEntities = [SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "classic 1151 again"),
                                         SongResultEntity(hymnType: .cebuano, hymnNumber: "123", queryParams: nil, title: "cebuano 123")]
        given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
        let convertedNetworkResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151 again", identifier: classic1151),
                                                                     UiSongResult(name: "cebuano 123", identifier: cebuano123)], hasMorePages: false)
        given(converter.toUiSongResultsPage(songResultsEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.expectedFulfillmentCount = 2
        var valueCount = 0
        let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.finished))
            }, receiveValue: { page in
                value.fulfill()
                valueCount += 1
                if valueCount == 1 {
                    expect(page.results).to(beEmpty())
                    expect(page.hasMorePages).to(beFalse())
                } else if valueCount == 2 {
                    expect(page).to(equal(convertedNetworkResultPage))
                } else {
                    XCTFail("receiveValue should only be called twice")
                }
            })
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_searchHymn_databaseResults_networkError() {
        given(dataStore.getDatabaseInitializedProperly()) ~> true
        given(systemUtil.isNetworkAvailable()) ~> true
        given(dataStore.searchHymn("Chenaniah")) ~> { _ in
            Just(self.databaseResults).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(service.search(for: "Chenaniah", onPage: 1)) ~> { _, _ in
            Just(self.networkResult)
                .tryMap({ _ -> SongResultsPage in
                    throw URLError(.badServerResponse)
                })
                .mapError({ _ -> ErrorType in
                    ErrorType.data(description: "forced network error")
                }).eraseToAnyPublisher()
        }
        // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
        let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifier: classic1151)], hasMorePages: false)
        given(converter.toUiSongResultsPage(songResultsEntities: self.sortedDatabaseResults, hasMorePages: false)) ~> convertedResultPage

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.failure(Hymns.ErrorType.data(description: "forced network error"))))
            }, receiveValue: { page in
                value.fulfill()
                expect(page).to(equal(convertedResultPage))
            })
        verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
        verify(dataStore.searchHymn("Chenaniah")).wasCalled(exactly(1))
        verify(service.search(for: "Chenaniah", onPage: 1)).wasCalled(exactly(1))
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }
}
