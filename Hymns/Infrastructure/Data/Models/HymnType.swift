import Foundation

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
        return switch self {
        case .classic:
            "h"
        case .newTune:
            "nt"
        case .newSong:
            "ns"
        case .children:
            "c"
        case .howardHigashi:
            "lb"
        case .dutch:
            "hd"
        case .german:
            "de"
        case .chinese:
            "ch"
        case .chineseSimplified:
            "chx"
        case .chineseSupplement:
            "ts"
        case .chineseSupplementSimplified:
            "tsx"
        case .cebuano:
            "cb"
        case .tagalog:
            "ht"
        case .french:
            "hf"
        case .spanish:
            "S"
        case .korean:
            "K"
        case .japanese:
            "J"
        case .indonesian:
            "I"
        case .farsi:
            "F"
        case .russian:
            "R"
        case .portuguese:
            "pt"
        case .hebrew:
            "he"
        case .slovak:
            "sk"
        case .estonian:
            "et"
        case .arabic:
            "ar"
        case .beFilled:
            "bf"
        case .liederbuch:
            "lde"
        case .liedboek:
            "lbk"
        case .blueSongbook:
            "sb"
        case .songbaseOther:
            "sbx"
        case .hinos:
            "hs"
        case .UNRECOGNIZED:
            ""
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
        return switch self {
        case .classic:
            NSLocalizedString("Classic Hymns", comment: "Display name of 'Classic hymns'. Usually appears just by itself (i.e. as a title).")
        case .newTune:
            NSLocalizedString("New Tunes", comment: "Display name of 'New Tunes'. Usually appears just by itself (i.e. as a title).")
        case .newSong:
            NSLocalizedString("New Songs", comment: "Display name of 'New Songs'. Usually appears just by itself (i.e. as a title).")
        case .children:
            NSLocalizedString("Children's Songs", comment: "Display name of 'Children's Songs'. Usually appears just by itself (i.e. as a title).")
        case .howardHigashi:
            NSLocalizedString("Howard Higashi Songs", comment: "Display name of 'Howard Higashi Songs'. Usually appears just by itself (i.e. as a title).")
        case .dutch:
            NSLocalizedString("Dutch Songs", comment: "Display name of 'Dutch Songs'. Usually appears just by itself (i.e. as a title).")
        case .german:
            NSLocalizedString("German Songs", comment: "Display name of 'German Songs'. Usually appears just by itself (i.e. as a title).")
        case .chinese, .chineseSimplified:
            NSLocalizedString("Chinese Songs", comment: "Display name of 'Chinese Songs'. Usually appears just by itself (i.e. as a title).")
        case .chineseSupplement, .chineseSupplementSimplified:
            NSLocalizedString("Chinese Supplemental Songs", comment: "Display name of 'Chinese Supplemental Songs'. Usually appears just by itself (i.e. as a title).")
        case .cebuano:
            NSLocalizedString("Cebuano Songs", comment: "Display name of 'Cebuano Songs'. Usually appears just by itself (i.e. as a title).")
        case .tagalog:
            NSLocalizedString("Tagalog Songs", comment: "Display name of 'Tagalog Songs'. Usually appears just by itself (i.e. as a title).")
        case .french:
            NSLocalizedString("French Songs", comment: "Display name of 'French Songs'. Usually appears just by itself (i.e. as a title).")
        case .spanish:
            NSLocalizedString("Spanish Songs", comment: "Display name of 'Spanish Songs'. Usually appears just by itself (i.e. as a title).")
        case .korean:
            NSLocalizedString("Korean Songs", comment: "Display name of 'Korean Songs'. Usually appears just by itself (i.e. as a title).")
        case .japanese:
            NSLocalizedString("Japanese Songs", comment: "Display name of 'Japanese Songs'. Usually appears just by itself (i.e. as a title).")
        case .indonesian:
            NSLocalizedString("Indonesian Songs", comment: "Display name of 'Indonesian Songs'. Usually appears just by itself (i.e. as a title).")
        case .farsi:
            NSLocalizedString("Farsi Songs", comment: "Display name of 'Farsi Songs'. Usually appears just by itself (i.e. as a title).")
        case .russian:
            NSLocalizedString("Russian Songs", comment: "Display name of 'Russian Songs'. Usually appears just by itself (i.e. as a title).")
        case .portuguese:
            NSLocalizedString("Portuguese Songs", comment: "Display name of 'Portuguese Songs'. Usually appears just by itself (i.e. as a title).")
        case .hebrew:
            NSLocalizedString("Hebrew Songs", comment: "Display name of 'Hebrew Songs'. Usually appears just by itself (i.e. as a title).")
        case .slovak:
            NSLocalizedString("Slovak Songs", comment: "Display name of 'Slovak Songs'. Usually appears just by itself (i.e. as a title).")
        case .estonian:
            NSLocalizedString("Estonian Songs", comment: "Display name of 'Estonian Songs'. Usually appears just by itself (i.e. as a title).")
        case .arabic:
            NSLocalizedString("Arabic Songs", comment: "Display name of 'Arabic Songs'. Usually appears just by itself (i.e. as a title).")
        case .beFilled:
            NSLocalizedString("Be Filled Songs", comment: "Display name of 'Be Filled Songs'. Usually appears just by itself (i.e. as a title).")
        case .liederbuch:
            NSLocalizedString("Liederbuch Songs", comment: "Display name of 'Liederbuch Songs'. Usually appears just by itself (i.e. as a title).")
        case .liedboek:
            NSLocalizedString("Liedboek Songs", comment: "Display name of 'Liedboek Songs'. Usually appears just by itself (i.e. as a title).")
        case .blueSongbook:
            NSLocalizedString("Songbase Songs", comment: "Display name of 'Songbase Songs'. Usually appears just by itself (i.e. as a title).")
        case .songbaseOther:
            NSLocalizedString("Songbase Songs", comment: "Display name of 'Songbase Songs'. Usually appears just by itself (i.e. as a title).")
        case .hinos:
            NSLocalizedString("Hinos Songs", comment: "Display name of 'Hinos Songs'. Usually appears just by itself (i.e. as a title).")
        case .UNRECOGNIZED:
            ""
        }
    }

    var displayLabel: String {
        switch self {
        case .classic:
            NSLocalizedString("Hymn %@", comment: "Will appear in conjunction with something else (e.g. Hymn 7).")
        case .newTune:
            NSLocalizedString("New tune %@", comment: "Will appear in conjunction with something else (e.g. New tune 7).")
        case .newSong:
            NSLocalizedString("New song %@", comment: "Will appear in conjunction with something else (e.g. New song 7).")
        case .children:
            NSLocalizedString("Children %@", comment: "Will appear in conjunction with something else (e.g. Children 7).")
        case .howardHigashi:
            NSLocalizedString("Howard Higashi (LB) %@", comment: "Will appear in conjunction with something else (e.g. Howard Higashi (LB) 7).")
        case .dutch:
            NSLocalizedString("Dutch %@", comment: "Will appear in conjunction with something else (e.g. Dutch 7).")
        case .german:
            NSLocalizedString("German %@", comment: "Will appear in conjunction with something else (e.g. German 7).")
        case .chinese:
            NSLocalizedString("Chinese %@ (Trad.)",
                              comment: "Will appear in conjunction with something else (e.g. Chinese 7 (Trad.)).")
        case .chineseSimplified:
            NSLocalizedString("Chinese %@ (Simp.)",
                              comment: "Will appear in conjunction with something else (e.g. Chinese 7 (Simp.)).")
        case .chineseSupplement:
            NSLocalizedString("Chinese Supplement %@ (Trad.)",
                              comment: "Will appear in conjunction with something else (e.g. Chinese Supplement 7 (Trad.)).")
        case .chineseSupplementSimplified:
            NSLocalizedString("Chinese Supplement %@ (Simp.)",
                              comment: "Will appear in conjunction with something else (e.g. Chinese Supplement 7 (Simp.)).")
        case .cebuano:
            NSLocalizedString("Cebuano %@", comment: "Will appear in conjunction with something else (e.g. Cebuano 7).")
        case .tagalog:
            NSLocalizedString("Tagalog %@", comment: "Will appear in conjunction with something else (e.g. Tagalog 7).")
        case .french:
            NSLocalizedString("French %@", comment: "Will appear in conjunction with something else (e.g. French 7).")
        case .spanish:
            NSLocalizedString("Spanish %@", comment: "Will appear in conjunction with something else (e.g. Spanish 7).")
        case .korean:
            NSLocalizedString("Korean %@", comment: "Will appear in conjunction with something else (e.g. Korean 7).")
        case .japanese:
            NSLocalizedString("Japanese %@", comment: "Will appear in conjunction with something else (e.g. Japanese 7).")
        case .indonesian:
            NSLocalizedString("Indonesian %@", comment: "Will appear in conjunction with something else (e.g. Indonesian 7).")
        case .farsi:
            NSLocalizedString("Farsi %@", comment: "Will appear in conjunction with something else (e.g. Farsi 7).")
        case .russian:
            NSLocalizedString("Russian %@", comment: "Will appear in conjunction with something else (e.g. Russian 7).")
        case .portuguese:
            NSLocalizedString("Portuguese %@", comment: "Will appear in conjunction with something else (e.g. Portuguese 7).")
        case .hebrew:
            NSLocalizedString("Hebrew %@", comment: "Will appear in conjunction with something else (e.g. Hebrew 7).")
        case .slovak:
            NSLocalizedString("Slovak %@", comment: "Will appear in conjunction with something else (e.g. Slovak 7).")
        case .estonian:
            NSLocalizedString("Estonian %@", comment: "Will appear in conjunction with something else (e.g. Estonian 7).")
        case .arabic:
            NSLocalizedString("Arabic %@", comment: "Will appear in conjunction with something else (e.g. Arabic 7).")
        case .beFilled:
            NSLocalizedString("Be Filled %@", comment: "Will appear in conjunction with something else (e.g. Be Filled 7).")
        case .liederbuch:
            NSLocalizedString("Liederbuch %@", comment: "Will appear in conjunction with something else (e.g. Liederbuch 7).")
        case .liedboek:
            NSLocalizedString("Liedboek %@", comment: "Will appear in conjunction with something else (e.g. Liedboek 7).")
        case .blueSongbook:
            NSLocalizedString("Songbase %@", comment: "Will appear in conjunction with something else (e.g. Songbase 7).")
        case .songbaseOther:
            NSLocalizedString("Songbase %@", comment: "Will appear in conjunction with something else (e.g. Songbase 7).")
        case .hinos:
            NSLocalizedString("Hinos %@", comment: "Will appear in conjunction with something else (e.g. Hinos 7).")
        case .UNRECOGNIZED:
            ""
        }
    }

    var language: Language {
        return switch self {
        case .classic, .newTune, .newSong, .children, .howardHigashi, .beFilled, .blueSongbook, .songbaseOther: .english
        case .dutch, .liedboek: .dutch
        case .german, .liederbuch: .german
        case .chinese, .chineseSupplement: .chineseTraditional
        case .chineseSimplified, .chineseSupplementSimplified: .chineseSimplified
        case .cebuano: .cebuano
        case .tagalog: .tagalog
        case .french: .french
        case .spanish: .spanish
        case .korean: .korean
        case .japanese: .japanese
        case .indonesian: .indonesian
        case .farsi: .farsi
        case .russian: .russian
        case .portuguese: .portuguese
        case .hebrew: .hebrew
        case .slovak: .slovak
        case .estonian: .estonian
        case .arabic: .arabic
        case .hinos: .portuguese
        case .UNRECOGNIZED(let idx): .UNRECOGNIZED(idx)
        }
    }
}

extension HymnType: CustomStringConvertible {
    var description: String { abbreviatedValue }
}

extension HymnType: Codable {

    enum HymnTypeCodingError: Error {
        case decoding(String)
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

extension Language {
    var displayTitle: String {
        return switch self {
        case .english:
            NSLocalizedString("English", comment: "Display name of the 'English' language.")
        case .dutch:
            NSLocalizedString("Dutch", comment: "Display name of the 'Dutch' language.")
        case .german:
            NSLocalizedString("German", comment: "Display name of the 'German' language.")
        case .chineseTraditional:
            NSLocalizedString("Chinese (Trad.)", comment: "Display name of the traditional 'Chinese' language.")
        case .chineseSimplified:
            NSLocalizedString("Chinese (Simp.)", comment: "Display name of the simplified 'Chinese' language.")
        case .cebuano:
            NSLocalizedString("Cebuano", comment: "Display name of the 'Cebuano' language.")
        case .tagalog:
            NSLocalizedString("Tagalog", comment: "Display name of the 'Tagalog' language.")
        case .french:
            NSLocalizedString("French", comment: "Display name of the 'French' language.")
        case .spanish:
            NSLocalizedString("Spanish", comment: "Display name of the 'Spanish' language.")
        case .korean:
            NSLocalizedString("Korean", comment: "Display name of the 'Korean' language.")
        case .japanese:
            NSLocalizedString("Japanese", comment: "Display name of the 'Japanese' language.")
        case .farsi:
            NSLocalizedString("Farsi", comment: "Display name of the 'Farsi' language.")
        case .russian:
            NSLocalizedString("Russian", comment: "Display name of the 'Russian' language.")
        case .portuguese:
            NSLocalizedString("Portuguese", comment: "Display name of the 'Portuguese' language.")
        case .hebrew:
            NSLocalizedString("Hebrew", comment: "Display name of the 'Hebrew' language.")
        case .slovak:
            NSLocalizedString("Slovak", comment: "Display name of the 'Slovak' language.")
        case .estonian:
            NSLocalizedString("Estonian", comment: "Display name of the 'Estonian' language.")
        case .arabic:
            NSLocalizedString("Arabic", comment: "Display name of the 'Arabic' language.")
        case .indonesian:
            NSLocalizedString("Indonesian", comment: "Display name of the 'Indonesian' language.")
        case .UNRECOGNIZED:
            ""
        }
    }
}

extension Language: Identifiable {
    var id: String { String(rawValue) }
}

extension Language: Codable {}
