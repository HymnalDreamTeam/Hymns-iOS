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
    let queryParams: String
    let title: String?
    let lyricsJson: String?
    let category: String?
    let subcategory: String?
    let author: String?
    let composer: String?
    let key: String?
    let time: String?
    let meter: String?
    let scriptures: String?
    let hymnCode: String?
    let musicJson: String?
    let svgSheetJson: String?
    let pdfSheetJson: String?
    let languagesJson: String?
    let relevantJson: String?

    // https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case queryParams = "QUERY_PARAMS"
        case title = "SONG_TITLE"
        case lyricsJson = "SONG_LYRICS"
        case category = "SONG_META_DATA_CATEGORY"
        case subcategory = "SONG_META_DATA_SUBCATEGORY"
        case author = "SONG_META_DATA_AUTHOR"
        case composer = "SONG_META_DATA_COMPOSER"
        case key = "SONG_META_DATA_KEY"
        case time = "SONG_META_DATA_TIME"
        case meter = "SONG_META_DATA_METER"
        case scriptures = "SONG_META_DATA_SCRIPTURES"
        case hymnCode = "SONG_META_DATA_HYMN_CODE"
        case musicJson = "SONG_META_DATA_MUSIC"
        case svgSheetJson = "SONG_META_DATA_SVG_SHEET_MUSIC"
        case pdfSheetJson = "SONG_META_DATA_PDF_SHEET_MUSIC"
        case languagesJson = "SONG_META_DATA_LANGUAGES"
        case relevantJson = "SONG_META_DATA_RELEVANT"
    }

    static func == (lhs: HymnEntity, rhs: HymnEntity) -> Bool {
        let hymnTypesEqual = lhs.hymnType == rhs.hymnType
        let hymnNumbersEqual = lhs.hymnNumber == rhs.hymnNumber
        let queryParamsEqual = lhs.queryParams == rhs.queryParams
        let titlesEqual = lhs.title == rhs.title
        let lyricsEqual = lhs.lyricsJson == rhs.lyricsJson
        let categoriesEqual = lhs.category == rhs.category
        let subcategoriesEqual = lhs.subcategory == rhs.subcategory
        let authorsEqual = lhs.author == rhs.author
        let composersEqual = lhs.composer == rhs.composer
        let keysEqual = lhs.key == rhs.key
        let timesEqual = lhs.time == rhs.title
        let metersEqual = lhs.meter == rhs.meter
        let scripturesEqual = lhs.scriptures == rhs.scriptures
        let hymnCodesEqual = lhs.hymnCode == rhs.hymnCode
        let musicsEqual = lhs.musicJson == rhs.musicJson
        let svgsEqual = lhs.svgSheetJson == rhs.svgSheetJson
        let pdfsEqual = lhs.pdfSheetJson == rhs.pdfSheetJson
        let languagesEqual = lhs.languagesJson == rhs.languagesJson
        let relevantsEqual = lhs.relevantJson == rhs.relevantJson
        return hymnTypesEqual && hymnNumbersEqual && queryParamsEqual && titlesEqual && lyricsEqual && categoriesEqual && subcategoriesEqual
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
        static let queryParams = Column(CodingKeys.queryParams)
        static let title = Column(CodingKeys.title)
        static let lyricsJson = Column(CodingKeys.lyricsJson)
        static let category = Column(CodingKeys.category)
        static let subcategory = Column(CodingKeys.subcategory)
        static let author = Column(CodingKeys.author)
        static let composer = Column(CodingKeys.composer)
        static let key = Column(CodingKeys.key)
        static let time = Column(CodingKeys.time)
        static let meter = Column(CodingKeys.meter)
        static let scriptures = Column(CodingKeys.scriptures)
        static let hymnCode = Column(CodingKeys.hymnCode)
        static let musicJson = Column(CodingKeys.musicJson)
        static let svgSheetJson = Column(CodingKeys.svgSheetJson)
        static let pdfSheetJson = Column(CodingKeys.pdfSheetJson)
        static let languagesJson = Column(CodingKeys.languagesJson)
        static let relevantJson = Column(CodingKeys.relevantJson)
    }
}

class HymnEntityBuilder {

    private (set) var hymnIdentifier: HymnIdentifier
    private (set) var id: Int64?
    private (set) var title: String?
    private (set) var lyricsJson: String?
    private (set) var category: String?
    private (set) var subcategory: String?
    private (set) var author: String?
    private (set) var composer: String?
    private (set) var key: String?
    private (set) var time: String?
    private (set) var meter: String?
    private (set) var scriptures: String?
    private (set) var hymnCode: String?
    private (set) var musicJson: String?
    private (set) var svgSheetJson: String?
    private (set) var pdfSheetJson: String?
    private (set) var languagesJson: String?
    private (set) var relevantJson: String?

    init(hymnIdentifier: HymnIdentifier) {
        self.hymnIdentifier = hymnIdentifier
    }

    init?(_ hymnEntity: HymnEntity) {
        guard let hymnType = HymnType.fromAbbreviatedValue(hymnEntity.hymnType) else {
            return nil
        }
        self.hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: hymnEntity.hymnNumber, queryParams: hymnEntity.queryParams.deserializeFromQueryParamString)
        self.title = hymnEntity.title
        self.lyricsJson = hymnEntity.lyricsJson
        self.category = hymnEntity.category
        self.subcategory = hymnEntity.subcategory
        self.author = hymnEntity.author
        self.composer = hymnEntity.composer
        self.key = hymnEntity.key
        self.time = hymnEntity.time
        self.meter = hymnEntity.meter
        self.scriptures = hymnEntity.scriptures
        self.hymnCode = hymnEntity.hymnCode
        self.musicJson = hymnEntity.musicJson
        self.svgSheetJson = hymnEntity.svgSheetJson
        self.pdfSheetJson = hymnEntity.pdfSheetJson
        self.languagesJson = hymnEntity.languagesJson
        self.relevantJson = hymnEntity.relevantJson
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

    public func lyricsJson(_ lyricsJson: String?) -> HymnEntityBuilder {
        self.lyricsJson = lyricsJson
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

    public func musicJson(_ musicJson: String?) -> HymnEntityBuilder {
        self.musicJson = musicJson
        return self
    }

    public func svgSheetJson(_ svgSheetJson: String?) -> HymnEntityBuilder {
        self.svgSheetJson = svgSheetJson
        return self
    }

    public func pdfSheetJson(_ pdfSheetJson: String?) -> HymnEntityBuilder {
        self.pdfSheetJson = pdfSheetJson
        return self
    }

    public func languagesJson(_ languagesJson: String?) -> HymnEntityBuilder {
        self.languagesJson = languagesJson
        return self
    }

    public func relevantJson(_ relevantJson: String?) -> HymnEntityBuilder {
        self.relevantJson = relevantJson
        return self
    }

    public func build() -> HymnEntity {
        HymnEntity(id: id,
                   hymnType: hymnIdentifier.hymnType.abbreviatedValue,
                   hymnNumber: hymnIdentifier.hymnNumber,
                   queryParams: hymnIdentifier.queryParamString,
                   title: title,
                   lyricsJson: lyricsJson,
                   category: category,
                   subcategory: subcategory,
                   author: author,
                   composer: composer,
                   key: key,
                   time: time,
                   meter: meter,
                   scriptures: scriptures,
                   hymnCode: hymnCode,
                   musicJson: musicJson,
                   svgSheetJson: svgSheetJson,
                   pdfSheetJson: pdfSheetJson,
                   languagesJson: languagesJson,
                   relevantJson: relevantJson)
    }
}
