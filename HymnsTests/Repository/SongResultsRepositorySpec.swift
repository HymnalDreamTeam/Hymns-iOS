import Combine
import Mockingbird
import Nimble
import XCTest
import Quick
@testable import Hymns

// swiftlint:disable:next type_body_length
class SongResultsRepositorySpec: AsyncSpec {

    static let noMatchesSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "1", title: "no matches in match info",
                                                          matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
                                                          songId: 0)
    static let noMatches = SongResultEntity(hymnType: .classic, hymnNumber: "1", title: "no matches in match info", songId: 0)

    static let singleMatchInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "2", title: "Hymn: single match in lyrics",
                                                                    matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0]),
                                                                    songId: 0)
    static let singleMatchInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "2", title: "Hymn: single match in lyrics", songId: 0)

    static let singleMatchInTitleSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "3", title: "single match in title",
                                                                   matchInfo: Data([0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]),
                                                                   songId: 0)
    static let singleMatchInTitle = SongResultEntity(hymnType: .classic, hymnNumber: "3", title: "single match in title", songId: 0)

    static let twoMatchesInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "4", title: "Hymn: two matches in lyrics",
                                                                   matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0]),
                                                                   songId: 0)
    static let twoMatchesInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "4", title: "Hymn: two matches in lyrics", songId: 0)

    static let maxMatchesInLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "5", title: "max matches in lyrics",
                                                                   matchInfo: Data([0x0, 0x0, 0x0, 0x0, 0xff, 0xff, 0xff, 0xff]),
                                                                   songId: 0)
    static let maxMatchesInLyrics = SongResultEntity(hymnType: .classic, hymnNumber: "5", title: "max matches in lyrics", songId: 0)

    static let maxMatchesInTitleSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "6", title: "Hymn: max matches in title",
                                                                  matchInfo: Data([0xff, 0xff, 0xff, 0xff, 0x0, 0x0, 0x0, 0x0]),
                                                                  songId: 0)
    static let maxMatchesInTitle = SongResultEntity(hymnType: .classic, hymnNumber: "6", title: "Hymn: max matches in title", songId: 0)

    static let maxMatchesTitleSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "7", title: "max matches in both",
                                                                matchInfo: Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xdf, 0xff]),
                                                                songId: 0)
    static let maxMatchesLyricsSearchResult = SearchResultEntity(hymnType: .classic, hymnNumber: "7", title: "max matches in both",
                                                                 matchInfo: Data([0x0f, 0xaa, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]),
                                                                 songId: 0)
    static let maxMatches = SongResultEntity(hymnType: .classic, hymnNumber: "7", title: "max matches in both", songId: 0)

    static let maxMatchesInBothButWrongTypeSearchResult = SearchResultEntity(hymnType: .portuguese, hymnNumber: "7",
                                                                             title: "max matches in both but wrong type",
                                                                             matchInfo: Data([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]),
                                                                             songId: 0)
    static let maxMatchesInBothButWrongType = SongResultEntity(hymnType: .portuguese, hymnNumber: "7",
                                                               title: "max matches in both but wrong type",
                                                               songId: 0)

    static let titleResults = [noMatchesSearchResult, singleMatchInLyricsSearchResult, singleMatchInTitleSearchResult,
                               maxMatchesInBothButWrongTypeSearchResult, twoMatchesInLyricsSearchResult,
                               maxMatchesInLyricsSearchResult, maxMatchesInTitleSearchResult, maxMatchesTitleSearchResult]
    static let lyricsResults = [noMatchesSearchResult, maxMatchesLyricsSearchResult]
    // Note: maxMatches is only rank #1 (over maxMatchesInBothButWrongType) because the match infos are "combined" together between
    //  maxMatchesTitleSearchResult and maxMatchesLyricsSearchResult. Otherwise, maxMatchesInBothButWrongType would rank higher.
    static let sortedDatabaseResults = [maxMatches, maxMatchesInBothButWrongType, maxMatchesInTitle, maxMatchesInLyrics,
                                        twoMatchesInLyrics, singleMatchInTitle, singleMatchInLyrics, noMatches]

    static let networkResult = SongResultsPage(results: [SongResult(name: "classic 1151", path: "/en/hymn/h/1151"),
                                                         SongResult(name: "Hymn 1", path: "/en/hymn/h/1")],
                                               hasMorePages: false)

    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("SongResultsRepository") {
            let backgroundQueue = DispatchQueue.init(label: "background test queue")
            var converter: ConverterMock!
            var dataStore: HymnDataStoreMock!
            var service: HymnalApiServiceMock!
            var systemUtil: SystemUtilMock!
            var target: SongResultsRepository!

            var completion: XCTestExpectation!
            var value: XCTestExpectation!
            beforeEach {
                converter = mock(Converter.self)
                dataStore = mock(HymnDataStore.self)
                service = mock(HymnalApiService.self)
                systemUtil = mock(SystemUtil.self)
                target = SongResultsRepositoryImpl(converter: converter, dataStore: dataStore, mainQueue: backgroundQueue,
                                                   service: service, systemUtil: systemUtil)

                completion = XCTestExpectation(description: "completion received")
                value = XCTestExpectation(description: "value received")
            }
            context("no network") {
                beforeEach {
                    given(systemUtil.isNetworkAvailable()) ~> false
                }
                context("data store not initialized properly") {
                    beforeEach {
                        given(dataStore.getDatabaseInitializedProperly()) ~> false
                    }
                    it("should return a failure completion") {
                        value.isInverted = true
                        let cancellable = target.search(searchParameter: "param", pageNumber: 1)
                            .print(current.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.failure(.data(description: "database was not intialized properly"))))
                            }, receiveValue: { _ in
                                value.fulfill()
                            })

                        verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
                        verify(dataStore.searchHymn(any())).wasNeverCalled()
                        verify(service.search(for: any(), onPage: any())).wasNeverCalled()
                        await current.fulfillment(of: [completion, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                context("data store initialized properly") {
                    beforeEach {
                        given(dataStore.getDatabaseInitializedProperly()) ~> true
                        given(dataStore.searchHymn("(O OR Oh)!!! Loving you (Lord’s OR Lord's) all (I’m OR I'm) living for.")) ~> { _ in
                            Just(Self.titleResults).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        given(dataStore.searchHymn("o loving you lords all im living for")) ~> { _ in
                            Just(Self.lyricsResults).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                    }
                    it("should return only data store results") {
                        // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
                        let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifiers: [classic1151])], hasMorePages: false)
                        given(converter.toUiSongResultsPage(songResultEntities: self.sortedDatabaseResults, hasMorePages: false)) ~> convertedResultPage

                        let cancellable = target.search(searchParameter: "O!!! Loving you Lord's all I'm living for.", pageNumber: 1)
                            .print(current.description)
                            .sink(receiveCompletion: { state in
                                completion.fulfill()
                                expect(state).to(equal(.finished))
                            }, receiveValue: { page in
                                value.fulfill()
                                expect(page).to(equal(convertedResultPage))
                            })
                        verify(dataStore.getDatabaseInitializedProperly()).wasCalled()
                        verify(dataStore.searchHymn("(O OR Oh)!!! Loving you (Lord’s OR Lord's) all (I’m OR I'm) living for.")).wasCalled(exactly(1))
                        verify(dataStore.searchHymn("o loving you lords all im living for")).wasCalled(exactly(1))
                        await current.fulfillment(of: [completion, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
            }
            context("network available") {
                beforeEach {
                    given(systemUtil.isNetworkAvailable()) ~> true
                }
                /// Only set data store to initialzed to simplify tests. Don't need to test the case where both data stores are initialized since that only matters in
                /// loadFromDatabase, which is thoroughly tested above already.
                context("data store initialized properly") {
                    beforeEach {
                        given(dataStore.getDatabaseInitializedProperly()) ~> true
                        given(dataStore.searchHymn("chenaniah")) ~> { _ in
                            Just([singleMatchInLyricsSearchResult]).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                    }
                    context("network error") {
                        beforeEach {
                            given(service.search(for: "chenaniah", onPage: 1)) ~> { _, _ in
                                Just(Self.networkResult)
                                    .tryMap({ _ -> SongResultsPage in
                                        throw URLError(.badServerResponse)
                                    })
                                    .mapError({ _ -> ErrorType in
                                        ErrorType.data(description: "forced network error")
                                    }).eraseToAnyPublisher()
                            }
                        }
                        it("should return only data store results") {
                            // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
                            let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifiers: [classic1151])], hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: [singleMatchInLyrics], hasMorePages: false)) ~> convertedResultPage

                            let cancellable = target.search(searchParameter: "chenaniah", pageNumber: 1)
                                .print(current.description)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.failure(Hymns.ErrorType.data(description: "forced network error"))))
                                }, receiveValue: { page in
                                    value.fulfill()
                                    expect(page).to(equal(convertedResultPage))
                                })
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled()
                            verify(dataStore.searchHymn("chenaniah")).wasCalled(exactly(2))
                            verify(service.search(for: "chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                    context("network results") {
                        beforeEach {
                            given(service.search(for: "chenaniah", onPage: 1)) ~> { _, _ in
                                Just(self.networkResult).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                        }
                        it("should append network results to data store results") {
                            // Since we're mocking out the converter, we can conveniently just return one result in the page for succinctness.
                            let convertedResultPage = UiSongResultsPage(results: [UiSongResult(name: "classic 1151", identifiers: [classic1151])], hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: [singleMatchInLyrics], hasMorePages: false)) ~> convertedResultPage

                            let networkSongResultEntities = [
                                SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151 again", songId: 0),
                                SongResultEntity(hymnType: .cebuano, hymnNumber: "123", title: "cebuano 123", songId: 0)]
                            given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
                            let convertedNetworkResultPage = UiSongResultsPage(
                                results: [UiSongResult(name: "classic 1151 again", identifiers: [classic1151]),
                                          UiSongResult(name: "cebuano 123", identifiers: [cebuano123])],
                                hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

                            value.expectedFulfillmentCount = 2
                            var valueCount = 0
                            let cancellable = target.search(searchParameter: "chenaniah", pageNumber: 1)
                                .print(current.description)
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
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled()
                            verify(dataStore.searchHymn("chenaniah")).wasCalled(exactly(2))
                            verify(service.search(for: "chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                }
                context("data store not initialized properly") {
                    beforeEach {
                        given(dataStore.getDatabaseInitializedProperly()) ~> false
                    }
                    context("network error") {
                        beforeEach {
                            given(service.search(for: "Chenaniah", onPage: 1)) ~> { _, _ in
                                Just(self.networkResult)
                                    .tryMap({ _ -> SongResultsPage in
                                        throw URLError(.badServerResponse)
                                    })
                                    .mapError({ _ -> ErrorType in
                                        ErrorType.data(description: "forced network error")
                                    }).eraseToAnyPublisher()
                            }
                        }
                        it("should return network error") {
                            let emptyResultPage = UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> emptyResultPage

                            value.isInverted = true
                            let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
                                .print(current.description)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.failure(Hymns.ErrorType.data(description: "forced network error"))))
                                }, receiveValue: { _ in
                                    value.fulfill()
                                })
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
                            verify(dataStore.searchHymn("Chenaniah")).wasNeverCalled()
                            verify(service.search(for: "Chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                    context("network results") {
                        beforeEach {
                            given(service.search(for: "Chenaniah", onPage: 1)) ~> { _, _ in
                                Just(self.networkResult).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                        }
                        it("should return network results") {
                            given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                            let networkSongResultEntities = [
                                SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151 again", songId: 0),
                                SongResultEntity(hymnType: .cebuano, hymnNumber: "123", title: "cebuano 123", songId: 0)]
                            given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
                            let convertedNetworkResultPage = UiSongResultsPage(
                                results: [UiSongResult(name: "classic 1151 again", identifiers: [classic1151]),
                                          UiSongResult(name: "cebuano 123", identifiers: [cebuano123])],
                                hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

                            let cancellable = target.search(searchParameter: "Chenaniah", pageNumber: 1)
                                .print(current.description)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.finished))
                                }, receiveValue: { page in
                                    value.fulfill()
                                    expect(page).to(equal(convertedNetworkResultPage))
                                })
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled(exactly(1))
                            verify(dataStore.searchHymn("Chenaniah")).wasNeverCalled()
                            verify(service.search(for: "Chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                }
                context("data store miss") {
                    beforeEach {
                        given(dataStore.getDatabaseInitializedProperly()) ~> true
                        given(dataStore.searchHymn("chenaniah")) ~> { _ in
                            Just([SearchResultEntity]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                    }
                    context("network error") {
                        beforeEach {
                            given(service.search(for: "chenaniah", onPage: 1)) ~> { _, _ in
                                Just(self.networkResult)
                                    .tryMap({ _ -> SongResultsPage in
                                        throw URLError(.badServerResponse)
                                    })
                                    .mapError({ _ -> ErrorType in
                                        ErrorType.data(description: "forced network error")
                                    }).eraseToAnyPublisher()
                            }
                        }
                        it("should return network error") {
                            let emptyResultPage = UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> emptyResultPage

                            let cancellable = target.search(searchParameter: "chenaniah", pageNumber: 1)
                                .print(current.description)
                                .sink(receiveCompletion: { state in
                                    completion.fulfill()
                                    expect(state).to(equal(.failure(Hymns.ErrorType.data(description: "forced network error"))))
                                }, receiveValue: { page in
                                    value.fulfill()
                                    expect(page).to(equal(emptyResultPage))
                                })
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled()
                            verify(dataStore.searchHymn("chenaniah")).wasCalled(exactly(2))
                            verify(service.search(for: "chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                    context("network results") {
                        beforeEach {
                            given(service.search(for: "chenaniah", onPage: 1)) ~> { _, _ in
                                Just(self.networkResult).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                        }
                        it("should return network results") {
                            given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                            let networkSongResultEntities = [
                                SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151 again", songId: 0),
                                SongResultEntity(hymnType: .cebuano, hymnNumber: "123", title: "cebuano 123", songId: 0)]
                            given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
                            let convertedNetworkResultPage = UiSongResultsPage(
                                results: [UiSongResult(name: "classic 1151 again", identifiers: [classic1151]),
                                          UiSongResult(name: "cebuano 123", identifiers: [cebuano123])],
                                hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

                            value.expectedFulfillmentCount = 2
                            var valueCount = 0
                            let cancellable = target.search(searchParameter: "chenaniah", pageNumber: 1)
                                .print(current.description)
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
                            verify(dataStore.getDatabaseInitializedProperly()).wasCalled()
                            verify(dataStore.searchHymn("chenaniah")).wasCalled(exactly(2))
                            verify(service.search(for: "chenaniah", onPage: 1)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                    context("network results page 2") {
                        beforeEach {
                            given(service.search(for: "chenaniah", onPage: 2)) ~> { _, _ in
                                Just(self.networkResult).mapError({ _ -> ErrorType in
                                    // This will never be triggered.
                                }).eraseToAnyPublisher()
                            }
                        }
                        it("should not hit the database") {
                            given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                            let networkSongResultEntities = [
                                SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151 again", songId: 0),
                                SongResultEntity(hymnType: .cebuano, hymnNumber: "123", title: "cebuano 123", songId: 0)]
                            given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
                            let convertedNetworkResultPage = UiSongResultsPage(
                                results: [UiSongResult(name: "classic 1151 again", identifiers: [classic1151]),
                                          UiSongResult(name: "cebuano 123", identifiers: [cebuano123])],
                                hasMorePages: false)
                            given(converter.toUiSongResultsPage(songResultEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

                            value.expectedFulfillmentCount = 2
                            var valueCount = 0
                            let cancellable = target.search(searchParameter: "chenaniah", pageNumber: 2)
                                .print(current.description)
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
                            verify(dataStore.getDatabaseInitializedProperly()).wasNeverCalled()
                            verify(dataStore.searchHymn("chenaniah")).wasNeverCalled()
                            verify(service.search(for: "chenaniah", onPage: 2)).wasCalled(exactly(1))
                            await current.fulfillment(of: [completion, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                }
                context("search param has quotes") {
                    beforeEach {
                        given(service.search(for: "\"Chena \"ni\" ah\"", onPage: 1)) ~> { _, _ in
                            Just(self.networkResult).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        given(converter.toUiSongResultsPage(songResultEntities: [SongResultEntity](), hasMorePages: false)) ~> UiSongResultsPage(results: [UiSongResult](), hasMorePages: false)
                        let networkSongResultEntities = [
                            SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "classic 1151 again", songId: 0),
                            SongResultEntity(hymnType: .cebuano, hymnNumber: "123", title: "cebuano 123", songId: 0)]
                        given(converter.toSongResultEntities(songResultsPage: self.networkResult)) ~> (networkSongResultEntities, self.networkResult.hasMorePages!)
                        let convertedNetworkResultPage = UiSongResultsPage(
                            results: [UiSongResult(name: "classic 1151 again", identifiers: [classic1151]),
                                      UiSongResult(name: "cebuano 123", identifiers: [cebuano123])],
                            hasMorePages: false)
                        given(converter.toUiSongResultsPage(songResultEntities: networkSongResultEntities, hasMorePages: false)) ~> convertedNetworkResultPage

                        value.expectedFulfillmentCount = 2
                        var valueCount = 0
                        let cancellable = target.search(searchParameter: "\"Chena “ni” ah\"", pageNumber: 1)
                            .print(current.description)
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
                        verify(dataStore.getDatabaseInitializedProperly()).wasNeverCalled()
                        await current.fulfillment(of: [completion, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                    it("should not hit the database") {
                        verify(dataStore.searchHymn(any())).wasNeverCalled()
                    }
                    it("replace curly quotes in network call") {
                        verify(service.search(for: "\"Chena \"ni\" ah\"", onPage: 1)).wasCalled(exactly(1))
                    }
                }
            }
        }
    }
}
