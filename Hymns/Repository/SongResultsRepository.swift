import Combine
import Foundation
import Resolver
import SwiftUI

/**
 * Repository to fetch a list of songs results, both from local storage and from the network.
 */
protocol SongResultsRepository {
    func search(searchParameter: String, pageNumber: Int) -> AnyPublisher<UiSongResultsPage, ErrorType>
    func search(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType>
}

class SongResultsRepositoryImpl: SongResultsRepository {

    private let converter: Converter
    private let dataStore: HymnDataStore
    private let mainQueue: DispatchQueue
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    private var disposables = Set<AnyCancellable>()

    init(converter: Converter = Resolver.resolve(),
         dataStore: HymnDataStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         service: HymnalApiService = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.converter = converter
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.service = service
        self.systemUtil = systemUtil
    }

    func search(searchParameter: String, pageNumber: Int) -> AnyPublisher<UiSongResultsPage, ErrorType> {
        SearchPublisher(pageNumber: pageNumber, searchParameter: searchParameter, converter: converter,
                        dataStore: dataStore, disposables: &disposables, service: service, systemUtil: systemUtil)
        .eraseToAnyPublisher()
    }

    func search(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        dataStore.getResultsBy(hymnCode: hymnCode)
    }
}

private class SearchPublisher: NetworkBoundPublisher {

    typealias UIResultType = UiSongResultsPage
    typealias Output = UiSongResultsPage

    private var disposables: Set<AnyCancellable>
    private let converter: Converter
    private let dataStore: HymnDataStore
    private let pageNumber: Int
    private let searchParameter: String
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    fileprivate init(pageNumber: Int, searchParameter: String, converter: Converter, dataStore: HymnDataStore,
                     disposables: inout Set<AnyCancellable>, service: HymnalApiService, systemUtil: SystemUtil) {
        self.converter = converter
        self.dataStore = dataStore
        self.disposables = disposables
        self.pageNumber = pageNumber
        self.searchParameter = searchParameter
        self.service = service
        self.systemUtil = systemUtil
    }

    func createSubscription<S>(_ subscriber: S) -> Subscription where S: Subscriber, S.Failure == ErrorType, S.Input == UIResultType {
        SearchSubscription(pageNumber: pageNumber, searchParameter: searchParameter, converter: converter, dataStore: dataStore,
                           disposables: &disposables, service: service, subscriber: subscriber, systemUtil: systemUtil)
    }
}

private class SearchSubscription<SubscriberType: Subscriber>: NetworkBoundSubscription where SubscriberType.Input == UiSongResultsPage, SubscriberType.Failure == ErrorType {

    @AppStorage("preferred_search_language") var preferredSearchLanguage: Language = .english

    private let analytics: FirebaseLogger
    private let converter: Converter
    private let dataStore: HymnDataStore
    private let pageNumber: Int
    private let searchParameter: String
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    var subscriber: SubscriberType?
    var disposables: Set<AnyCancellable>

    fileprivate init(pageNumber: Int, searchParameter: String, analytics: FirebaseLogger = Resolver.resolve(),
                     converter: Converter, dataStore: HymnDataStore, disposables: inout Set<AnyCancellable>,
                     service: HymnalApiService, subscriber: SubscriberType, systemUtil: SystemUtil) {
        // okay to inject analytics because wse aren't mocking it in the unit tests
        self.analytics = analytics
        self.converter = converter
        self.dataStore = dataStore
        self.disposables = disposables
        self.pageNumber = pageNumber
        self.searchParameter = searchParameter
        self.service = service
        self.subscriber = subscriber
        self.systemUtil = systemUtil
    }

    func saveToDatabase(databaseResult: ([SongResultEntity], Bool)?, convertedNetworkResult: ([SongResultEntity], Bool)) {
        // do nothing
    }

    func shouldFetch(convertedDatabaseResult: UiSongResultsPage?) -> Bool {
        systemUtil.isNetworkAvailable()
    }

    func convertType(networkResult: SongResultsPage) throws -> ([SongResultEntity], Bool) {
        converter.toSongResultEntities(songResultsPage: networkResult)
    }

    func convertType(databaseResult: ([SongResultEntity], Bool)) throws -> UiSongResultsPage {
        converter.toUiSongResultsPage(songResultEntities: databaseResult.0, hasMorePages: databaseResult.1)
    }

    func loadFromDatabase() -> AnyPublisher<([SongResultEntity], Bool), ErrorType> {
        // Only hit DB on page 1 because DB isn't pagineated.
        if pageNumber != 1 {
            return Just(([SongResultEntity](), false)).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }

        // Go straight to network for exact search.
        if RegexUtil.containsQuote(searchParameter) {
            return Just(([SongResultEntity](), false)).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }

        if !dataStore.databaseInitializedProperly {
            return Just<Void>(()).tryMap { _ -> ([SongResultEntity], Bool) in
                throw ErrorType.data(description: "database was not intialized properly")
            }.mapError({ error -> ErrorType in
                ErrorType.data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
        }

        let dataStoreResults = dataStore.searchHymn(santize(searchParameter))

        return dataStoreResults
            .reduce(([SongResultEntity](), false)) { (_, searchResultEntities) -> ([SongResultEntity], Bool) in
                let sortedSongResults = searchResultEntities.sorted { (entity1, entity2) -> Bool in
                    let rank1 = self.calculateRank(entity1)
                    let rank2 = self.calculateRank(entity2)
                    return rank1 > rank2
                }.map { searchResultEntity -> SongResultEntity in
                    let title = searchResultEntity.title
                    let songId = searchResultEntity.songId
                    return SongResultEntity(hymnType: searchResultEntity.hymnType, hymnNumber: searchResultEntity.hymnNumber, title: title, songId: songId)
                }
                return (Array(sortedSongResults.prefix(50)), false)
        }.eraseToAnyPublisher()
    }

    private func santize(_ searchParameter: String) -> String {
        var sanitizedParam = searchParameter.trim()
        sanitizedParam = RegexUtil.replaceOs(sanitizedParam.trim())
        sanitizedParam = RegexUtil.replaceApostrophes(sanitizedParam.trim())
        sanitizedParam = RegexUtil.replaceCurlyQuotes(sanitizedParam.trim())
        return sanitizedParam
    }

    /*
     The matchinfo function returns a blob value. If it is used within a query that does not use the full-text index
     (a "query by rowid" or "linear scan"), then the blob is zero bytes in size. Otherwise, the blob consists of zero
     or more 32-bit unsigned integers in machine byte-order. The exact number of integers in the returned array
     depends on both the query and the value of the second argument (if any) passed to the matchinfo function.
     https://sqlite.org/fts3.html#matchinfo
     */
    private func calculateRank(_ entity: SearchResultEntity) -> UInt64 {
        let matchArray = entity.matchInfo.toArray(type: UInt32.self)
        if matchArray.count < 2 {
            return 0
        }

        // Weight the match of the title twice as much as the match of the lyrics.
        let titleMatch = UInt64(matchArray[0])
        let titleMultiplier = fibonacci(index: titleMatch) * 2

        let lyricsMatch = UInt64(matchArray[1])
        let lyricsMultiplier = fibonacci(index: lyricsMatch)

        // If the hymn is the same as the default search language, then give it extra weight.
        // This has the effect of bubbling the songs of the default search type to the top.
        let isPreferredSearchLanguage = entity.hymnType.language == preferredSearchLanguage
        let preferredLanguageExtraWeight = UInt64(isPreferredSearchLanguage ? 3 : 0)

        return (titleMatch * titleMultiplier) + (lyricsMatch * lyricsMultiplier) + preferredLanguageExtraWeight
    }

    private func fibonacci(index: UInt64) -> UInt64 {
        if index <= 1 {
            return index
        }
        var num1 = UInt64(0)
        var num2 = UInt64(1)
        for _ in 2...index {
            let result = num1 + num2
            // Max multiplier will be 1000 to avoid getting into integer overflow land with
            // fibonacci sequences. Realistically, this should never hit, because it means
            // that the user typed in 1000 words into the search bar and all 1000 words
            // matched with the lyrics of a hymn.
            if result > 1000 {
                return 1000
            }
            num1 = num2
            num2 = result
        }
        return num2
    }

    func createNetworkCall() -> AnyPublisher<SongResultsPage, ErrorType> {
        service.search(for: RegexUtil.replaceCurlyQuotes(searchParameter.trim()), onPage: pageNumber)
    }
}
