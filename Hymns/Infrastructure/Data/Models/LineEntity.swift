import Foundation

extension LineEntity {
    init(lineContent: String) {
        self.lineContent = lineContent
    }

    init(lineContent: String, transliteration: String?) {
        self.lineContent = lineContent
        if let transliteration = transliteration {
            self.transliteration = transliteration
        }
    }
}
