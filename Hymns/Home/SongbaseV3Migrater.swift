import Combine
import Foundation
import Resolver
import SwiftUI

/**
 * Goes through the songbase db and generates a diff report between that and the current Hymns
 * database.
 * </p>
 * This is needed due to a combination of factors: 1) Songbase, at some point, re-indexed all
 * their songs, so all the songs between songbasedb-v3 and the current Hymns database are
 * different. This messed up a lot of our favorites, recents, and tags, since they are keyed by
 * hymn type and hymn number. The way to solve this was to perform an exact match on the title and
 * try to infer the new hymn number. However... 2) There was a bug in iOS where tag titles weren't
 * being written, meaning we no longer have a title on which to perform the exact match.
 * </p>
 * Here, we are going through the entire songbase db and performing an exact match for every title
 * to see which songs out to be mapped to which song. Then, we will take the diff output and apply
 * it in the client, simplifying client logic.
 */
protocol SongbaseV3Migrater {
    func migrate() async
}

class SongbaseV3MigraterImpl: SongbaseV3Migrater {

    @AppStorage("favorites_migrated") var favoritesMigrated = false
    @AppStorage("tags_migrated") var tagsMigrated = false
    @AppStorage("history_migrated") var historyMigrated = false

    private let favoritesStore: FavoriteStore
    private let firebaseLogger: FirebaseLogger
    private let historyStore: HistoryStore
    private let mainQueue: DispatchQueue
    private let tagStore: TagStore

    private var migrateFavoritesTask: AnyCancellable?
    private var migrateHistoryTask: AnyCancellable?
    private var migrateTagsTask: AnyCancellable?

    init(favoritesStore: FavoriteStore = Resolver.resolve(),
         firebaseLogger: FirebaseLogger = Resolver.resolve(),
         historyStore: HistoryStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         tagStore: TagStore = Resolver.resolve()) {
        self.favoritesStore = favoritesStore
        self.firebaseLogger = firebaseLogger
        self.historyStore = historyStore
        self.mainQueue = mainQueue
        self.tagStore = tagStore
    }

    // swiftlint:disable cyclomatic_complexity
    func migrate() async {
        let changed = await readChangedMigrationFile()
        let dropped = await readDroppedMigrationFile()
        let unchanged = await readUnchangedMigrationFile()
        if !favoritesMigrated {
            mainQueue.async {
                self.migrateFavoritesTask = self.favoritesStore.favorites().map({ existings -> [FavoriteEntity]? in
                    if existings.isEmpty {
                        return nil
                    }
                    self.firebaseLogger.logLaunchTask(description: "Migrating \(existings.count) existing favorites: \(existings)")
                    return existings.compactMap { existing -> FavoriteEntity? in
                        // Only try to migrate songbase songs
                        if existing.hymnIdentifier.hymnType != .blueSongbook {
                            return existing.copy()
                        }
                        let songbaseNumber = existing.hymnIdentifier.hymnNumber
                        if dropped.contains(songbaseNumber) {
                            return nil
                        }
                        if let (newMapping, title) = changed[songbaseNumber] {
                            return FavoriteEntity(hymnIdentifier: newMapping, songTitle: title)
                        }
                        if unchanged.contains(songbaseNumber) {
                            return existing.copy()
                        }
                        self.firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Songbase \(existing) wasn't found in any mapping"))
                        return nil
                    }
                })
                .receive(on: self.mainQueue)
                .sink(receiveCompletion: { state in
                    switch state {
                    case .failure(let failure):
                        self.firebaseLogger.logError(failure, message: "Failed to migrate favorites")
                    case .finished:
                        break
                    }
                }, receiveValue: { news in
                    if let news = news {
                        self.firebaseLogger.logLaunchTask(description: "Migrated \(news.count) favorites: \(news)")

                        self.favoritesStore.clear()
                        news.forEach { new in
                            self.favoritesStore.storeFavorite(new)
                        }
                    }
                    // Cancel task this doesn't trigger again because of these updates, causing an infinite loop
                    self.migrateFavoritesTask?.cancel()
                    self.favoritesMigrated = true
                })
            }
        }

        if !historyMigrated {
            mainQueue.async {
                self.migrateHistoryTask = self.historyStore.recentSongs()
                    .map({ existings -> [RecentSong]? in
                        if existings.isEmpty {
                            return nil
                        }
                        self.firebaseLogger.logLaunchTask(description: "Migrating \(existings.count) existing recent songs: \(existings)")
                        return existings.compactMap { existing -> RecentSong? in
                            // Only try to migrate songbase songs
                            if existing.hymnIdentifier.hymnType != .blueSongbook {
                                return existing.copy()
                            }
                            let songbaseNumber = existing.hymnIdentifier.hymnNumber
                            if dropped.contains(songbaseNumber) {
                                return nil
                            }
                            if let (newMapping, title) = changed[songbaseNumber] {
                                return RecentSong(hymnIdentifier: newMapping, songTitle: title)
                            }
                            if unchanged.contains(songbaseNumber) {
                                return existing.copy()
                            }
                            self.firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Songbase \(existing) wasn't found in any mapping"))
                            return nil
                        }
                    })
                    .receive(on: self.mainQueue)
                    .sink(receiveCompletion: { state in
                        switch state {
                        case .failure(let failure):
                            self.firebaseLogger.logError(failure, message: "Failed to migrate recent songs")
                        case .finished:
                            break
                        }
                    }, receiveValue: { news in
                        if let news = news {
                            self.firebaseLogger.logLaunchTask(description: "Migrated \(news.count) recent songs: \(news)")

                            do {
                                try self.historyStore.clearHistory()
                                news.forEach { new in
                                    self.historyStore.storeRecentSong(hymnToStore: new.hymnIdentifier.hymnIdentifier,
                                                                      songTitle: new.songTitle)
                                }
                            } catch {
                                self.firebaseLogger.logError(error, message: "Failed to clear history")
                            }
                        }
                        // Cancel task this doesn't trigger again because of these updates, causing an infinite loop
                        self.migrateHistoryTask?.cancel()
                        self.historyMigrated = true
                    })
            }
        }

        if !tagsMigrated {
            mainQueue.async {
                self.migrateTagsTask = self.tagStore.getAllTagEntities().map({ existings -> [TagEntity]? in
                    if existings.isEmpty {
                        return nil
                    }
                    self.firebaseLogger.logLaunchTask(description: "Migrating \(existings.count) existing tags: \(existings)")
                    return existings.compactMap { existing -> TagEntity? in
                        // Only try to migrate songbase songs
                        if existing.tagObject.hymnIdentifier.hymnType != .blueSongbook {
                            return existing.copy()
                        }
                        let songbaseNumber = existing.tagObject.hymnIdentifier.hymnNumber
                        if dropped.contains(songbaseNumber) {
                            return nil
                        }
                        if let (newMapping, title) = changed[songbaseNumber] {
                            return TagEntity(tagObject: Tag(hymnIdentifier: newMapping, songTitle: title,
                                                            tag: existing.tagObject.tag, color: existing.tagObject.color),
                                             created: existing.created)
                        }
                        if unchanged.contains(songbaseNumber) {
                            return existing.copy()
                        }
                        self.firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Songbase \(existing) wasn't found in any mapping"))
                        return nil
                    }
                })
                .receive(on: self.mainQueue)
                .sink(receiveCompletion: { state in
                    switch state {
                    case .failure(let failure):
                        self.firebaseLogger.logError(failure, message: "Failed to migrate tags")
                    case .finished:
                        break
                    }
                }, receiveValue: { news in
                    if let news = news {
                        self.firebaseLogger.logLaunchTask(description: "Migrated \(news.count) tags: \(news)")

                        do {
                            try self.tagStore.clear()
                            news.forEach { new in
                                self.tagStore.storeTagEntity(new)
                            }
                        } catch {
                            self.firebaseLogger.logError(error, message: "Failed to clear tags")
                        }
                    }
                    // Cancel task this doesn't trigger again because of these updates, causing an infinite loop
                    self.migrateTagsTask?.cancel()
                    self.tagsMigrated = true
                })
            }
        }
    }

    private func readChangedMigrationFile() async -> [String: (reference: HymnIdentifier, title: String)] {
        guard let migrationFile = Bundle.main.path(forResource: "songbase_v3_migration_changed", ofType: "txt") else {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Changed migration file does not exist"))
            return [String: (reference: HymnIdentifier, title: String)]()
        }
        do {
            let migrations = try String.init(contentsOfFile: migrationFile)
            return Dictionary(uniqueKeysWithValues: migrations.split(separator: "\n")
                .compactMap { migration -> (String, (reference: HymnIdentifier, title: String))? in
                    let components = migration.split(separator: "|")
                    let songbaseNumber = String(components[0])
                    let replacementType = HymnType.fromAbbreviatedValue(String(components[1]))
                    guard let replacementType = replacementType else {
                        firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Changed migration file contained an invalid replacement type"))
                        return nil
                    }
                    let hymnIdentifier = HymnIdentifier(hymnType: replacementType, hymnNumber: String(components[2]))
                    let title = String(components[3])
                    return (songbaseNumber, (reference: hymnIdentifier, title: title))
                })
        } catch {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Changed migration file was malformed"))
            return [String: (reference: HymnIdentifier, title: String)]()
        }
    }

    private func readDroppedMigrationFile() async -> [String] {
        guard let migrationFile = Bundle.main.path(forResource: "songbase_v3_migration_dropped", ofType: "txt") else {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Dropped migration file does not exist"))
            return [String]()
        }
        do {
            return try String.init(contentsOfFile: migrationFile).split(separator: "\n").map { String($0) }
        } catch {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Dropped migration file was malformed"))
            return [String]()
        }
    }

    private func readUnchangedMigrationFile() async -> [String] {
        guard let migrationFile = Bundle.main.path(forResource: "songbase_v3_migration_unchanged", ofType: "txt") else {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Unchanged migration file does not exist"))
            return [String]()
        }
        do {
            return try String.init(contentsOfFile: migrationFile).split(separator: "\n").map { String($0) }
        } catch {
            firebaseLogger.logError(SongbaseMigrationError(errorDescription: "Unchanged migration file was malformed"))
            return [String]()
        }
    }
}
