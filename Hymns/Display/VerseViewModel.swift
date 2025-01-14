import Combine
import Foundation
import Resolver
import SwiftUI

class VerseLineViewModel: Hashable, ObservableObject {

    @Published public var fontSize: Float
    @Published var isItalicized: Bool = false

    let verseType: VerseType
    let verseNumber: String?
    let verseText: String
    let transliteration: String?

    private var disposables = Set<AnyCancellable>()

    init(verseType: VerseType, verseNumber: String? = nil, lineEntity: LineEntity,
         userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.verseType = verseType
        self.verseNumber = verseNumber
        self.verseText = lineEntity.lineContent
        self.transliteration = lineEntity.hasTransliteration ? lineEntity.transliteration: nil

        if verseType == .note {
            self.fontSize = userDefaultsManager.fontSize * 0.7
            isItalicized = true
        } else {
            self.fontSize = userDefaultsManager.fontSize
            isItalicized = false
        }
        userDefaultsManager
            .fontSizeSubject
            .sink { fontSize in
                if verseType == .note {
                    self.fontSize = fontSize * 0.7
                    self.isItalicized = true
                } else {
                    self.fontSize = fontSize
                    self.isItalicized = false
                }
        }.store(in: &disposables)
    }

    static func == (lhs: VerseLineViewModel, rhs: VerseLineViewModel) -> Bool {
        lhs.verseType == rhs.verseType && lhs.verseNumber == rhs.verseNumber && lhs.verseText == rhs.verseText && lhs.transliteration == rhs.transliteration
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(verseType)
        if let verseNumber = verseNumber {
            hasher.combine(verseNumber)
        }
        hasher.combine(verseText)
        if let transliteration = transliteration {
            hasher.combine(transliteration)
        }
    }
}

extension VerseLineViewModel {
    convenience init(verseType: VerseType, verseNumber: String? = nil, verseText: String, transliteration: String? = nil) {
        self.init(verseType: verseType, verseNumber: verseNumber, lineEntity: LineEntity(lineContent: verseText, transliteration: transliteration))
    }
}

extension VerseLineViewModel: CustomStringConvertible {
    var description: String {
        "verseType: \(verseType), verseNumber: \(String(describing: verseNumber)), verseText: \(verseText), transliteration: \(String(describing: transliteration))"
    }
}

class VerseViewModel {

    let verseLines: [VerseLineViewModel]

    init(verseType: VerseType, verseNumber: String?, verseLines: [LineEntity], shouldTransliterate: Binding<Bool>? = nil) {
        self.verseLines = verseLines.enumerated().map { (index, lineEntity) -> VerseLineViewModel in
            return VerseLineViewModel(verseType: verseType, verseNumber: index == 0 ? verseNumber : nil, lineEntity: lineEntity)
        }
    }
}

extension VerseViewModel {
    convenience init(verseType: VerseType, verseNumber: String, verseLines: [String], shouldTransliterate: Binding<Bool>? = nil) {
        self.init(verseType: verseType, verseNumber: verseNumber, verseLines: verseLines.map({ lineContent in
            LineEntity(lineContent: lineContent)
        }), shouldTransliterate: shouldTransliterate)
    }
}

extension VerseViewModel {

    /**
     * Makes the verse into a formatted string. Used to send to the clipboard if a user long presses the verse.
     */
    public func createFormattedString(includeTransliteration: Bool) -> String {
        var string = ""
        for verseLine in verseLines {
            if let transliteration = verseLine.transliteration, includeTransliteration {
                string.append(transliteration)
                string.append("\n")
            }
            string.append(verseLine.verseText)
            string.append("\n")
        }
        return string
    }
}

extension VerseViewModel: Hashable {
    static func == (lhs: VerseViewModel, rhs: VerseViewModel) -> Bool {
        lhs.verseLines == rhs.verseLines
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(verseLines)
    }
}

extension VerseViewModel: CustomStringConvertible {
    var description: String {
        verseLines.map { $0.description }.joined(separator: "|")
    }
}
