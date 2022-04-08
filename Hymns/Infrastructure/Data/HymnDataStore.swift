import Combine
import FirebaseCrashlytics
import Foundation
import GRDB
import GRDBCombine
import Resolver

/**
 * Service to contact the local Hymn database.
 */
protocol HymnDataStore {

    /**
     * Whether or not the database has been initialized properly. If this value is false, then the database is **NOT** safe to use and clients should avoid using it.
     */
    var databaseInitializedProperly: Bool { get }

    func saveHymn(_ entity: HymnEntity)
    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnEntity?, ErrorType>
    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SearchResultEntity], ErrorType>
    func getAllCategories() -> AnyPublisher<[CategoryEntity], ErrorType>
    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType>
    func getResultsBy(category: String, hymnType: HymnType?, subcategory: String?) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getScriptureSongs() -> AnyPublisher<[ScriptureEntity], ErrorType>
    func getAllSongs(hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
}

/**
 * Implementation of `HymnDataStore` that uses `GRDB`.
 */
class HymnDataStoreGrdbImpl: HymnDataStore {

    let tableName = "SONG_DATA"

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
                    // CREATE TABLE SONG_DATA(
                    //   ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    //   HYMN_TYPE TEXT NOT NULL,
                    //   HYMN_NUMBER TEXT NOT NULL,
                    //   QUERY_PARAMS TEXT NOT NULL,
                    //   SONG_TITLE TEXT NOT NULL,
                    //   SONG_LYRICS TEXT,
                    //   SONG_META_DATA_CATEGORY TEXT,
                    //   SONG_META_DATA_SUBCATEGORY TEXT,
                    //   SONG_META_DATA_AUTHOR TEXT,
                    //   SONG_META_DATA_COMPOSER TEXT,
                    //   SONG_META_DATA_KEY TEXT,
                    //   SONG_META_DATA_TIME TEXT,
                    //   SONG_META_DATA_METER TEXT,
                    //   SONG_META_DATA_SCRIPTURES TEXT,
                    //   SONG_META_DATA_HYMN_CODE TEXT,
                    //   SONG_META_DATA_MUSIC TEXT,
                    //   SONG_META_DATA_SVG_SHEET_MUSIC TEXT,
                    //   SONG_META_DATA_PDF_SHEET_MUSIC TEXT,
                    //   SONG_META_DATA_LANGUAGES TEXT,
                    //   SONG_META_DATA_RELEVANT TEXT
                    // )
                    try database.create(table: tableName, ifNotExists: true) { table in
                        table.autoIncrementedPrimaryKey(HymnEntity.CodingKeys.id.rawValue)
                        table.column(HymnEntity.CodingKeys.hymnType.rawValue, .text).notNull()
                        table.column(HymnEntity.CodingKeys.hymnNumber.rawValue, .text).notNull()
                        table.column(HymnEntity.CodingKeys.queryParams.rawValue, .text).notNull()
                        table.column(HymnEntity.CodingKeys.title.rawValue, .text).notNull()
                        table.column(HymnEntity.CodingKeys.lyricsJson.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.category.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.subcategory.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.author.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.composer.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.key.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.time.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.meter.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.scriptures.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.hymnCode.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.musicJson.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.svgSheetJson.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.pdfSheetJson.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.languagesJson.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.relevantJson.rawValue, .text)
                    }

                    // CREATE UNIQUE INDEX IF NOT EXISTS index_SONG_DATA_HYMN_TYPE_HYMN_NUMBER_QUERY_PARAMS ON SONG_DATA (HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS)
                    try database.create(index: "index_SONG_DATA_HYMN_TYPE_HYMN_NUMBER_QUERY_PARAMS",
                                        on: tableName,
                                        columns: [HymnEntity.CodingKeys.hymnType.rawValue, HymnEntity.CodingKeys.hymnNumber.rawValue, HymnEntity.CodingKeys.queryParams.rawValue],
                                        unique: true,
                                        ifNotExists: true)

                    // CREATE INDEX IF NOT EXISTS index_SONG_DATA_ID ON SONG_DATA (ID)
                    try database.create(index: "index_SONG_DATA_ID",
                                        on: tableName,
                                        columns: [HymnEntity.CodingKeys.id.rawValue],
                                        unique: false,
                                        ifNotExists: true)

                    // CREATE VIRTUAL TABLE IF NOT EXISTS SEARCH_VIRTUAL_SONG_DATA USING FTS4(
                    //   SONG_TITLE TEXT NOT NULL,
                    //   SONG_LYRICS TEXT NOT NULL,
                    //   tokenize=porter,
                    //   content=SONG_DATA
                    // )
                    try database.create(virtualTable: "SEARCH_VIRTUAL_SONG_DATA", ifNotExists: true, using: FTS4()) { table in
                        table.synchronize(withTable: self.tableName)
                        table.tokenizer = .porter
                        table.column(HymnEntity.CodingKeys.title.rawValue)
                        table.column(HymnEntity.CodingKeys.lyricsJson.rawValue)
                    }
                } catch {
                    databaseInitializedProperly = false
                    Crashlytics.crashlytics().log("Failed to create tables for data store")
                    Crashlytics.crashlytics().setCustomValue("corrupted db", forKey: "database_state")
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }

    func saveHymn(_ entity: HymnEntity) {
        do {
            try self.databaseQueue.inDatabase { database in
                try entity.insert(database)
            }
        } catch {
            analytics.logError(message: "Save entity failed", error: error, extraParameters: ["hymnType": entity.hymnType, "hymnNumber": entity.hymnNumber, "queryParams": entity.queryParams])
        }
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnEntity?, ErrorType> {
        let hymnType = hymnIdentifier.hymnType.abbreviatedValue
        let hymnNumber = hymnIdentifier.hymnNumber
        let queryParams = hymnIdentifier.queryParamString

        return databaseQueue.readPublisher { database in
            try HymnEntity.fetchOne(database,
                                    sql: "SELECT * FROM SONG_DATA WHERE HYMN_TYPE = ? AND HYMN_NUMBER = ? AND QUERY_PARAMS = ?",
                                    arguments: [hymnType, hymnNumber, queryParams])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).map({entity -> HymnEntity? in
            return entity
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SearchResultEntity], ErrorType> {
        let pattern = FTS3Pattern(matchingAllTokensIn: searchParameter)

        /*
         For each column, the length of the longest subsequence of phrase matches that the column value has in common with
         the query text. For example, if a table column contains the text 'a b c d e' and the query is 'a c "d e"', then
         the length of the longest common subsequence is 2 (phrase "c" followed by phrase "d e").
         https://sqlite.org/fts3.html#matchinfo
         */
        return databaseQueue.readPublisher { database in
            try SearchResultEntity.fetchAll(database,
                                            sql: "SELECT SONG_DATA.SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS, matchinfo(SEARCH_VIRTUAL_SONG_DATA, 's') FROM SONG_DATA JOIN SEARCH_VIRTUAL_SONG_DATA ON (SEARCH_VIRTUAL_SONG_DATA.docid = SONG_DATA.rowid) WHERE SEARCH_VIRTUAL_SONG_DATA MATCH ?",
                                            arguments: [pattern])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getAllCategories() -> AnyPublisher<[CategoryEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try CategoryEntity.fetchAll(database,
                                        sql: "SELECT DISTINCT SONG_META_DATA_CATEGORY, SONG_META_DATA_SUBCATEGORY, COUNT(1) FROM SONG_DATA WHERE SONG_META_DATA_CATEGORY IS NOT NULL AND SONG_META_DATA_SUBCATEGORY IS NOT NULL GROUP BY 1, 2")
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try CategoryEntity.fetchAll(database,
                                        sql: "SELECT DISTINCT SONG_META_DATA_CATEGORY, SONG_META_DATA_SUBCATEGORY, COUNT(1) FROM SONG_DATA WHERE SONG_META_DATA_CATEGORY IS NOT NULL AND SONG_META_DATA_SUBCATEGORY IS NOT NULL AND HYMN_TYPE = ? GROUP BY 1, 2",
                                        arguments: [hymnType.abbreviatedValue])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, hymnType: HymnType?, subcategory: String?) -> AnyPublisher<[SongResultEntity], ErrorType> {
        let publisher: AnyPublisher<[SongResultEntity], Error>

        if let hymnType = hymnType, let subcategory = subcategory {
            // Both hymn type and subcategory are not nil
            publisher = databaseQueue.readPublisher { database in
                try SongResultEntity.fetchAll(database,
                                              sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE HYMN_TYPE = ? AND SONG_META_DATA_CATEGORY = ? AND SONG_META_DATA_SUBCATEGORY = ?",
                                              arguments: [hymnType.abbreviatedValue, category, subcategory])
            }
        } else if let hymnType = hymnType {
            // hymn type is not nil but subcategory is nil
            publisher = databaseQueue.readPublisher { database in
                try SongResultEntity.fetchAll(database,
                                              sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE HYMN_TYPE = ? AND SONG_META_DATA_CATEGORY = ?",
                                              arguments: [hymnType.abbreviatedValue, category])
            }
        } else if let subcategory = subcategory {
            // hymn type is nil but subcategory is not nil
            publisher = databaseQueue.readPublisher { database in
                try SongResultEntity.fetchAll(database,
                                              sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE SONG_META_DATA_CATEGORY = ? AND SONG_META_DATA_SUBCATEGORY = ?",
                                              arguments: [category, subcategory])
            }
        } else {
            // both hymn type and subcategory are nil
            publisher = databaseQueue.readPublisher { database in
                try SongResultEntity.fetchAll(database,
                                              sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE SONG_META_DATA_CATEGORY = ?",
                                              arguments: [category])
            }
        }
        return publisher.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(database,
                                          sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE SONG_META_DATA_HYMN_CODE LIKE '%' || ? || '%'",
                                          arguments: [hymnCode])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getScriptureSongs() -> AnyPublisher<[ScriptureEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try ScriptureEntity.fetchAll(database, sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS, SONG_META_DATA_SCRIPTURES FROM SONG_DATA WHERE SONG_META_DATA_SCRIPTURES IS NOT NULL AND SONG_TITLE IS NOT NULL")
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getAllSongs(hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(database,
                                          sql: "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, QUERY_PARAMS FROM SONG_DATA WHERE HYMN_TYPE = ?",
                                          arguments: [hymnType.abbreviatedValue])
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
    public static func registerHymnDataStore() {
        register(HymnDataStore.self) {
            let fileManager = FileManager.default
            guard let dbPath =
                try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("hymnaldb-v19.sqlite")
                    .path else {
                        Crashlytics.crashlytics().log("The desired path in Application Support is nil, so we are unable to create a database file. Fall back to useing an in-memory db and initialize it with empty tables")
                        Crashlytics.crashlytics().setCustomValue("in-memory db", forKey: "database_state")
                        Crashlytics.crashlytics().record(error: NSError(domain: "Database Initialization Error", code: NonFatalEvent.ErrorCode.databaseInitialization.rawValue))
                        return HymnDataStoreGrdbImpl(databaseQueue: DatabaseQueue(), initializeTables: true) as HymnDataStore
            }

            /// Whether or not we need to create the tables for the database.
            var needToCreateTables: Bool = false
            outer: do {
                // Need to copy the bundled database into the Application Support directory on order for GRDB to access it
                // https://github.com/groue/GRDB.swift#how-do-i-open-a-database-stored-as-a-resource-of-my-application
                if !fileManager.fileExists(atPath: dbPath) {
                    guard let bundledDbPath = Bundle.main.path(forResource: "hymnaldb-v19", ofType: "sqlite") else {
                        Crashlytics.crashlytics().log("Path to the bundled database was not found, so just create an empty database instead and initialize it with empty tables")
                        Crashlytics.crashlytics().setCustomValue("empty persistent db", forKey: "database_state")
                        Crashlytics.crashlytics().record(error: NSError(domain: "Database Initialization Error", code: NonFatalEvent.ErrorCode.databaseInitialization.rawValue))
                        needToCreateTables = true
                        break outer
                    }
                    try fileManager.copyItem(atPath: bundledDbPath, toPath: dbPath)
                    needToCreateTables = false
                    Crashlytics.crashlytics().log("Database successfully copied from bundled SQLite file")
                    Crashlytics.crashlytics().setCustomValue("bundled db", forKey: "database_state")
                }
            } catch {
                Crashlytics.crashlytics().log("Unable to copy bundled data to the Application Support directly, so just create an empty database there instead and initialize it with empty tables")
                Crashlytics.crashlytics().setCustomValue("empty persistent db", forKey: "database_state")
                Crashlytics.crashlytics().record(error: error)
                needToCreateTables = true
            }

            let databaseQueue: DatabaseQueue
            do {
                databaseQueue = try DatabaseQueue(path: dbPath)
            } catch {
                Crashlytics.crashlytics().log("Unable to create database queue at the desired path, so create an in-memory one and initialize it with empty tables as a fallback")
                Crashlytics.crashlytics().setCustomValue("in-memory db", forKey: "database_state")
                Crashlytics.crashlytics().record(error: error)
                databaseQueue = DatabaseQueue()
                needToCreateTables = true
            }
            return HymnDataStoreGrdbImpl(databaseQueue: databaseQueue, initializeTables: needToCreateTables) as HymnDataStore
        }.scope(.application)
    }
}
