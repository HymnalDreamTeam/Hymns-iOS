import Foundation

/// Structure of a Verse object from Hymnal.net
struct Verse: Codable, Equatable {
    let verseType: VerseType
    let verseContent: [String]
    let transliteration: [String]?

    init(verseType: VerseType, verseContent: [String], transliteration: [String]? = nil) {
        self.verseType = verseType
        self.verseContent = verseContent
        self.transliteration = transliteration
    }
}

extension VerseType: Codable {
    
    enum VerseTypeCodingError: Error {
        case decoding(String)
    }

    // Decoding an enum: https://stackoverflow.com/a/48204890/1907538
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = switch(value) {
        case "verse": .verse
        case "chorus": .chorus
        case "other": .other
        case "copyright": .copyright
        case "note": .note
        case "doNotDisplay": .doNotDisplay
        default: throw VerseTypeCodingError.decoding("Unrecognized verse type: \(value)")
        }
    }
}

extension VerseEntity {
    init(verseType: VerseType, lines: [LineEntity]) {
        self.verseType = verseType
        self.lines = lines
    }
}

extension VerseEntity {
    init(verseType: VerseType, lineStrings: [String]) {
        self.verseType = verseType
        self.lines = lineStrings.map({ LineEntity(lineContent: $0)})
    }
}
