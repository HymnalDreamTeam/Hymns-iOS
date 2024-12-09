import Combine
import FirebaseCrashlytics
import Foundation
import RealmSwift
import Resolver

protocol HistoryStore {
    func clearHistory() throws
    func recentSongs() -> AnyPublisher<[RecentSong], ErrorType>
    func storeRecentSong(hymnToStore hymnIdentifier: HymnIdentifier, songTitle: String?)
}

class HistoryStoreRealmImpl: HistoryStore {

    /**
     * Once the number of entries hits this threshold, start replacing the entries.
     */
    let numberToStore = 50

    private let firebaseLogger: FirebaseLogger
    private let realm: Realm

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), realm: Realm) {
        self.firebaseLogger = firebaseLogger
        self.realm = realm
    }

    /**
     * Gets a list of `RecentSong`s. but if the list is greater than `numberToStore`, then it will delete the excess `RecentSong`s from the database.
     */
    func recentSongs() -> AnyPublisher<[RecentSong], ErrorType> {
        realm.objects(RecentSongEntity.self).sorted(byKeyPath: "created", ascending: false).collectionPublisher
            .map({ results -> [RecentSong] in
                results.map { entity -> RecentSong in
                    entity.recentSong
                }
            }).mapError({ error -> ErrorType in
                .data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
    }

    func storeRecentSong(hymnToStore hymnIdentifier: HymnIdentifier, songTitle: String?) {
        do {
            try realm.write {
                realm.add(
                    RecentSongEntity(recentSong:
                        RecentSong(hymnIdentifier: hymnIdentifier, songTitle: songTitle),
                                     created: Date()),
                    update: .modified)
            }
            let results: Results<RecentSongEntity> = realm.objects(RecentSongEntity.self).sorted(byKeyPath: "created", ascending: false)
            if results.count > numberToStore {
                let entitiesToDelete = Array(results).suffix(results.count - numberToStore)
                do {
                    try realm.write {
                        realm.delete(entitiesToDelete)
                    }
                } catch {
                    var extraParameters = [String: String]()
                    for (index, entity) in entitiesToDelete.enumerated() {
                        extraParameters["primary_key \(index)"] = entity.primaryKey
                    }
                    firebaseLogger.logError(error, message: "error occurred when deleting recent songs", extraParameters: extraParameters)
                }
            }
        } catch {
            firebaseLogger.logError(error, message: "error occurred when storing recent song",
                                    extraParameters: ["hymnIdentifier": String(describing: hymnIdentifier), "title": songTitle ?? "nil"])
        }
    }

    func clearHistory() throws {
        try realm.write {
            self.realm.deleteAll()
        }
    }
}

extension Resolver {
    // swiftlint:disable:next cyclomatic_complexity
    public static func registerHistoryStore() {
        register(HistoryStore.self) {
            // https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file
            var url = Realm.Configuration.defaultConfiguration.fileURL
            url?.deleteLastPathComponent()
            url?.appendPathComponent("history.realm")
            let config = Realm.Configuration(
                fileURL: url!,
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 3,

                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // Certain songs are in the format 'Hymn 12: O God, Thou art the source of life'.
                    // However, since we are adding labels to recent songs, we should remove the initial
                    // 'Hymn 12: ' so it's not redundant.
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: RecentSongEntity.className()) { old, new in
                            let newTitle = old.flatMap { oldEntity in
                                oldEntity["recentSong"] as? MigrationObject
                            }.flatMap { recentSong in
                                recentSong["songTitle"] as? String
                            }.flatMap { songTitle in
                                songTitle.replacingOccurrences(of: #"\Hymn.*: "#, with: "", options: .regularExpression, range: nil)
                            }

                            guard let newTitle = newTitle else {
                                return
                            }

                            _ = new.flatMap { newEntity in
                                newEntity["recentSong"] as? MigrationObject
                            }.flatMap { recentSong in
                                recentSong["songTitle"] = newTitle
                                return recentSong
                            }
                        }
                    }

                    // In version 2:
                    //   - hymnTypeRaw has been migrated from the enum value to the HymnType's abbreviated value
                    //   - Removed query parameters, so all songs with query params must be changed to its approprate 'simplified' hymn type
                    if oldSchemaVersion < 2 {
                        migration.enumerateObjects(ofType: RecentSongEntity.className()) { old, new in
                            let newHymnIdentifier = old.flatMap { oldEntity in
                                oldEntity["recentSong"] as? MigrationObject
                            }.flatMap { recentSong in
                                recentSong["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity -> HymnIdentifier? in
                                let hymnType = hymnIdentifierEntity["hymnTypeRaw"] as? Int
                                let hymnNumber = hymnIdentifierEntity["hymnNumber"] as? String
                                let queryParams = (hymnIdentifierEntity["queryParams"] as? String?)?.flatMap {$0}

                                guard let hymnType = hymnType,
                                      let hymnType = HymnType(rawValue: hymnType),
                                        let hymnNumber = hymnNumber else {
                                    Crashlytics.crashlytics().record(error: HistoryMigrationError(errorDescription: "Unable to migrate history"),
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
                                return newEntity["recentSong"] as? MigrationObject
                            }.flatMap { recentSong in
                                recentSong["primaryKey"] = newPrimaryKey
                                return recentSong["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity in
                                hymnIdentifierEntity["hymnTypeRaw"] = newHymnIdentifier.hymnType.abbreviatedValue
                                hymnIdentifierEntity["hymnNumber"] = newHymnIdentifier.hymnNumber
                                return hymnIdentifierEntity
                            }
                        }
                    }

                    // In version 3:
                    //   - HymnIdentifierEntity was migrated to use HymnIdentifierWrapper, since HymnIdentifierEntity became a
                    //     proto field, and thus not @objc-compatible.
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: RecentSongEntity.className()) { old, new in
                            guard let old = old, let new = new else {
                                Crashlytics.crashlytics()
                                    .record(error: HistoryMigrationError(errorDescription: "Unable to migrate history because either old or new is nil"),
                                            userInfo: [
                                                "oldSchemaVersion": oldSchemaVersion,
                                                "old": old ?? "nil",
                                                "new": new ?? "nil"])
                                return
                            }
                            let hymnIdentifierWrapper = (old["recentSong"] as? MigrationObject).flatMap { recentSong in
                                recentSong["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity -> HymnIdentifier? in
                                let hymnType = hymnIdentifierEntity["hymnTypeRaw"] as? String
                                let hymnNumber = hymnIdentifierEntity["hymnNumber"] as? String

                                guard let hymnType = hymnType,
                                      let hymnType = HymnType.fromAbbreviatedValue(hymnType),
                                      let hymnNumber = hymnNumber else {
                                    return nil
                                }
                                return HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
                            }.map { hymnIdentifier -> HymnIdentifierWrapper in
                                HymnIdentifierWrapper(hymnIdentifier)
                            }
                            guard let hymnIdentifierWrapper = hymnIdentifierWrapper else {
                                Crashlytics.crashlytics()
                                    .record(error: HistoryMigrationError(errorDescription: "Unable to migrate history"),
                                            userInfo: [
                                                "oldSchemaVersion": oldSchemaVersion,
                                                "old": old, "new": new])
                                return
                            }
                            if let recentSong = new["recentSong"] as? MigrationObject {
                                recentSong["hymnIdentifier"] = hymnIdentifierWrapper
                            }
                        }
                    }
                })
            // If the Realm db is unable to be created, that's an unrecoverable error, so crashing the app is appropriate.
            // swiftlint:disable:next force_try
            let realm = try! Realm(configuration: config)
            return HistoryStoreRealmImpl(realm: realm) as HistoryStore
        }.scope(.application)
    }
}
