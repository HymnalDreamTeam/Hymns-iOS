import Foundation
import GRDB

/**
 * Structure of a Hymn object returned from the databse.
 */
struct HymnEntity: Equatable {
    static let databaseTableName = "SONG_DATA"
    // Prefer Int64 for auto-incremented database ids
    let id: Int64?
    let hymnType: String
    let hymnNumber: String
    let title: String?
    let lyrics: [VerseEntity]?
    let category: String?
    let subcategory: String?
    let author: String?
    let composer: String?
    let key: String?
    let time: String?
    let meter: String?
    let scriptures: String?
    let hymnCode: String?
    let music: [String: String]?
    let svgSheet: [String: String]?
    let pdfSheet: [String: String]?
    let languages: [SongLink]?
    let relevant: [SongLink]?

    // https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case title = "SONG_TITLE"
        case lyrics = "SONG_LYRICS"
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
        case relevant = "SONG_META_DATA_RELEVANT"
    }

    static func == (lhs: HymnEntity, rhs: HymnEntity) -> Bool {
        let hymnTypesEqual = lhs.hymnType == rhs.hymnType
        let hymnNumbersEqual = lhs.hymnNumber == rhs.hymnNumber
        let titlesEqual = lhs.title == rhs.title
        let lyricsEqual = lhs.lyrics == rhs.lyrics
        let categoriesEqual = lhs.category == rhs.category
        let subcategoriesEqual = lhs.subcategory == rhs.subcategory
        let authorsEqual = lhs.author == rhs.author
        let composersEqual = lhs.composer == rhs.composer
        let keysEqual = lhs.key == rhs.key
        let timesEqual = lhs.time == rhs.time
        let metersEqual = lhs.meter == rhs.meter
        let scripturesEqual = lhs.scriptures == rhs.scriptures
        let hymnCodesEqual = lhs.hymnCode == rhs.hymnCode
        let musicsEqual = lhs.music == rhs.music
        let svgsEqual = lhs.svgSheet == rhs.svgSheet
        let pdfsEqual = lhs.pdfSheet == rhs.pdfSheet
        let languagesEqual = lhs.languages == rhs.languages
        let relevantsEqual = lhs.relevant == rhs.relevant
        return hymnTypesEqual && hymnNumbersEqual && titlesEqual && lyricsEqual && categoriesEqual && subcategoriesEqual
        && authorsEqual && composersEqual && keysEqual && timesEqual && metersEqual && scripturesEqual && hymnCodesEqual && musicsEqual && svgsEqual
        && pdfsEqual && languagesEqual && relevantsEqual
    }
}

extension HymnEntity: Codable, FetchableRecord, PersistableRecord, MutablePersistableRecord {
    // https://github.com/groue/GRDB.swift/blob/master/README.md#conflict-resolution
    static let persistenceConflictPolicy = PersistenceConflictPolicy(insert: .replace, update: .replace)

    // Define database columns from CodingKeys
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let hymnType = Column(CodingKeys.hymnType)
        static let hymnNumber = Column(CodingKeys.hymnNumber)
        static let title = Column(CodingKeys.title)
        static let lyrics = Column(CodingKeys.lyrics)
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
        static let relevant = Column(CodingKeys.relevant)
    }
}

class HymnEntityBuilder {

    private (set) var hymnIdentifier: HymnIdentifier
    private (set) var id: Int64?
    private (set) var title: String?
    private (set) var lyrics: [VerseEntity]?
    private (set) var category: String?
    private (set) var subcategory: String?
    private (set) var author: String?
    private (set) var composer: String?
    private (set) var key: String?
    private (set) var time: String?
    private (set) var meter: String?
    private (set) var scriptures: String?
    private (set) var hymnCode: String?
    private (set) var music: [String: String]?
    private (set) var svgSheet: [String: String]?
    private (set) var pdfSheet: [String: String]?
    private (set) var languages: [SongLink]?
    private (set) var relevant: [SongLink]?

    init(hymnIdentifier: HymnIdentifier) {
        self.hymnIdentifier = hymnIdentifier
    }

    init?(_ hymnEntity: HymnEntity) {
        guard let hymnType = HymnType.fromAbbreviatedValue(hymnEntity.hymnType) else {
            return nil
        }
        self.hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: hymnEntity.hymnNumber)
        self.title = hymnEntity.title
        self.lyrics = hymnEntity.lyrics
        self.category = hymnEntity.category
        self.subcategory = hymnEntity.subcategory
        self.author = hymnEntity.author
        self.composer = hymnEntity.composer
        self.key = hymnEntity.key
        self.time = hymnEntity.time
        self.meter = hymnEntity.meter
        self.scriptures = hymnEntity.scriptures
        self.hymnCode = hymnEntity.hymnCode
        self.music = hymnEntity.music
        self.svgSheet = hymnEntity.svgSheet
        self.pdfSheet = hymnEntity.pdfSheet
        self.languages = hymnEntity.languages
        self.relevant = hymnEntity.relevant
    }

    public func hymnIdentifier(_ hymnIdentifier: HymnIdentifier) -> HymnEntityBuilder {
        self.hymnIdentifier = hymnIdentifier
        return self
    }

    public func id(_ id: Int64?) -> HymnEntityBuilder {
        self.id = id
        return self
    }

    public func title(_ title: String?) -> HymnEntityBuilder {
        self.title = title
        return self
    }

    public func lyrics(_ lyrics: [VerseEntity]?) -> HymnEntityBuilder {
        self.lyrics = lyrics
        return self
    }

    public func category(_ category: String?) -> HymnEntityBuilder {
        self.category = category
        return self
    }

    public func subcategory(_ subcategory: String?) -> HymnEntityBuilder {
        self.subcategory = subcategory
        return self
    }

    public func author(_ author: String?) -> HymnEntityBuilder {
        self.author = author
        return self
    }

    public func composer(_ composer: String?) -> HymnEntityBuilder {
        self.composer = composer
        return self
    }

    public func key(_ key: String?) -> HymnEntityBuilder {
        self.key = key
        return self
    }

    public func time(_ time: String?) -> HymnEntityBuilder {
        self.time = time
        return self
    }

    public func meter(_ meter: String?) -> HymnEntityBuilder {
        self.meter = meter
        return self
    }

    public func scriptures(_ scriptures: String?) -> HymnEntityBuilder {
        self.scriptures = scriptures
        return self
    }

    public func hymnCode(_ hymnCode: String?) -> HymnEntityBuilder {
        self.hymnCode = hymnCode
        return self
    }

    public func music(_ music: [String: String]?) -> HymnEntityBuilder {
        self.music = music
        return self
    }

    public func svgSheet(_ svgSheet: [String: String]?) -> HymnEntityBuilder {
        self.svgSheet = svgSheet
        return self
    }

    public func pdfSheet(_ pdfSheet: [String: String]?) -> HymnEntityBuilder {
        self.pdfSheet = pdfSheet
        return self
    }

    public func languages(_ languages: [SongLink]?) -> HymnEntityBuilder {
        self.languages = languages
        return self
    }

    public func relevant(_ relevant: [SongLink]?) -> HymnEntityBuilder {
        self.relevant = relevant
        return self
    }

    public func build() -> HymnEntity {
        HymnEntity(id: id,
                   hymnType: hymnIdentifier.hymnType.abbreviatedValue,
                   hymnNumber: hymnIdentifier.hymnNumber,
                   title: title,
                   lyrics: lyrics,
                   category: category,
                   subcategory: subcategory,
                   author: author,
                   composer: composer,
                   key: key,
                   time: time,
                   meter: meter,
                   scriptures: scriptures,
                   hymnCode: hymnCode,
                   music: music,
                   svgSheet: svgSheet,
                   pdfSheet: pdfSheet,
                   languages: languages,
                   relevant: relevant)
    }
}
