import Combine
import FirebaseCrashlytics
import Foundation
import RealmSwift
import Resolver

protocol FavoriteStore {
    func storeFavorite(_ entity: FavoriteEntity)
    func deleteFavorite(primaryKey: String)
    func favorites() -> AnyPublisher<[FavoriteEntity], ErrorType>
    func isFavorite(hymnIdentifier: HymnIdentifier) -> AnyPublisher<Bool, ErrorType>
}

class FavoriteStoreRealmImpl: FavoriteStore {

    private let analytics: AnalyticsLogger
    private let realm: Realm

    init(analytics: AnalyticsLogger = Resolver.resolve(), realm: Realm) {
        self.analytics = analytics
        self.realm = realm
    }

    func storeFavorite(_ entity: FavoriteEntity) {
        do {
            try realm.write {
                realm.add(entity, update: .modified)
            }
        } catch {
            analytics.logError(message: "error orccured when storing favorite", error: error, extraParameters: ["primaryKey": entity.primaryKey])
        }
    }

    func deleteFavorite(primaryKey: String) {
        guard let entityToDelete = realm.object(ofType: FavoriteEntity.self, forPrimaryKey: primaryKey) else {
            analytics.logError(message: "tried to delete a favorite that doesn't exist", extraParameters: ["primaryKey": primaryKey])
            return
        }

        do {
            try realm.write {
                realm.delete(entityToDelete)
            }
        } catch {
            analytics.logError(message: "error orccured when deleting favorite", error: error, extraParameters: ["primaryKey": primaryKey])
        }
    }

    func favorites() -> AnyPublisher<[FavoriteEntity], ErrorType> {
        realm.objects(FavoriteEntity.self).collectionPublisher
            .map({ results -> [FavoriteEntity] in
                results.sorted(byKeyPath: "songTitle", ascending: true).map { entity -> FavoriteEntity in
                    entity
                }
            }).mapError({ error -> ErrorType in
                .data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
    }

    func isFavorite(hymnIdentifier: HymnIdentifier) -> AnyPublisher<Bool, ErrorType> {
        realm.objects(FavoriteEntity.self)
            .filter(NSPredicate(format: "primaryKey == %@", FavoriteEntity.createPrimaryKey(hymnIdentifier: hymnIdentifier)))
            .collectionPublisher
            .map({ results -> Bool in
                !results.isEmpty
            }).mapError({ error -> ErrorType in
                .data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
    }
}

extension Resolver {
    public static func registerFavoriteStore() {
        register(FavoriteStore.self) {
            // https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file
            var url = Realm.Configuration.defaultConfiguration.fileURL
            url?.deleteLastPathComponent()
            url?.appendPathComponent("favorites.realm")
            let config = Realm.Configuration(
                fileURL: url!,
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 1,

                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // We've removed query parameters, so all songs with query params must be changed to its approprate 'simplified' hymn type
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: FavoriteEntity.className()) { old, new in
                            let newHymnIdentifier = old.flatMap { oldEntity in
                                oldEntity["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity -> HymnIdentifier? in
                                let hymnType = hymnIdentifierEntity["hymnTypeRaw"] as? String
                                let hymnNumber = hymnIdentifierEntity["hymnNumber"] as? String
                                let queryParams = (hymnIdentifierEntity["queryParams"] as? String?)?.flatMap {$0}

                                guard let hymnType = hymnType,
                                        let hymnType = HymnType.fromAbbreviatedValue(hymnType),
                                        let hymnNumber = hymnNumber else {
                                    return nil
                                }

                                // If it's a simplified Chinese song, then change the hymn type
                                if let queryParams = queryParams, queryParams.contains("gb=1") {
                                    if hymnType == .chinese {
                                        return HymnIdentifier(hymnType: .chineseSimplified, hymnNumber: hymnNumber)
                                    } else if hymnType == .chineseSupplement {
                                        return HymnIdentifier(hymnType: .chineseSupplementSimplified, hymnNumber: hymnNumber)
                                    }
                                }
                                return HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
                            }

                            guard let newHymnIdentifier = newHymnIdentifier else {
                                return
                            }

                            let newPrimaryKey = "\(newHymnIdentifier.hymnType.abbreviatedValue):\(newHymnIdentifier.hymnNumber)"
                            new.flatMap { newEntity in
                                newEntity["primaryKey"] = newPrimaryKey
                                return newEntity["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity in
                                hymnIdentifierEntity["hymnType"] = newHymnIdentifier.hymnType.abbreviatedValue
                                hymnIdentifierEntity["hymnNumber"] = newHymnIdentifier.hymnNumber
                            }
                        }
                    }
            })
            // If the Realm db is unable to be created, that's an unrecoverable error, so crashing the app is appropriate.
            // swiftlint:disable:next force_try
            let realm = try! Realm(configuration: config)
            return FavoriteStoreRealmImpl(realm: realm) as FavoriteStore
        }.scope(.application)
    }
}
