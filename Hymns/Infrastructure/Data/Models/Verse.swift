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

/// Structure of a Verse object represented in the app, as well as in the bundled database
struct VerseEntity: Codable, Equatable {
    let verseType: VerseType
    let lines: [LineEntity]
}

extension VerseEntity {
    init(verseType: VerseType, lineStrings: [String]) {
        self.init(verseType: verseType, lines: lineStrings.map({ LineEntity(lineContent: $0)}))
    }
}
