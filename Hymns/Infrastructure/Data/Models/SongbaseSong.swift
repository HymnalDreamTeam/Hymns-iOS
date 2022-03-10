import GRDB

struct SongbaseSong: Codable {
    static let databaseTableName = "songs"
    let bookId: Int
    let bookIndex: Int
    let title: String
    let language: String
    let lyrics: String
    let chords: String

    enum CodingKeys: String, CodingKey {
        case bookId = "book_id"
        case bookIndex = "book_index"
        case title = "title"
        case language = "language"
        case lyrics = "lyrics"
        case chords = "chords"
    }
}

extension SongbaseSong {

    public static let chordsPattern = "\\[(.*?)\\]"

    var containsChords: Bool {
        return chords.range(of: Self.chordsPattern, options: .regularExpression) != nil
    }
}

extension SongbaseSong: FetchableRecord {

    // https://github.com/groue/GRDB.swift/blob/master/README.md#conflict-resolution
    public static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bookId = try container.decode(Int.self, forKey: .bookId)
        bookIndex = try container.decode(Int.self, forKey: .bookIndex)
        title = try container.decode(String.self, forKey: .title)
        language = try container.decode(String.self, forKey: .language)
        lyrics = try container.decode(String.self, forKey: .lyrics)
        chords = try container.decode(String.self, forKey: .chords)
    }
}
