import Foundation

/// Structure of a Verse object from Hymnal.net
struct Verse: Codable, Equatable, Hashable {
    let verseType: VerseType
    let verseContent: [String]
    let transliteration: [String]?
}

extension Verse {
    // Allows us to use a customer initializer along with the default memberwise one
    // https://www.hackingwithswift.com/articles/106/10-quick-swift-tips
    init(verseType: VerseType, verseContent: [String]) {
        self.verseType = verseType
        self.verseContent = verseContent
        self.transliteration = nil
    }
}

/// Structure of a Verse object represented in the app, as well as in the bundled database
struct VerseEntity: Codable, Equatable {
    let verseType: VerseType
    let lines: [LineEntity]

    init(verseType: VerseType, lines: [LineEntity]) {
        self.verseType = verseType
        self.lines = lines
    }
}

extension VerseEntity {
    init(verseType: VerseType, lineStrings: [String]) {
        self.init(verseType: verseType, lines: lineStrings.map({ LineEntity(lineContent: $0)}))
    }
}
