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
            chordWord.chords != nil && !chordWord.chords!.trim().isEmpty
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

    func transpose(_ steps: Int) {
        words.forEach { chordWord in
            chordWord.transpose(steps)
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

    private static let chordsTransposingPattern = "([^A-G]*)([A-G][#b]?)([^A-G]*)"

    @Published var fontSize: Float
    @Published var chords: String?
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

    func transpose(_ steps: Int) {
        guard let chords = chords else {
            return
        }
        let range = NSRange(chords.startIndex..<chords.endIndex, in: chords)
        let pattern = NSRegularExpression(Self.chordsTransposingPattern, options: [])
        let matches = pattern.matches(in: chords, range: range)
        self.chords = matches.map { match -> String? in
            if match.numberOfRanges < 4 {
                return nil
            }

            var newChords = ""
            if let beforeChordRange = Range(match.range(at: 1), in: chords) {
                newChords += String(chords[beforeChordRange])
            }

            if let chordRange = Range(match.range(at: 2), in: chords), let chord = Chord(rawValue: String(chords[chordRange])) {
                var newChord = chord
                for _ in 0..<abs(steps) {
                    newChord = steps > 0 ? newChord.transposeUp() : newChord.transposeDown()
                }
                newChords += newChord.rawValue
            }

            if let afterChordRange = Range(match.range(at: 3), in: chords) {
                newChords += String(chords[afterChordRange])
            }
            return newChords
        }.compactMap { $0 }.reduce("", { partialResult, newChords in
            return partialResult + newChords
        })
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

extension ChordWord: CustomStringConvertible {
    var description: String {
        "word: \(word), chords: \(String(describing: chords)), fontSize: \(fontSize)"
    }
}

// swiftlint:disable identifier_name cyclomatic_complexity
enum Chord: String {
    case aFlat = "Ab"
    case a = "A"
    case aSharp = "A#"
    case bFlat = "Bb"
    case b = "B"
    case c = "C"
    case cSharp = "C#"
    case dFlat = "Db"
    case d = "D"
    case dSharp = "D#"
    case eFlat = "Eb"
    case e = "E"
    case f = "F"
    case fSharp = "F#"
    case gFlat = "Gb"
    case g = "G"
    case gSharp = "G#"

    func transposeUp() -> Chord {
        switch self {
        case .gSharp, .aFlat:
            return .a
        case .a:
            return .aSharp
        case .aSharp, .bFlat:
            return .b
        case .b:
            return .c
        case .c:
            return .cSharp
        case .cSharp, .dFlat:
            return .d
        case .d:
            return .dSharp
        case .dSharp, .eFlat:
            return .e
        case .e:
            return .f
        case .f:
            return .fSharp
        case .fSharp, .gFlat:
            return .g
        case .g:
            return .gSharp
        }
    }

    func transposeDown() -> Chord {
        switch self {
        case .g:
            return .gFlat
        case .gFlat, .fSharp:
            return .f
        case .f:
            return .e
        case .e:
            return .eFlat
        case .eFlat, .dSharp:
            return .d
        case .d:
            return .dFlat
        case .dFlat, .cSharp:
            return .c
        case .c:
            return .b
        case .b:
            return .bFlat
        case .bFlat, .aSharp:
            return .a
        case .a:
            return .aFlat
        case .aFlat, .gSharp:
            return .g
        }
    }
}
// swiftlint:enagle identifier_name cyclomatic_complexity
