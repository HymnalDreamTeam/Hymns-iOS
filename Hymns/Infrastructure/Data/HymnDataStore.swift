import Combine
import FirebaseCrashlytics
import Foundation
import GRDB
import GRDBCombine
import Resolver

// swiftlint:disable:next identifier_name
let HYMN_DATA_STORE_VERISON = 28

// Service to contact the local Hymn database.
// swiftlint:disable file_length
protocol HymnDataStore {

    /**
     * Whether or not the database has been initialized properly. If this value is false, then the database is **NOT** safe to use and clients should avoid using it.
     */
    var databaseInitializedProperly: Bool { get }

    func saveHymn(_ entity: HymnIdEntity)
    func saveHymn(_ entity: HymnEntity) -> Int64?
    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnReference?, ErrorType>
    func getHymnsByTitleSync(_ title: String) throws -> [HymnReference]
    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SearchResultEntity], ErrorType>
    func getHymns(by hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getHymns(by hymnTypes: [HymnType]) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType>
    func getResultsBy(category: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(category: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(category: String, subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(category: String, subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(author: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(composer: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(key: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(time: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(meter: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(scriptures: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getResultsBy(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType>
    func getScriptureSongs() -> AnyPublisher<[ScriptureEntity], ErrorType>
    func getAllSongs(hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType>
}

// swiftlint:disable:next type_body_length
class HymnDataStoreGrdbImpl: HymnDataStore {

    private(set) var databaseInitializedProperly = true

    private let databaseQueue: DatabaseQueue
    private let firebaseLogger: FirebaseLogger

    /// Initializes the `HymnDataStoreGrdbImpl` object.
    /// - Parameter databaseQueue: `DatabaseQueue` object to use to make sql queries to
    /// - Parameter firebaseLogger: Used for logging analytics and non-fatal errors
    /// - Parameter initializeTables: Whether or not to create the necessary tables on startup
    init(databaseQueue: DatabaseQueue, firebaseLogger: FirebaseLogger = Resolver.resolve(), initializeTables: Bool = false) {
        self.databaseQueue = databaseQueue
        self.firebaseLogger = firebaseLogger
        if initializeTables {
            databaseQueue.inDatabase { database in
                do {
                    // CREATE TABLE IF NOT EXISTS SONG_DATA(
                    //   ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                    //   SONG_TITLE TEXT,
                    //   SONG_LYRICS TEXT,
                    //   INLINE_CHORDS TEXT,
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
                    //   SONG_META_DATA_RELEVANTS TEXT,
                    //   FLATTENED_LYRICS TEXT,
                    //   SONG_LANGUAGE INTEGER)
                    try database.create(table: HymnEntity.databaseTableName, ifNotExists: true) { table in
                        table.autoIncrementedPrimaryKey(HymnEntity.CodingKeys.id.rawValue)
                        table.column(HymnEntity.CodingKeys.title.rawValue, .text).notNull()
                        table.column(HymnEntity.CodingKeys.lyrics.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.inlineChords.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.category.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.subcategory.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.author.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.composer.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.key.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.time.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.meter.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.scriptures.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.hymnCode.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.music.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.svgSheet.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.pdfSheet.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.languages.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.relevants.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.flattenedLyrics.rawValue, .text)
                        table.column(HymnEntity.CodingKeys.language.rawValue, .integer)
                    }

                    // CREATE INDEX IF NOT EXISTS index_SONG_DATA_ID ON SONG_DATA (ID)
                    try database.create(index: "index_SONG_DATA_ID",
                                        on: HymnEntity.databaseTableName,
                                        columns: [HymnEntity.CodingKeys.id.rawValue],
                                        ifNotExists: true)

                    // CREATE TABLE IF NOT EXISTS SONG_IDS(
                    //   HYMN_TYPE TEXT NOT NULL,
                    //   HYMN_NUMBER TEXT NOT NULL,
                    //   SONG_ID INTEGER NOT NULL,
                    //   PRIMARY KEY (HYMN_TYPE, HYMN_NUMBER),
                    //   FOREIGN KEY(SONG_ID) REFERENCES SONG_DATA(ID) ON UPDATE NO ACTION ON DELETE CASCADE
                    // )
                    try database.create(table: HymnIdEntity.databaseTableName, ifNotExists: true) { table in
                        table.column(HymnIdEntity.CodingKeys.hymnType.rawValue, .text).notNull()
                        table.column(HymnIdEntity.CodingKeys.hymnNumber.rawValue, .text).notNull()
                        table.column(HymnIdEntity.CodingKeys.songId.rawValue, .integer).notNull()
                        table.primaryKey([HymnIdEntity.CodingKeys.hymnType.rawValue, HymnIdEntity.CodingKeys.hymnNumber.rawValue])
                        table.foreignKey([HymnIdEntity.CodingKeys.songId.rawValue],
                                         references: HymnEntity.databaseTableName,
                                         columns: [HymnEntity.CodingKeys.id.rawValue],
                                         onDelete: .cascade,
                                         onUpdate: .none)
                    }
                    // CREATE UNIQUE INDEX IF NOT EXISTS index_SONG_IDS_HYMN_TYPE_HYMN_NUMBER ON SONG_IDS (HYMN_TYPE, HYMN_NUMBER)
                    try database.create(index: "index_SONG_IDS_HYMN_TYPE_HYMN_NUMBER",
                                        on: HymnIdEntity.databaseTableName,
                                        columns: [HymnIdEntity.CodingKeys.hymnType.rawValue, HymnIdEntity.CodingKeys.hymnNumber.rawValue],
                                        unique: true,
                                        ifNotExists: true)
                    // CREATE INDEX IF NOT EXISTS index_SONG_IDS_SONG_ID ON SONG_IDS (SONG_ID)
                    try database.create(index: "index_SONG_IDS_SONG_ID",
                                        on: HymnIdEntity.databaseTableName,
                                        columns: [HymnIdEntity.CodingKeys.songId.rawValue],
                                        ifNotExists: true)

                    // CREATE VIRTUAL TABLE IF NOT EXISTS SEARCH_VIRTUAL_SONG_DATA USING FTS4(
                    //   SONG_TITLE TEXT,
                    //   SONG_LYRICS TEXT NOT NULL,
                    //   tokenize=porter,
                    //   content=SONG_DATA
                    // )
                    try database.create(virtualTable: "SEARCH_VIRTUAL_SONG_DATA", ifNotExists: true, using: FTS4()) { table in
                        table.synchronize(withTable: HymnEntity.databaseTableName)
                        table.tokenizer = .porter
                        table.column(HymnEntity.CodingKeys.title.rawValue)
                        table.column(HymnEntity.CodingKeys.lyrics.rawValue)
                    }
                } catch {
                    databaseInitializedProperly = false
                    firebaseLogger.logError(error, message: "Failed to create tables for data store",
                                            extraParameters: ["database_state": "corrupted"])
                }
            }
        }
    }

    func saveHymn(_ entity: HymnEntity) -> Int64? {
        do {
            return try self.databaseQueue.inDatabase { database in
                try entity.insert(database)
                return database.lastInsertedRowID
            }
        } catch {
            firebaseLogger.logError(error, message: "Save entity failed",
                                    extraParameters: ["hymn": String(describing: entity)])
        }
        return nil
    }

    func saveHymn(_ entity: HymnIdEntity) {
        do {
            try self.databaseQueue.inDatabase { database in
                try entity.insert(database)
            }
        } catch {
            firebaseLogger.logError(error, message: "Save entity failed",
                                    extraParameters: ["hymnType": String(describing: entity.hymnType), "hymnNumber": entity.hymnNumber])
        }
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnReference?, ErrorType> {
        let hymnType = hymnIdentifier.hymnType.rawValue
        let hymnNumber = hymnIdentifier.hymnNumber

        return databaseQueue.readPublisher { database in
            try HymnReference.fetchOne(
                database,
                sql: "SELECT * FROM SONG_DATA JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID WHERE HYMN_TYPE = ? AND HYMN_NUMBER = ?",
                arguments: [hymnType, hymnNumber])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).map({entity -> HymnReference? in
            return entity
        }).eraseToAnyPublisher()
    }

    func getHymnsByTitleSync(_ title: String) throws -> [HymnReference] {
        try databaseQueue.read { database in
            try HymnReference.fetchAll(
                database,
                sql: "SELECT * FROM SONG_DATA JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID WHERE SONG_TITLE = ?",
                arguments: [title])
        }
    }

    func getHymns(by hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE HYMN_TYPE = ?",
                arguments: [hymnType.rawValue])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getHymns(by hymnTypes: [HymnType]) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER " +
                "FROM SONG_DATA " +
                "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                // Create a comma-seperated list of "?"s
                "WHERE HYMN_TYPE IN (\(hymnTypes.map { _ in "?" }.joined(separator: ",")))",
                arguments: StatementArguments(hymnTypes.map {$0.rawValue}))
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SearchResultEntity], ErrorType> {
        let pattern = FTS3Pattern(matchingAnyTokenIn: searchParameter)

        /// For each column, the length of the longest subsequence of phrase matches that the column value has in common with the query text. For example, if a table column contains the text 'a b c d e' and the query
        /// is 'a c "d e"', then the length of the longest common subsequence is 2 (phrase "c" followed by phrase "d e").
        /// https://sqlite.org/fts3.html#matchinfo
        return databaseQueue.readPublisher { database in
            try SearchResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_DATA.SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, matchinfo(SEARCH_VIRTUAL_SONG_DATA, 's') , SONG_DATA.ID " +
                    "FROM SONG_DATA " +
                    "JOIN SEARCH_VIRTUAL_SONG_DATA ON (SEARCH_VIRTUAL_SONG_DATA.docid = SONG_DATA.rowid) " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SEARCH_VIRTUAL_SONG_DATA MATCH ?",
                arguments: [pattern])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try CategoryEntity.fetchAll(
                database,
                sql:
                    "SELECT DISTINCT SONG_META_DATA_CATEGORY, SONG_META_DATA_SUBCATEGORY, COUNT(1) " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_CATEGORY IS NOT NULL AND SONG_META_DATA_SUBCATEGORY IS NOT NULL AND HYMN_TYPE = ? GROUP BY 1, 2",
                arguments: [hymnType.rawValue])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_CATEGORY = ?",
                arguments: [category])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE HYMN_TYPE = ? AND SONG_META_DATA_CATEGORY = ?",
                arguments: [hymnType.rawValue, category])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_CATEGORY = ? AND SONG_META_DATA_SUBCATEGORY = ?",
                arguments: [category, subcategory])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE HYMN_TYPE = ? AND SONG_META_DATA_CATEGORY = ? AND SONG_META_DATA_SUBCATEGORY = ?",
                arguments: [hymnType.rawValue, category, subcategory])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_SUBCATEGORY = ?",
                arguments: [subcategory])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE HYMN_TYPE = ? AND SONG_META_DATA_SUBCATEGORY = ?",
                arguments: [hymnType.rawValue, subcategory])
        }.mapError({error -> ErrorType in
                .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    // swiftlint:disable force_try
    func getAllResults() -> [SongResultEntity] {
        databaseQueue.inDatabase { database in
            try! SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                "FROM SONG_DATA " +
                "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID")
        }
    }

    func getAllHymns() -> [HymnReference] {
        databaseQueue.inDatabase { database in
            try! HymnReference.fetchAll(
                database,
                sql: "SELECT * FROM SONG_DATA JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID")
        }
    }
    // swiftlint:enable force_try

    func getResultsBy(author: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_AUTHOR LIKE '%' || ? || '%'",
                arguments: [author])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(composer: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_COMPOSER LIKE '%' || ? || '%'",
                arguments: [composer])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(key: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_KEY = ?",
                arguments: [key])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(time: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_TIME LIKE '%' || ? || '%'",
                arguments: [time])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(meter: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_METER LIKE '%' || ? || '%'",
                arguments: [meter])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(scriptures: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_SCRIPTURES = ?",
                arguments: [scriptures])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getResultsBy(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_HYMN_CODE = ?",
                arguments: [hymnCode])
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getScriptureSongs() -> AnyPublisher<[ScriptureEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try ScriptureEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, SONG_META_DATA_SCRIPTURES " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE SONG_META_DATA_SCRIPTURES IS NOT NULL AND SONG_TITLE IS NOT NULL")
        }.mapError({error -> ErrorType in
            .data(description: error.localizedDescription)
        }).eraseToAnyPublisher()
    }

    func getAllSongs(hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        databaseQueue.readPublisher { database in
            try SongResultEntity.fetchAll(
                database,
                sql:
                    "SELECT SONG_TITLE, HYMN_TYPE, HYMN_NUMBER, ID " +
                    "FROM SONG_DATA " +
                    "JOIN SONG_IDS ON SONG_DATA.ID = SONG_IDS.SONG_ID " +
                    "WHERE HYMN_TYPE = ?",
                arguments: [hymnType.rawValue])
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
                    .appendingPathComponent("hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite")
                    .path else {
                        Crashlytics.crashlytics().setCustomValue("in-memory db", forKey: "database_state")
                        Crashlytics.crashlytics().record(
                            error: DatabasePathError(errorDescription: "hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite"),
                            userInfo: ["error_message": "The desired path 'hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite' in Application Support is nil, so we are unable to create a database file. Fall back to useing an in-memory db and initialize it with empty tables"])
                        return HymnDataStoreGrdbImpl(databaseQueue: DatabaseQueue(), initializeTables: true) as HymnDataStore
            }

            /// Whether or not we need to create the tables for the database.
            var needToCreateTables: Bool = false
            outer: do {
                // Need to copy the bundled database into the Application Support directory on order for GRDB to access it
                // https://github.com/groue/GRDB.swift#how-do-i-open-a-database-stored-as-a-resource-of-my-application
                if !fileManager.fileExists(atPath: dbPath) {
                    guard let bundledDbPath = Bundle.main.path(forResource: "hymnaldb-v\(HYMN_DATA_STORE_VERISON)",
                                                               ofType: "sqlite") else {
                        Crashlytics.crashlytics().setCustomValue("empty persistent db", forKey: "database_state")
                        Crashlytics.crashlytics().record(
                            error: DatabaseFileNotFoundError(errorDescription: "Database Initialization Error"),
                            userInfo: ["error_message": "Path to the bundled database (hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite) was not found, so just create an empty database instead and initialize it with empty tables"])
                        needToCreateTables = true
                        break outer
                    }
                    try fileManager.copyItem(atPath: bundledDbPath, toPath: dbPath)
                    needToCreateTables = false
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
