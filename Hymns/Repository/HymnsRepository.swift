import Combine
import Foundation
import Resolver

/**
 * Repository that stores all hymns that have been searched during this session in memory.
 */
protocol HymnsRepository {
    func getHymn(_ hymnIdentifier: HymnIdentifier)  -> AnyPublisher<UiHymn?, Never>
    func getHymn(_ hymnIdentifier: HymnIdentifier, makeNetworkRequest: Bool)  -> AnyPublisher<UiHymn?, Never>
}

class HymnsRepositoryImpl: HymnsRepository {

    private let converter: Converter
    private let dataStore: HymnDataStore
    private let firebaseLogger: FirebaseLogger
    private let mainQueue: DispatchQueue
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    private var disposables = Set<AnyCancellable>()
    private var hymns: [HymnIdentifier: UiHymn] = [HymnIdentifier: UiHymn]()

    init(converter: Converter = Resolver.resolve(),
         dataStore: HymnDataStore = Resolver.resolve(),
         firebaseLogger: FirebaseLogger = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         service: HymnalApiService = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.converter = converter
        self.dataStore = dataStore
        self.firebaseLogger = firebaseLogger
        self.mainQueue = mainQueue
        self.service = service
        self.systemUtil = systemUtil
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier)  -> AnyPublisher<UiHymn?, Never> {
        return getHymn(hymnIdentifier, makeNetworkRequest: true)
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier, makeNetworkRequest: Bool)  -> AnyPublisher<UiHymn?, Never> {
        if let hymn = hymns[hymnIdentifier] {
            return Just(hymn).eraseToAnyPublisher()
        }
        return HymnPublisher(hymnIdentifier: hymnIdentifier, disposables: &disposables, converter: converter,
                             dataStore: dataStore, firebaseLogger: firebaseLogger, makeNetworkRequest: makeNetworkRequest,
                             service: service, systemUtil: systemUtil)
            .replaceError(with: nil)
            .map { hymn -> UiHymn? in
                guard let hymn = hymn else {
                    return nil
                }
                self.mainQueue.async {
                    self.hymns[hymnIdentifier] = hymn
                }
                return hymn
        }.eraseToAnyPublisher()
    }
}

private class HymnPublisher: NetworkBoundPublisher {

    typealias UIResultType = UiHymn?
    typealias Output = UiHymn?

    private var disposables: Set<AnyCancellable>
    private let converter: Converter
    private let dataStore: HymnDataStore
    private let firebaseLogger: FirebaseLogger
    private let hymnIdentifier: HymnIdentifier
    private let makeNetworkRequest: Bool
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    init(hymnIdentifier: HymnIdentifier, disposables: inout Set<AnyCancellable>, converter: Converter,
         dataStore: HymnDataStore, firebaseLogger: FirebaseLogger, makeNetworkRequest: Bool, service: HymnalApiService,
         systemUtil: SystemUtil) {
        self.disposables = disposables
        self.converter = converter
        self.dataStore = dataStore
        self.firebaseLogger = firebaseLogger
        self.hymnIdentifier = hymnIdentifier
        self.makeNetworkRequest = makeNetworkRequest
        self.service = service
        self.systemUtil = systemUtil
    }

    func createSubscription<S>(_ subscriber: S) -> Subscription where S: Subscriber, S.Failure == ErrorType, S.Input == UIResultType {
        HymnSubscription(hymnIdentifier: hymnIdentifier, converter: converter, dataStore: dataStore,
                         disposables: &disposables, firebaseLogger: firebaseLogger, makeNetworkRequest: makeNetworkRequest,
                         service: service, subscriber: subscriber, systemUtil: systemUtil)
    }
}

private class HymnSubscription<SubscriberType: Subscriber>: NetworkBoundSubscription where SubscriberType.Input == UiHymn?, SubscriberType.Failure == ErrorType {

    private let analytics: FirebaseLogger
    private let converter: Converter
    private let dataStore: HymnDataStore
    private let firebaseLogger: FirebaseLogger
    private let hymnIdentifier: HymnIdentifier
    private let makeNetworkRequest: Bool
    private let service: HymnalApiService
    private let systemUtil: SystemUtil

    var subscriber: SubscriberType?
    var disposables: Set<AnyCancellable>

    fileprivate init(hymnIdentifier: HymnIdentifier, analytics: FirebaseLogger = Resolver.resolve(),
                     converter: Converter, dataStore: HymnDataStore, disposables: inout Set<AnyCancellable>,
                     firebaseLogger: FirebaseLogger, makeNetworkRequest: Bool, service: HymnalApiService,
                     subscriber: SubscriberType, systemUtil: SystemUtil) {
        // okay to inject analytics because we aren't mocking it in the unit tests
        self.analytics = analytics
        self.converter = converter
        self.dataStore = dataStore
        self.disposables = disposables
        self.firebaseLogger = firebaseLogger
        self.hymnIdentifier = hymnIdentifier
        self.makeNetworkRequest = makeNetworkRequest
        self.service = service
        self.subscriber = subscriber
        self.systemUtil = systemUtil
    }

    func saveToDatabase(databaseResult: HymnEntity??, convertedNetworkResult: HymnEntity?) {
        if !dataStore.databaseInitializedProperly {
            return
        }

        guard let convertedNetworkResult = convertedNetworkResult else {
            return
        }

        let flattenedDatabaseResult = databaseResult?.flatMap({databaseResult -> HymnEntity? in return databaseResult})

        // Combine the result from the database and the network and update the database entry.
        let combinedHymn = combineHymns(databaseResult: flattenedDatabaseResult, convertedNetworkResult: convertedNetworkResult)
        if combinedHymn != flattenedDatabaseResult {
            guard let songId = dataStore.saveHymn(combinedHymn) else {
                firebaseLogger.logError(message: "Failed to save song to the database",
                                        extraParameters: ["song": String(describing: combinedHymn)])
                return
            }
            dataStore.saveHymn(HymnIdEntity(hymnIdentifier: hymnIdentifier, songId: songId))
        }
    }

    /// Takes two HymnEntities, one from the database and one from the network, and combines them into one as an update to write to the database entry for that hymn.
    private func combineHymns(databaseResult: HymnEntity?, convertedNetworkResult: HymnEntity) -> HymnEntity {
        guard let databaseResult = databaseResult else {
            return convertedNetworkResult
        }
        return databaseResult
    }

    func shouldFetch(convertedDatabaseResult: UiHymn??) -> Bool {
        guard makeNetworkRequest, systemUtil.isNetworkAvailable() else {
            return false
        }
        return convertedDatabaseResult?.flatMap({ uiHymn -> UiHymn? in return uiHymn }) == nil
    }

    /// Converts the network result to the equivalent database result type.
    func convertType(networkResult: Hymn) throws -> HymnEntity? {
        do {
            return try converter.toHymnEntity(hymn: networkResult)
        } catch {
            analytics.logError(message: "error orccured when converting Hymn to HymnEntity", error: error, extraParameters: ["hymnIdentifier": String(describing: hymnIdentifier)])
            throw TypeConversionError(triggeringError: error)
        }
    }

    /// Converts the database result to the type consumed by the UI.
    func convertType(databaseResult: HymnEntity?) throws -> UiHymn? {
        do {
            return try converter.toUiHymn(hymnIdentifier: hymnIdentifier, hymnEntity: databaseResult)
        } catch {
            analytics.logError(message: "error orccured when converting HymnEntity to UiHymn", error: error, extraParameters: ["hymnIdentifier": String(describing: hymnIdentifier)])
            throw TypeConversionError(triggeringError: error)
        }
    }

    func loadFromDatabase() -> AnyPublisher<HymnEntity?, ErrorType> {
        if !dataStore.databaseInitializedProperly {
            return Just<HymnEntity?>(nil).tryMap { _ -> HymnEntity? in
                throw ErrorType.data(description: "database was not intialized properly")
            }.mapError({ error -> ErrorType in
                ErrorType.data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
        }
        return dataStore.getHymn(hymnIdentifier).map { $0?.hymnEntity }.eraseToAnyPublisher()
    }

    func createNetworkCall() -> AnyPublisher<Hymn, ErrorType> {
        service.getHymn(hymnIdentifier)
    }
}
