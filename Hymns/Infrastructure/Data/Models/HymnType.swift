import Foundation

/// Represents the type of a hymn.
/// Note: Must keep this ordering because some versions of favorites/tags/history database rely on the numbering, and it may mess up migration for devices on those versions.
@objc enum HymnType: Int {
    case classic
    case newTune
    case newSong
    case children
    case howardHigashi
    case dutch
    case german
    case chinese
    case chineseSupplement
    case cebuano
    case tagalog
    case french
    case spanish
    case korean
    case japanese
    case indonesian
    case farsi
    case russian
    case portuguese
    case blueSongbook
    case chineseSimplified
    case chineseSupplementSimplified
    case beFilled
    case liederbuch
    case songbaseOther // Uncategorized songbase songs.

    static var allCases: [HymnType] {
        return [classic, newTune, newSong, children, howardHigashi, dutch, german, chinese, chineseSimplified,
                chineseSupplement, chineseSupplementSimplified, cebuano, tagalog, french, spanish, korean,
                japanese, indonesian, farsi, russian, portuguese, beFilled, liederbuch, blueSongbook, songbaseOther]
    }
}

extension HymnType {

    /**
     * Prefixes that match this paritcular hymn type during search (e.g. ch40, Chinese 40, Chinese40 should all match the song for "ch40")
     */
    static let searchPrefixes = allCases.reduce([String: HymnType]()) { partialResult, hymnType in
        var partialResult = partialResult
        partialResult[hymnType.abbreviatedValue.lowercased()] = hymnType
        return partialResult
    }.merging([
        "en": classic, "english": classic, "classic": classic, "hymn": classic,
        "new tune": .newTune,
        "new song": .newSong,
        "chidren": .children,
        "howard higashi": .howardHigashi, "long beach": .howardHigashi, "longbeach": .howardHigashi,
        "be filled": .beFilled, "befilled": .beFilled,
        "dt": .dutch, "dutch": .dutch,
        "g": .liederbuch, "ge": .liederbuch, "german": .liederbuch,
        "chinese": .chinese, "中文": .chinese,
        "cs": .chineseSupplement, "chs": .chineseSupplement, "chinese supplement": .chineseSupplement, "中文補充": .chineseSupplement, "中文补充": .chineseSupplement, "補充": .chineseSupplement, "补充": .chineseSupplement,
        "cebuano": .cebuano,
        "tg": .tagalog, "t": .tagalog, "tagalog": .tagalog,
        "fr": .french, "french": .french,
        "sp": .spanish, "spanish": .spanish,
        "kr": .korean, "korean": .korean,
        "jp": .japanese, "japanese": .japanese,
        "indonesian": .indonesian,
        "farsi": .farsi,
        "russian": .russian, "ru": .russian,
        "songbase": .blueSongbook, "sb": blueSongbook
    ]) { _, new in new } // merging two dictionaries: https://stackoverflow.com/a/43615143/1907538

    var abbreviatedValue: String {
        switch self {
        case .classic:
            return "h"
        case .newTune:
            return "nt"
        case .newSong:
            return "ns"
        case .children:
            return "c"
        case .howardHigashi:
            return "lb"
        case .dutch:
            return "hd"
        case .german:
            return "de"
        case .chinese:
            return "ch"
        case .chineseSimplified:
            return "chx"
        case .chineseSupplement:
            return "ts"
        case .chineseSupplementSimplified:
            return "tsx"
        case .cebuano:
            return "cb"
        case .tagalog:
            return "ht"
        case .french:
            return "hf"
        case .spanish:
            return "S"
        case .korean:
            return "K"
        case .japanese:
            return "J"
        case .indonesian:
            return "I"
        case .farsi:
            return "F"
        case .russian:
            return "R"
        case .portuguese:
            return "pt"
        case .beFilled:
            return "bf"
        case .liederbuch:
            return "lde"
        case .blueSongbook:
            return "sb"
        case .songbaseOther:
            return "sbx"
        }
    }

    /**
     * Maps a HymnType's abbreciated value to the corresponding enum.
     *
     * - Parameters:
     *     - abbreviatedValue: abbreviated value of the enum
     * - Returns: HymnType corresponding to value
     */
    static func fromAbbreviatedValue(_ abbreviatedValue: String) -> HymnType? {
        for hymnType in HymnType.allCases where abbreviatedValue == hymnType.abbreviatedValue {
            return hymnType
        }
        // In Hymnal.net, Spanish is hs.
        if abbreviatedValue == "hs" {
            return .spanish
        }
        return nil
    }

    var displayTitle: String {
        switch self {
        case .classic:
            return NSLocalizedString("Classic Hymns", comment: "Display name of 'Classic hymns'. Usually appears just by itself (i.e. as a title).")
        case .newTune:
            return NSLocalizedString("New Tunes", comment: "Display name of 'New Tunes'. Usually appears just by itself (i.e. as a title).")
        case .newSong:
            return NSLocalizedString("New Songs", comment: "Display name of 'New Songs'. Usually appears just by itself (i.e. as a title).")
        case .children:
            return NSLocalizedString("Children's Songs", comment: "Display name of 'Children's Songs'. Usually appears just by itself (i.e. as a title).")
        case .howardHigashi:
            return NSLocalizedString("Howard Higashi Songs", comment: "Display name of 'Howard Higashi Songs'. Usually appears just by itself (i.e. as a title).")
        case .dutch:
            return NSLocalizedString("Dutch Songs", comment: "Display name of 'Dutch Songs'. Usually appears just by itself (i.e. as a title).")
        case .german:
            return NSLocalizedString("German Songs", comment: "Display name of 'German Songs'. Usually appears just by itself (i.e. as a title).")
        case .chinese, .chineseSimplified:
            return NSLocalizedString("Chinese Songs", comment: "Display name of 'Chinese Songs'. Usually appears just by itself (i.e. as a title).")
        case .chineseSupplement, .chineseSupplementSimplified:
            return NSLocalizedString("Chinese Supplemental Songs", comment: "Display name of 'Chinese Supplemental Songs'. Usually appears just by itself (i.e. as a title).")
        case .cebuano:
            return NSLocalizedString("Cebuano Songs", comment: "Display name of 'Cebuano Songs'. Usually appears just by itself (i.e. as a title).")
        case .tagalog:
            return NSLocalizedString("Tagalog Songs", comment: "Display name of 'Tagalog Songs'. Usually appears just by itself (i.e. as a title).")
        case .french:
            return NSLocalizedString("French Songs", comment: "Display name of 'French Songs'. Usually appears just by itself (i.e. as a title).")
        case .spanish:
            return NSLocalizedString("Spanish Songs", comment: "Display name of 'Spanish Songs'. Usually appears just by itself (i.e. as a title).")
        case .korean:
            return NSLocalizedString("Korean Songs", comment: "Display name of 'Korean Songs'. Usually appears just by itself (i.e. as a title).")
        case .japanese:
            return NSLocalizedString("Japanese Songs", comment: "Display name of 'Japanese Songs'. Usually appears just by itself (i.e. as a title).")
        case .indonesian:
            return NSLocalizedString("Indonesian Songs", comment: "Display name of 'Indonesian Songs'. Usually appears just by itself (i.e. as a title).")
        case .farsi:
            return NSLocalizedString("Farsi Songs", comment: "Display name of 'Farsi Songs'. Usually appears just by itself (i.e. as a title).")
        case .russian:
            return NSLocalizedString("Russian Songs", comment: "Display name of 'Russian Songs'. Usually appears just by itself (i.e. as a title).")
        case .portuguese:
            return NSLocalizedString("Portuguese Songs", comment: "Display name of 'Portuguese Songs'. Usually appears just by itself (i.e. as a title).")
        case .beFilled:
            return NSLocalizedString("Be Filled Songs", comment: "Display name of 'Be Filled Songs'. Usually appears just by itself (i.e. as a title).")
        case .liederbuch:
            return NSLocalizedString("Liederbuch Songs", comment: "Display name of 'Liederbuch Songs'. Usually appears just by itself (i.e. as a title).")
        case .blueSongbook:
            return NSLocalizedString("Songbase Songs", comment: "Display name of 'Songbase Songs'. Usually appears just by itself (i.e. as a title).")
        case .songbaseOther:
            return NSLocalizedString("Songbase Songs", comment: "Display name of 'Songbase Songs'. Usually appears just by itself (i.e. as a title).")
        }
    }

    var displayLabel: String {
        switch self {
        case .classic:
            return NSLocalizedString("Hymn %@", comment: "Will appear in conjunction with something else (e.g. Hymn 7).")
        case .newTune:
            return NSLocalizedString("New tune %@", comment: "Will appear in conjunction with something else (e.g. New tune 7).")
        case .newSong:
            return NSLocalizedString("New song %@", comment: "Will appear in conjunction with something else (e.g. New song 7).")
        case .children:
            return NSLocalizedString("Children %@", comment: "Will appear in conjunction with something else (e.g. Children 7).")
        case .howardHigashi:
            return NSLocalizedString("Howard Higashi (LB) %@", comment: "Will appear in conjunction with something else (e.g. Howard Higashi (LB) 7).")
        case .dutch:
            return NSLocalizedString("Dutch %@", comment: "Will appear in conjunction with something else (e.g. Dutch 7).")
        case .german:
            return NSLocalizedString("German %@", comment: "Will appear in conjunction with something else (e.g. German 7).")
        case .chinese:
            return NSLocalizedString("Chinese %@ (Trad.)",
                                     comment: "Will appear in conjunction with something else (e.g. Chinese 7 (Trad.)).")
        case .chineseSimplified:
            return NSLocalizedString("Chinese %@ (Simp.)",
                                     comment: "Will appear in conjunction with something else (e.g. Chinese 7 (Simp.)).")
        case .chineseSupplement:
            return NSLocalizedString("Chinese Supplement %@ (Trad.)",
                                     comment: "Will appear in conjunction with something else (e.g. Chinese Supplement 7 (Trad.)).")
        case .chineseSupplementSimplified:
            return NSLocalizedString("Chinese Supplement %@ (Simp.)",
                                     comment: "Will appear in conjunction with something else (e.g. Chinese Supplement 7 (Simp.)).")
        case .cebuano:
            return NSLocalizedString("Cebuano %@", comment: "Will appear in conjunction with something else (e.g. Cebuano 7).")
        case .tagalog:
            return NSLocalizedString("Tagalog %@", comment: "Will appear in conjunction with something else (e.g. Tagalog 7).")
        case .french:
            return NSLocalizedString("French %@", comment: "Will appear in conjunction with something else (e.g. French 7).")
        case .spanish:
            return NSLocalizedString("Spanish %@", comment: "Will appear in conjunction with something else (e.g. Spanish 7).")
        case .korean:
            return NSLocalizedString("Korean %@", comment: "Will appear in conjunction with something else (e.g. Korean 7).")
        case .japanese:
            return NSLocalizedString("Japanese %@", comment: "Will appear in conjunction with something else (e.g. Japanese 7).")
        case .indonesian:
            return NSLocalizedString("Indonesian %@", comment: "Will appear in conjunction with something else (e.g. Indonesian 7).")
        case .farsi:
            return NSLocalizedString("Farsi %@", comment: "Will appear in conjunction with something else (e.g. Farsi 7).")
        case .russian:
            return NSLocalizedString("Russian %@", comment: "Will appear in conjunction with something else (e.g. Russian 7).")
        case .portuguese:
            return NSLocalizedString("Portuguese %@", comment: "Will appear in conjunction with something else (e.g. Portuguese 7).")
        case .beFilled:
            return NSLocalizedString("Be Filled %@", comment: "Will appear in conjunction with something else (e.g. Be Filled 7).")
        case .liederbuch:
            return NSLocalizedString("Liederbuch %@", comment: "Will appear in conjunction with something else (e.g. Liederbuch 7).")
        case .blueSongbook:
            return NSLocalizedString("Songbase %@", comment: "Will appear in conjunction with something else (e.g. Songbase 7).")
        case .songbaseOther:
            return NSLocalizedString("Songbase %@", comment: "Will appear in conjunction with something else (e.g. Songbase 7).")
        }
    }

    var language: Language {
        switch self {
        case .classic, .newTune, .newSong, .children, .howardHigashi, .beFilled, .blueSongbook, .songbaseOther:
            return .english
        case .dutch:
            return .dutch
        case .german, .liederbuch:
            return .german
        case .chinese, .chineseSupplement:
            return .chinese
        case .chineseSimplified, .chineseSupplementSimplified:
            return .chineseSimplified
        case .cebuano:
            return .cebuano
        case .tagalog:
            return .tagalog
        case .french:
            return .french
        case .spanish:
            return .spanish
        case .korean:
            return .korean
        case .japanese:
            return .japanese
        case .indonesian:
            return .indonesian
        case .farsi:
            return .farsi
        case .russian:
            return .russian
        case .portuguese:
            return .portuguese
        }
    }
}

extension HymnType: CustomStringConvertible {
    var description: String { abbreviatedValue }
}

extension HymnType: Decodable {

    enum HymnTypeCodingError: Error {
        case decoding(String)
    }

    // Decoding an enum: https://stackoverflow.com/a/48204890/1907538
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        guard let hymnType = HymnType.fromAbbreviatedValue(value) else {
            throw HymnTypeCodingError.decoding("Unrecognized abbreviated hymn type: \(value)")
        }
        self = hymnType
    }
}

extension HymnType {
    var toSongbaseBook: Int? {
        switch self {
        case .songbaseOther:
            return 1
        case .classic:
            return 2
        default:
            return nil
        }
    }
}

enum Language: Int {
    case english
    case dutch
    case german
    case chinese
    case chineseSimplified
    case cebuano
    case tagalog
    case french
    case spanish
    case korean
    case japanese
    case indonesian
    case farsi
    case russian
    case portuguese

    static let allValues = [
        english, chinese, chineseSimplified, cebuano,
        tagalog, dutch, german, french, spanish, portuguese,
        korean, japanese, indonesian, farsi, russian
    ]

    var displayTitle: String {
        switch self {
        case .english:
            return NSLocalizedString("English", comment: "Display name of the 'English' language.")
        case .dutch:
            return NSLocalizedString("Dutch", comment: "Display name of the 'Dutch' language.")
        case .german:
            return NSLocalizedString("German", comment: "Display name of the 'German' language.")
        case .chinese:
            return NSLocalizedString("Chinese (Trad.)", comment: "Display name of the traditional 'Chinese' language.")
        case .chineseSimplified:
            return NSLocalizedString("Chinese (Simp.)", comment: "Display name of the simplified 'Chinese' language.")
        case .cebuano:
            return NSLocalizedString("Cebuano", comment: "Display name of the 'Cebuano' language.")
        case .tagalog:
            return NSLocalizedString("Tagalog", comment: "Display name of the 'Tagalog' language.")
        case .french:
            return NSLocalizedString("French", comment: "Display name of the 'French' language.")
        case .spanish:
            return NSLocalizedString("Spanish", comment: "Display name of the 'Spanish' language.")
        case .korean:
            return NSLocalizedString("Korean", comment: "Display name of the 'Korean' language.")
        case .japanese:
            return NSLocalizedString("Japanese", comment: "Display name of the 'Japanese' language.")
        case .indonesian:
            return NSLocalizedString("Indonesian", comment: "Display name of the 'Indonesian' language.")
        case .farsi:
            return NSLocalizedString("Farsi", comment: "Display name of the 'Farsi' language.")
        case .russian:
            return NSLocalizedString("Russian", comment: "Display name of the 'Russian' language.")
        case .portuguese:
            return NSLocalizedString("Portuguese", comment: "Display name of the 'Portuguese' language.")
        }
    }
}

extension Language: Identifiable {
    var id: String { String(rawValue) }
}
