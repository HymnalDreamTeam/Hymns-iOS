import Combine
import FirebaseCrashlytics
import Foundation
import RealmSwift
import Resolver

protocol TagStore {
    func storeTag(_ tag: Tag)
    func storeTagEntity(_ tag: TagEntity)
    func deleteTag(_ tag: Tag)
    func getSongsByTag(_ tag: UiTag) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getTagsForHymn(hymnIdentifier: HymnIdentifier) -> AnyPublisher<[Tag], ErrorType>
    func getUniqueTags() -> AnyPublisher<[UiTag], ErrorType>
    func getAllTagEntities() -> AnyPublisher<[TagEntity], ErrorType>
    func clear() throws
}

class TagStoreRealmImpl: TagStore {

    private let firebaseLogger: FirebaseLogger
    private let realm: Realm

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), realm: Realm) {
        self.firebaseLogger = firebaseLogger
        self.realm = realm
    }

    func storeTag(_ tag: Tag) {
        do {
            try realm.write {
                realm.add(TagEntity(tagObject: tag, created: Date()), update: .modified)
            }
        } catch {
            firebaseLogger.logError(error, message: "error occurred when storing tag",
                                    extraParameters: ["primaryKey": tag.primaryKey])
        }
    }

    func storeTagEntity(_ tagEntity: TagEntity) {
        do {
            try realm.write {
                realm.add(tagEntity, update: .modified)
            }
        } catch {
            firebaseLogger.logError(error, message: "error occurred when storing tag",
                                    extraParameters: ["primaryKey": tagEntity.primaryKey])
        }
    }

    func deleteTag(_ tag: Tag) {
        let hymnIdentifier = HymnIdentifier(wrapper: tag.hymnIdentifier)
        let primaryKey = Tag.createPrimaryKey(hymnIdentifier: hymnIdentifier, tag: tag.tag, color: tag.color)
        let entitiesToDelete = realm.objects(TagEntity.self).filter(NSPredicate(format: "primaryKey == %@", primaryKey))
        do {
            try realm.write {
                realm.delete(entitiesToDelete)
            }
        } catch {
            firebaseLogger.logError(error, message: "error occurred when deleting tag", extraParameters: ["primaryKey": primaryKey])
        }
    }

    func clear() throws {
        try realm.write {
            realm.deleteAll()
        }
    }

    /** Can be used either with a value to specificially query for one tag or without the optional to query all tags*/
    func getSongsByTag(_ tag: UiTag) -> AnyPublisher<[SongResultEntity], ErrorType> {
        realm.objects(TagEntity.self)
            .filter(NSPredicate(format: "tagObject.tag == %@ AND tagObject.privateTagColor == %d", tag.title, tag.color.rawValue))
            .collectionPublisher
            .map { entities -> [SongResultEntity] in
                entities.map { entity -> SongResultEntity in
                    let hymnType = entity.tagObject.hymnIdentifier.hymnType
                    let hymnNumber = entity.tagObject.hymnIdentifier.hymnNumber
                    return SongResultEntity(hymnType: hymnType, hymnNumber: hymnNumber, title: entity.tagObject.songTitle)
                }
        }.mapError({ error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getTagsForHymn(hymnIdentifier: HymnIdentifier) -> AnyPublisher<[Tag], ErrorType> {
        realm.objects(TagEntity.self)
            .filter(NSPredicate(format: "primaryKey CONTAINS[c] %@", ("\(hymnIdentifier.hymnType):\(hymnIdentifier.hymnNumber)")))
            .sorted(byKeyPath: "created", ascending: false).collectionPublisher
            .map({ results -> [Tag] in
                results.map { entity -> Tag in
                    entity.tagObject
                }
            }).mapError({ error -> ErrorType in
                .data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
    }

    func getUniqueTags() -> AnyPublisher<[UiTag], ErrorType> {
        realm.objects(TagEntity.self).distinct(by: ["tagObject.tag", "tagObject.privateTagColor"]).collectionPublisher
            .map({ results -> [UiTag] in
                results.map { entity -> UiTag in
                    UiTag(title: entity.tagObject.tag, color: entity.tagObject.color)
                }
            }).mapError({ error -> ErrorType in
                .data(description: error.localizedDescription)
            }).eraseToAnyPublisher()
    }

    func getAllTagEntities() -> AnyPublisher<[TagEntity], ErrorType> {
        realm.objects(TagEntity.self)
            .collectionPublisher
            .map { entities -> [TagEntity] in
                entities.map { entity -> TagEntity in
                    entity
                }
        }.mapError({ error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }
}

extension Resolver {
    public static func registerTagStore() {
        register(TagStore.self) {
            // https://stackoverflow.com/questions/28465706/how-to-find-my-realm-file
            var url = Realm.Configuration.defaultConfiguration.fileURL
            url?.deleteLastPathComponent()
            url?.appendPathComponent("tags.realm")
            let config = Realm.Configuration(
                fileURL: url!,
                schemaVersion: 2,

                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // In version 1:
                    //   - hymnTypeRaw has been migrated from the enum value to the HymnType's abbreviated value
                    //   - Removed query parameters, so all songs with query params must be changed to its approprate 'simplified' hymn type
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: TagEntity.className()) { old, new in
                            let newHymnIdentifier = old.flatMap { oldEntity in
                                oldEntity["tagObject"] as? MigrationObject
                            }.flatMap { tag in
                                tag["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity -> HymnIdentifier? in
                                let hymnType = hymnIdentifierEntity["hymnTypeRaw"] as? Int
                                let hymnNumber = hymnIdentifierEntity["hymnNumber"] as? String
                                let queryParams = (hymnIdentifierEntity["queryParams"] as? String?)?.flatMap {$0}

                                guard let hymnType = hymnType,
                                      let hymnType = HymnType(rawValue: hymnType),
                                        let hymnNumber = hymnNumber else {
                                    Crashlytics.crashlytics().record(error: TagMigrationError(errorDescription: "Unable to migrate tags"),
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

                            let tag = old.flatMap { oldEntity in
                                oldEntity["tagObject"] as? MigrationObject
                            }.flatMap { tag in
                                tag["tag"] as? String
                            }

                            let tagColor = old.flatMap { oldEntity in
                                oldEntity["tagObject"] as? MigrationObject
                            }.flatMap { tag in
                                tag["privateTagColor"] as? Int
                            }

                            guard let newHymnIdentifier = newHymnIdentifier, let tag = tag, let tagColor = tagColor else {
                                return
                            }

                            let newPrimaryKey = "\(newHymnIdentifier.hymnType):\(newHymnIdentifier.hymnNumber):\(tag):\(tagColor)"
                            _ = new.flatMap { newEntity in
                                newEntity["primaryKey"] = newPrimaryKey
                                return newEntity["tagObject"] as? MigrationObject
                            }.flatMap { tag in
                                tag["primaryKey"] = newPrimaryKey
                                return tag["hymnIdentifierEntity"] as? MigrationObject
                            }.flatMap { hymnIdentifierEntity in
                                hymnIdentifierEntity["hymnTypeRaw"] = newHymnIdentifier.hymnType.abbreviatedValue
                                hymnIdentifierEntity["hymnNumber"] = newHymnIdentifier.hymnNumber
                                return hymnIdentifierEntity
                            }
                        }
                    }

                    // In version 2:
                    //   - HymnIdentifierEntity was migrated to use HymnIdentifierWrapper, since HymnIdentifierEntity became a
                    //     proto field, and thus not @objc-compatible.
                    if oldSchemaVersion < 2 {
                        migration.enumerateObjects(ofType: TagEntity.className()) { old, new in
                            guard let old = old, let new = new else {
                                Crashlytics.crashlytics()
                                    .record(error: TagMigrationError(errorDescription: "Unable to migrate tags because either old or new is nil"),
                                            userInfo: [
                                                "oldSchemaVersion": oldSchemaVersion,
                                                "old": old ?? "nil",
                                                "new": new ?? "nil"])
                                return
                            }
                            let hymnIdentifierWrapper = (old["tagObject"] as? MigrationObject).flatMap { tag in
                                tag["hymnIdentifierEntity"] as? MigrationObject
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
                                    .record(error: TagMigrationError(errorDescription: "Unable to migrate tags"),
                                                                 userInfo: [
                                                                    "oldSchemaVersion": oldSchemaVersion,
                                                                    "old": old, "new": new])
                                return
                            }
                            if let tagObject = new["tagObject"] as? MigrationObject {
                                tagObject["hymnIdentifier"] = hymnIdentifierWrapper
                            }
                        }
                    }
            })
            // If the Realm db is unable to be created, that's an unrecoverable error, so crashing the app is appropriate.
            // swiftlint:disable:next force_try
            let realm = try! Realm(configuration: config)
            return TagStoreRealmImpl(realm: realm) as TagStore
        }.scope(.application)
    }
}
