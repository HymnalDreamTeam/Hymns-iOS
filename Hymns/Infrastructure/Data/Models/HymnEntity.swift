import Foundation
import GRDB

extension HymnEntity {
    // https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case title = "SONG_TITLE"
        case lyrics = "SONG_LYRICS"
        case inlineChords = "INLINE_CHORDS"
        case category = "SONG_META_DATA_CATEGORY"
        case subcategory = "SONG_META_DATA_SUBCATEGORY"
        case author = "SONG_META_DATA_AUTHOR"
        case composer = "SONG_META_DATA_COMPOSER"
        case key = "SONG_META_DATA_KEY"
        case time = "SONG_META_DATA_TIME"
        case meter = "SONG_META_DATA_METER"
        case scriptures = "SONG_META_DATA_SCRIPTURES"
        case hymnCode = "SONG_META_DATA_HYMN_CODE"
        case music = "SONG_META_DATA_MUSIC"
        case svgSheet = "SONG_META_DATA_SVG_SHEET_MUSIC"
        case pdfSheet = "SONG_META_DATA_PDF_SHEET_MUSIC"
        case languages = "SONG_META_DATA_LANGUAGES"
        case relevants = "SONG_META_DATA_RELEVANTS"
        case flattenedLyrics = "FLATTENED_LYRICS"
        case language = "SONG_LANGUAGE"
    }
}

extension HymnEntity {
    // https://github.com/groue/GRDB.swift/blob/master/README.md#conflict-resolution
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    // Define database columns from CodingKeys
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let title = Column(CodingKeys.title)
        static let lyrics = Column(CodingKeys.lyrics)
        static let inlineChords = Column(CodingKeys.inlineChords)
        static let category = Column(CodingKeys.category)
        static let subcategory = Column(CodingKeys.subcategory)
        static let author = Column(CodingKeys.author)
        static let composer = Column(CodingKeys.composer)
        static let key = Column(CodingKeys.key)
        static let time = Column(CodingKeys.time)
        static let meter = Column(CodingKeys.meter)
        static let scriptures = Column(CodingKeys.scriptures)
        static let hymnCode = Column(CodingKeys.hymnCode)
        static let music = Column(CodingKeys.music)
        static let svgSheet = Column(CodingKeys.svgSheet)
        static let pdfSheet = Column(CodingKeys.pdfSheet)
        static let languages = Column(CodingKeys.languages)
        static let relevants = Column(CodingKeys.relevants)
        static let flattenedLyrics = Column(CodingKeys.flattenedLyrics)
        static let language = Column(CodingKeys.language)
    }
}

// Intended force-trys. FetchableRecord is designed for records that reliably decode from rows.
// swiftlint:disable force_try
extension HymnEntity: FetchableRecord, MutablePersistableRecord {
    public init(row: Row) {
        self.id = row[CodingKeys.id.rawValue]
        self.title = row[CodingKeys.title.rawValue]
        if row[CodingKeys.lyrics.rawValue] != nil, let lyrics = try? LyricsEntity(serializedBytes: row[CodingKeys.lyrics.rawValue] as Data) {
            self.lyrics = lyrics
        }
        if row[CodingKeys.inlineChords.rawValue] != nil, let inlineChords = try? InlineChordsEntity(serializedBytes: row[CodingKeys.inlineChords.rawValue] as Data) {
            self.inlineChords = inlineChords
        }
        self.category = row[CodingKeys.category.rawValue]?.toStringArray ?? [String]()
        self.subcategory = row[CodingKeys.subcategory.rawValue]?.toStringArray ?? [String]()
        self.author = row[CodingKeys.author.rawValue]?.toStringArray ?? [String]()
        self.composer = row[CodingKeys.composer.rawValue]?.toStringArray ?? [String]()
        self.key = row[CodingKeys.key.rawValue]?.toStringArray ?? [String]()
        self.time = row[CodingKeys.time.rawValue]?.toStringArray ?? [String]()
        self.meter = row[CodingKeys.meter.rawValue]?.toStringArray ?? [String]()
        self.scriptures = row[CodingKeys.scriptures.rawValue]?.toStringArray ?? [String]()
        self.hymnCode = row[CodingKeys.hymnCode.rawValue]?.toStringArray ?? [String]()
        if row[CodingKeys.music.rawValue] != nil, let music = try? MusicEntity(serializedBytes: row[CodingKeys.music.rawValue] as Data) {
            self.music = music
        }
        if row[CodingKeys.svgSheet.rawValue] != nil, let svgSheet = try? SvgSheetEntity(serializedBytes: row[CodingKeys.svgSheet.rawValue] as Data) {
            self.svgSheet = svgSheet
        }
        if row[CodingKeys.pdfSheet.rawValue] != nil, let pdfSheet = try? PdfSheetEntity(serializedBytes: row[CodingKeys.pdfSheet.rawValue] as Data) {
            self.pdfSheet = pdfSheet
        }
        if row[CodingKeys.languages.rawValue] != nil, let languages = try? LanguagesEntity(serializedBytes: row[CodingKeys.languages.rawValue] as Data) {
            self.languages = languages
        }
        if row[CodingKeys.relevants.rawValue] != nil, let relevant = try? RelevantsEntity(serializedBytes: row[CodingKeys.relevants.rawValue] as Data) {
            self.relevants = relevant
        }
        if row[CodingKeys.flattenedLyrics.rawValue] != nil {
            self.flattenedLyrics = row[CodingKeys.flattenedLyrics.rawValue]!
        }
        if row[CodingKeys.language.rawValue] != nil, let language = Language(rawValue: row[CodingKeys.language.rawValue]) {
            self.language = language
        }
    }

    func encode(to container: inout GRDB.PersistenceContainer) {
        if id != 0 {
            container[CodingKeys.id.rawValue] = id
        }
        if !title.isEmpty {
            container[CodingKeys.title.rawValue] = title
        }
        if !lyrics.verses.isEmpty {
            container[CodingKeys.lyrics.rawValue] = try? lyrics.serializedData()
        }
        if !inlineChords.chordLines.isEmpty {
            container[CodingKeys.inlineChords.rawValue] = try? inlineChords.serializedData()
        }
        if !category.isEmpty {
            container[CodingKeys.category.rawValue] = category.joined(separator: ",")
        }
        if !subcategory.isEmpty {
            container[CodingKeys.subcategory.rawValue] = subcategory.joined(separator: ",")
        }
        if !author.isEmpty {
            container[CodingKeys.author.rawValue] = author.joined(separator: ",")
        }
        if !composer.isEmpty {
            container[CodingKeys.composer.rawValue] = composer.joined(separator: ",")
        }
        if !key.isEmpty {
            container[CodingKeys.key.rawValue] = key.joined(separator: ",")
        }
        if !time.isEmpty {
            container[CodingKeys.time.rawValue] = time.joined(separator: ",")
        }
        if !meter.isEmpty {
            container[CodingKeys.meter.rawValue] = meter.joined(separator: ",")
        }
        if !scriptures.isEmpty {
            container[CodingKeys.scriptures.rawValue] = scriptures.joined(separator: ",")
        }
        if !hymnCode.isEmpty {
            container[CodingKeys.hymnCode.rawValue] = hymnCode.joined(separator: ",")
        }
        if !music.music.isEmpty {
            container[CodingKeys.music.rawValue] = try? music.serializedData()
        }
        if !svgSheet.svgSheet.isEmpty {
            container[CodingKeys.svgSheet.rawValue] = try? svgSheet.serializedData()
        }
        if !pdfSheet.pdfSheet.isEmpty {
            container[CodingKeys.pdfSheet.rawValue] = try? pdfSheet.serializedData()
        }
        if !languages.languages.isEmpty {
            container[CodingKeys.languages.rawValue] = try? languages.serializedData()
        }
        if !relevants.relevants.isEmpty {
            container[CodingKeys.relevants.rawValue] = try? relevants.serializedData()
        }
        if !flattenedLyrics.isEmpty {
            container[CodingKeys.flattenedLyrics.rawValue] = flattenedLyrics
        }
        if language != Language.UNRECOGNIZED(-1) {
            container[CodingKeys.language.rawValue] = language.rawValue
        }
    }
}

extension DatabaseValueConvertible {
    var toStringArray: [String]? {
        (self as? String)?.components(separatedBy: ",")
    }
}

// swiftlint:enable force_try

extension HymnEntity: PersistableRecord {
    static let databaseTableName = "SONG_DATA"
}

extension LyricsEntity {
    init(_ verses: [VerseEntity]) {
        self.verses = verses
    }
}

extension InlineChordsEntity {
    init?(_ chordLines: [ChordLineEntity]) {
        guard !chordLines.isEmpty else {
            return nil
        }
        self.chordLines = chordLines
    }
}

extension MusicEntity {
    init?(_ music: [String: String]?) {
        guard let music = music, !music.isEmpty else {
            return nil
        }
        self.music = music
    }
}

extension SvgSheetEntity {
    init?(_ svgSheet: [String: String]?) {
        guard let svgSheet = svgSheet, !svgSheet.isEmpty else {
            return nil
        }
        self.svgSheet = svgSheet
    }
}

extension PdfSheetEntity {
    init?(_ pdfSheet: [String: String]?) {
        guard let pdfSheet = pdfSheet, !pdfSheet.isEmpty else {
            return nil
        }
        self.pdfSheet = pdfSheet
    }
}

extension LanguagesEntity {
    init?(_ languages: [HymnIdentifier]?) {
        guard let languages = languages, !languages.isEmpty else {
            return nil
        }
        self.languages = languages.map { $0.toEntity }
    }
}

extension RelevantsEntity {
    init?(_ relevants: [HymnIdentifier]?) {
        guard let relevants = relevants, !relevants.isEmpty else {
            return nil
        }
        self.relevants = relevants.map { $0.toEntity }
    }
}
