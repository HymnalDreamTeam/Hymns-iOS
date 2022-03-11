import Combine
import Foundation
import Resolver
import SwiftUI

class VerseLineViewModel: Hashable, ObservableObject {

    @Published var fontSize: Float

    let verseNumber: String?
    let verseText: String
    let transliteration: String?

    private var disposables = Set<AnyCancellable>()

    init(verseNumber: String?, verseText: String, transliteration: String?,
         userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.verseNumber = verseNumber
        self.verseText = verseText
        self.transliteration = transliteration
        self.fontSize = userDefaultsManager.fontSize
        userDefaultsManager
            .fontSizeSubject
            .sink { fontSize in
                self.fontSize = fontSize
        }.store(in: &disposables)
    }

    static func == (lhs: VerseLineViewModel, rhs: VerseLineViewModel) -> Bool {
        lhs.verseNumber == rhs.verseNumber && lhs.verseText == rhs.verseText && lhs.transliteration == rhs.transliteration
    }

    func hash(into hasher: inout Hasher) {
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
    convenience init(verseText: String) {
        self.init(verseNumber: nil, verseText: verseText, transliteration: nil)
    }

    convenience init(verseNumber: String, verseText: String) {
        self.init(verseNumber: verseNumber, verseText: verseText, transliteration: nil)
    }

    convenience init(verseText: String, transliteration: String) {
        self.init(verseNumber: nil, verseText: verseText, transliteration: transliteration)
    }
}

extension VerseLineViewModel: CustomStringConvertible {
    var description: String {
        "verseNumber: \(String(describing: verseNumber)), verseText: \(verseText), transliteration: \(String(describing: transliteration))"
    }
}

class VerseViewModel {

    let verseLines: [VerseLineViewModel]

    init(verseNumber: String? = nil, verseLines: [String],
         transliteration: [String]? = nil, shouldTransliterate: Binding<Bool>? = nil) {
        self.verseLines = verseLines.enumerated().map { (index, line) -> VerseLineViewModel in
            let transliteration = transliteration?[index]
            return VerseLineViewModel(verseNumber: index == 0 ? verseNumber : nil, verseText: line, transliteration: transliteration)
        }
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
