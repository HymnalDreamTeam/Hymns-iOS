import Foundation

struct ChordLine: Identifiable {

    private static let chordsPattern = "\\[(.*?)\\]"

    var id = UUID()

    var hasChords: Bool {
        words.contains { chordWord in
            chordWord.chords != nil
        }
    }

    let words: [ChordWord]

    init(_ line: String) {
        let words = line.split(omittingEmptySubsequences: false, whereSeparator: \.isWhitespace)

        // If there is no chord pattern found
        let chordPatternFound = line.range(of: Self.chordsPattern, options: .regularExpression) != nil
        if !chordPatternFound {
            self.words = words.map { word in
                ChordWord(String(word), chords: nil)
            }
            return
        }

        // If there is at least one chord in the line
        self.words = words.map { word in
            let wordRange = NSRange(word.startIndex..<word.endIndex, in: word)
            let chordPattern = NSRegularExpression(Self.chordsPattern, options: [])
            let matches = chordPattern.matches(in: String(word), range: wordRange)
            if matches.isEmpty {
                return ChordWord(String(word))
            }

            let chords = matches.map { match -> String? in
                if match.numberOfRanges < 2 {
                    return nil
                }
                let matchedRange = match.range(at: 1)
                if let substringRange = Range(matchedRange, in: word) {
                    return String(word[substringRange])
                }
                return nil
            }.compactMap { $0 } // Removes nils from list

            let wordWithoutChords = word.replacingOccurrences(of: Self.chordsPattern, with: "", options: .regularExpression)
            return ChordWord(wordWithoutChords, chords: chords)
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
struct ChordWord: Identifiable {

    public let chords: [String]?
    public let word: String
    public var chordString: String? {
        guard let chords = chords else {
            return nil
        }

        let chordsString = chords.joined(separator: " ").trim()
        if word.isEmpty && chordsString.isEmpty {
            return nil
        }
        return !chordsString.isEmpty ? chordsString : " "
    }

    var id = UUID()

    init(_ word: String, chords: [String]? = [String]()) {
        self.chords = chords
        self.word = word
    }
}

extension ChordWord: Hashable, Equatable {
    static func == (lhs: ChordWord, rhs: ChordWord) -> Bool {
        lhs.word == rhs.word && lhs.chords == rhs.chords
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(chords)
    }
}
