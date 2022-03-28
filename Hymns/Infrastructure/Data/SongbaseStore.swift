import Combine
import FirebaseCrashlytics
import Foundation
import GRDB
import GRDBCombine
import Resolver

/**
 * Service to contact the local Songbase data.
 */
protocol SongbaseStore {

    /**
     * Whether or not the database has been initialized properly. If this value is false, then the database is **NOT** safe to use and clients should avoid using it.
     */
    var databaseInitializedProperly: Bool { get }
    func getHymn(bookId: Int, bookIndex: Int) -> AnyPublisher<SongbaseSong?, ErrorType>
    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SongbaseSearchResultEntity], ErrorType>
    func getAllSongs() -> AnyPublisher<[SongbaseResultEntity], ErrorType>
}

/**
 * Implementation of `SongbaseStore` that uses `GRDB`.
 */
class SongbaseStoreGrdbImpl: SongbaseStore {

    private(set) var databaseInitializedProperly = true

    private let analytics: AnalyticsLogger
    private let databaseQueue: DatabaseQueue

    /**
     * Initializes the `HymnDataStoreGrdbImpl` object.
     *
     * - Parameter analyticsLogger: Used for logging analytics and non-fatal errors
     * - Parameter databaseQueue: `DatabaseQueue` object to use to make sql queries to
     * - Parameter initializeTables: Whether or not to create the necessary tables on startup
     */
    init(analytics: AnalyticsLogger = Resolver.resolve(), databaseQueue: DatabaseQueue, initializeTables: Bool = false) {
        self.analytics = analytics
        self.databaseQueue = databaseQueue
        if initializeTables {
            databaseQueue.inDatabase { database in
                do {
                    // CREATE TABLE IF NOT EXISTS songs(
                    //   book_id INTEGER NOT NULL,
                    //   book_index INTEGER NOT NULL,
                    //   title TEXT NOT NULL,
                    //   language TEXT NOT NULL,
                    //   lyrics TEXT NOT NULL,
                    //   chords TEXT NOT NULL,
                    //   PRIMARY KEY(book_id, book_index)
                    // )
                    try database.create(table: "songs", ifNotExists: true) { table in
                        table.column("book_id", .integer).notNull()
                        table.column("book_index", .integer).notNull()
                        table.column("title", .text).notNull()
                        table.column("language", .text).notNull()
                        table.column("lyrics", .text).notNull()
                        table.column("chords", .text).notNull()
                        table.primaryKey(["book_id", "book_index"])
                    }
                    // CREATE TABLE IF NOT EXISTS books(
                    //   id INTEGER NOT NULL,
                    //   name TEXT NOT NULL,
                    //   language TEXT NOT NULL,
                    //   identifier TEXT NOT NULL,
                    //   PRIMARY KEY(id)
                    // )
                    try database.create(table: "books", ifNotExists: true) { table in
                        table.column("id", .integer).notNull()
                        table.column("name", .text).notNull()
                        table.column("language", .text).notNull()
                        table.column("identifier", .text).notNull()
                        table.primaryKey(["id"])
                    }

                    // CREATE TABLE IF NOT EXISTS destroyed(
                    //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    //   type TEXT,
                    //   destroyed TEXT
                    // )
                    try database.create(table: "destroyed", ifNotExists: true) { table in
                        table.autoIncrementedPrimaryKey("id")
                        table.column("type", .text)
                        table.column("destroyed", .text)
                    }

                    // CREATE VIRTUAL TABLE IF NOT EXISTS songs_virtual USING FTS4(
                    //   title TEXT NOT NULL,
                    //   lyrics TEXT NOT NULL,
                    //   tokenize=porter, content=songs
                    // )
                    try database.create(virtualTable: "songs_virtual", ifNotExists: true, using: FTS4()) { table in
                        table.synchronize(withTable: "songs")
                        table.tokenizer = .porter
                        table.column("title")
                        table.column("lyrics")
                    }
                } catch {
                    databaseInitializedProperly = false
                    Crashlytics.crashlytics().log("Failed to create tables for songbase")
                    Crashlytics.crashlytics().setCustomValue("corrupted db", forKey: "songbase_state")
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }

    func getHymn(bookId: Int, bookIndex: Int) -> AnyPublisher<SongbaseSong?, ErrorType> {
        return databaseQueue.readPublisher { database in
            try SongbaseSong.fetchOne(database,
                                      sql: "SELECT * FROM songs WHERE book_id = ? AND book_index = ?",
                                      arguments: [bookId, bookIndex])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).map({entity -> SongbaseSong? in
            return entity
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SongbaseSearchResultEntity], ErrorType> {
        let pattern = FTS3Pattern(matchingAllTokensIn: searchParameter)

        /*
         For each column, the length of the longest subsequence of phrase matches that the column value has in common with
         the query text. For example, if a table column contains the text 'a b c d e' and the query is 'a c "d e"', then
         the length of the longest common subsequence is 2 (phrase "c" followed by phrase "d e").
         https://sqlite.org/fts3.html#matchinfo
         */
        return databaseQueue.readPublisher { database in
            try SongbaseSearchResultEntity.fetchAll(database,
                                                    sql: "SELECT book_id, book_index, songs.title, matchinfo(songs_virtual, 's') FROM songs JOIN songs_virtual ON (songs_virtual.docid = songs.rowid) WHERE book_id = 1 AND songs_virtual MATCH ?",
                                                    arguments: [pattern])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getAllSongs() -> AnyPublisher<[SongbaseResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongbaseResultEntity.fetchAll(database,
                                              sql: "SELECT book_id, book_index, title FROM songs WHERE book_id = ?",
                                              arguments: ["1"])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }
}

extension Resolver {

    /**
     * Creates the hymn database and attempt to copy over the bundled database with fallbacks:
     *   1) Try to import bundled database. If that fails...
     *   2) Create a new database file and initialize it with empty tables. If that fails...
     *   3) Create an in-memory database and initialize it with empty tables. And if all fails...
     *   4) Indicate that the database isn't initialized correctly so that other classes will know to not use it
     *
     *   NOTE: These fallbacks need to be tested manually, as there is no way to mock/stub these file system interactions.
     */
    public static func registerSongbaseStore() {
        register(SongbaseStore.self) {
            let fileManager = FileManager.default
            guard let dbPath =
                try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("songbasedb-v2.sqlite")
                    .path else {
                        Crashlytics.crashlytics().log("The desired path in Application Support is nil, so we are unable to create a database file. Fall back to useing an in-memory db and initialize it with empty tables")
                        Crashlytics.crashlytics().setCustomValue("in-memory db", forKey: "songbase_state")
                        Crashlytics.crashlytics().record(error: NSError(domain: "Database Initialization Error", code: NonFatalEvent.ErrorCode.databaseInitialization.rawValue))
                        return SongbaseStoreGrdbImpl(databaseQueue: DatabaseQueue(), initializeTables: true) as SongbaseStoreGrdbImpl
            }

            /// Whether or not we need to create the tables for the database.
            var needToCreateTables: Bool = false
            outer: do {
                // Need to copy the bundled database into the Application Support directory on order for GRDB to access it
                // https://github.com/groue/GRDB.swift#how-do-i-open-a-database-stored-as-a-resource-of-my-application
                if !fileManager.fileExists(atPath: dbPath) {
                    guard let bundledDbPath = Bundle.main.path(forResource: "songbasedb-v2", ofType: "sqlite") else {
                        Crashlytics.crashlytics().log("Path to the bundled database was not found, so just create an empty database instead and initialize it with empty tables")
                        Crashlytics.crashlytics().setCustomValue("empty persistent db", forKey: "songbase_state")
                        Crashlytics.crashlytics().record(error: NSError(domain: "Database Initialization Error", code: NonFatalEvent.ErrorCode.databaseInitialization.rawValue))
                        needToCreateTables = true
                        break outer
                    }
                    try fileManager.copyItem(atPath: bundledDbPath, toPath: dbPath)
                    needToCreateTables = false
                    Crashlytics.crashlytics().log("Database successfully copied from bundled SQLite file")
                    Crashlytics.crashlytics().setCustomValue("bundled db", forKey: "songbase_state")
                }
            } catch {
                Crashlytics.crashlytics().log("Unable to copy bundled data to the Application Support directly, so just create an empty database there instead and initialize it with empty tables")
                Crashlytics.crashlytics().setCustomValue("empty persistent db", forKey: "songbase_state")
                Crashlytics.crashlytics().record(error: error)
                needToCreateTables = true
            }

            let databaseQueue: DatabaseQueue
            do {
                databaseQueue = try DatabaseQueue(path: dbPath)
            } catch {
                Crashlytics.crashlytics().log("Unable to create database queue at the desired path, so create an in-memory one and initialize it with empty tables as a fallback")
                Crashlytics.crashlytics().setCustomValue("in-memory db", forKey: "songbase_state")
                Crashlytics.crashlytics().record(error: error)
                databaseQueue = DatabaseQueue()
                needToCreateTables = true
            }
            return SongbaseStoreGrdbImpl(databaseQueue: databaseQueue, initializeTables: needToCreateTables) as SongbaseStore
        }.scope(.application)
    }
}
