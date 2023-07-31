import Combine
import FirebaseCrashlytics
import Foundation
import RealmSwift
import Resolver

protocol FavoriteStore {
    func storeFavorite(_ entity: FavoriteEntity)
    func deleteFavorite(primaryKey: String)
    func clear()
    func favoritesSync() -> Results<FavoriteEntity>
    func favorites() -> AnyPublisher<[FavoriteEntity], ErrorType>
    func isFavorite(hymnIdentifier: HymnIdentifier) -> AnyPublisher<Bool, ErrorType>
}

class FavoriteStoreRealmImpl: FavoriteStore {

    private let firebaseLogger: FirebaseLogger
    private let realm: Realm

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), realm: Realm) {
        self.firebaseLogger = firebaseLogger
        self.realm = realm
    }

    func storeFavorite(_ entity: FavoriteEntity) {
        do {
            try realm.write {
                realm.add(entity, update: .modified)
            }
        } catch {
            firebaseLogger.logError(error, message: "error orccured when storing favorite", extraParameters: ["primaryKey": entity.primaryKey])
        }
    }

    func deleteFavorite(primaryKey: String) {
        guard let entityToDelete = realm.object(ofType: FavoriteEntity.self, forPrimaryKey: primaryKey) else {
            firebaseLogger.logError(FavoriteDeletionError(errorDescription: "tried to delete a favorite that doesn't exist"),
                                    extraParameters: ["primaryKey": primaryKey])
            return
        }

        do {
            try realm.write {
                realm.delete(entityToDelete)
            }
        } catch {
            firebaseLogger.logError(error, message: "error orccured when deleting favorite",
                                    extraParameters: ["primaryKey": primaryKey])
        }
    }

    func clear() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            firebaseLogger.logError(error, message: "error orccured when clearing favorites table")
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

    func favoritesSync() -> Results<FavoriteEntity> {
        realm.objects(FavoriteEntity.self)
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
                    // In version 1:
                    //   - hymnTypeRaw has been migrated from the enum value to the HymnType's abbreviated value
                    //   - Removed query parameters, so all songs with query params must be changed to its approprate 'simplified' hymn type
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: FavoriteEntity.className()) { old, new in
                            let newHymnIdentifier = old.flatMap { oldEntity in
                                oldEntity["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity -> HymnIdentifier? in
                                let hymnType = hymnIdentifierEntity["hymnTypeRaw"] as? Int
                                let hymnNumber = hymnIdentifierEntity["hymnNumber"] as? String
                                let queryParams = (hymnIdentifierEntity["queryParams"] as? String?)?.flatMap {$0}

                                guard let hymnType = hymnType,
                                      let hymnType = HymnType(rawValue: hymnType),
                                        let hymnNumber = hymnNumber else {
                                    Crashlytics.crashlytics().record(error: FavoritesMigrationError(errorDescription: "Unable to migrate favorites"),
                                                                     userInfo: [
                                                                        "oldSchemaVersion": oldSchemaVersion,
                                                                        "hymnIdentifierEntity": hymnIdentifierEntity])
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
                            _ = new.flatMap { newEntity in
                                newEntity["primaryKey"] = newPrimaryKey
                                return newEntity["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity in
                                hymnIdentifierEntity["hymnTypeRaw"] = newHymnIdentifier.hymnType.abbreviatedValue
                                hymnIdentifierEntity["hymnNumber"] = newHymnIdentifier.hymnNumber
                                return hymnIdentifierEntity
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
