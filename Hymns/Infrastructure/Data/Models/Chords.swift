import Combine
import Foundation
import Resolver

struct ChordLine: Identifiable {

    // Separates chord line out into words.
    // Note: ?: represents a non-matching group. i.e. the regex matches, but the range isn't extracted.
    private static let separatorPattern = "(\\S*(?:\\[.*?])\\S*|\\S+)"
    private static let chordsPattern = "\\[(.*?)]"

    var id = UUID()

    var hasChords: Bool {
        words.contains { chordWord in
            chordWord.chords != nil
        }
    }

    let words: [ChordWord]

    init(_ line: String) {
        if line.isEmpty {
            self.words = [ChordWord("", chords: nil)]
            return
        }

        let range = NSRange(line.startIndex..<line.endIndex, in: line)
        let pattern = NSRegularExpression(Self.separatorPattern, options: [])
        let matches = pattern.matches(in: line, range: range)

        let chordWords = matches.map { match -> String? in
            if match.numberOfRanges < 1 {
                return nil
            }
            let matchedRange = match.range(at: 0)
            if let substringRange = Range(matchedRange, in: line) {
                return String(line[substringRange])
            }
            return nil
        }.compactMap { $0 }
        // If there is no chord pattern found
        let chordPatternFound = line.range(of: Self.chordsPattern, options: .regularExpression) != nil
        if !chordPatternFound {
            self.words = chordWords.map { word in
                ChordWord(String(word), chords: nil)
            }
            return
        }

        self.words = chordWords.map { chordWord in
            let chordPattern = NSRegularExpression(Self.chordsPattern, options: [])

            var word = chordWord
            var chords = ""
            var match = chordPattern.firstMatch(in: word, range: NSRange(word.startIndex..<word.endIndex, in: word))
            while match != nil {
                if match!.numberOfRanges < 2 {
                    continue
                }
                let matchedRange = Range(match!.range(at: 0), in: word) // Entire match (e.g.: [G])
                let chordRange = Range(match!.range(at: 1), in: word) // Only the chord portion (e.g.: G)
                guard let matchedRange = matchedRange, let chordRange = chordRange else {
                    continue
                }
                let chord = String(word[chordRange])
                let index = matchedRange.lowerBound.utf16Offset(in: word)
                while chords.count < index {
                    chords.append(" ")
                }
                chords.append(chord)
                word = word.replacingCharacters(in: matchedRange, with: "")
                match = chordPattern.firstMatch(in: word, range: NSRange(word.startIndex..<word.endIndex, in: word))
            }
            return ChordWord(word, chords: chords)
        }
    }
}

extension ChordLine: Hashable, Equatable {
    static func == (lhs: ChordLine, rhs: ChordLine) -> Bool {
        lhs.words == rhs.words
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(words)
    }
}

/// Represents a word that could optionally have a chord associated with it.
class ChordWord: Identifiable, ObservableObject {

    @Published var fontSize: Float
    public let chords: String?
    public let word: String

    var id = UUID()
    private var disposables = Set<AnyCancellable>()

    init(_ word: String, chords: String?,
         userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.chords = chords
        self.word = word
        self.fontSize = userDefaultsManager.fontSize
        userDefaultsManager
            .fontSizeSubject
            .sink { fontSize in
                self.fontSize = fontSize
        }.store(in: &disposables)
    }
}

extension ChordWord: Hashable, Equatable {
    static func == (lhs: ChordWord, rhs: ChordWord) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
