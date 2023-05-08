import Foundation

struct LineEntity: Codable, Equatable {
    let lineContent: String
    let transliteration: String?

    init(lineContent: String, transliteration: String? = nil) {
        self.lineContent = lineContent
        self.transliteration = transliteration
    }
}
