import Combine
import Resolver

class ChordLineViewModel: ObservableObject, Identifiable {

    @Published var chordWords: [ChordWordViewModel]

    var id = UUID()

    var hasChords: Bool {
        chordWords.contains { chordWord in
            chordWord.chords != nil && !chordWord.chords!.trim().isEmpty
        }
    }

    init(chordLine: ChordLineEntity) {
        self.chordWords = chordLine.chordWords.map({ chordWord in
            ChordWordViewModel(chordWord)
        })
    }

    func transpose(_ steps: Int) {
        chordWords.forEach { chordWord in
            chordWord.transpose(steps)
        }
    }
}

extension ChordLineViewModel: Hashable, Equatable {
    static func == (lhs: ChordLineViewModel, rhs: ChordLineViewModel) -> Bool {
        lhs.chordWords == rhs.chordWords
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(chordWords)
    }
}

extension ChordLineViewModel: CustomStringConvertible {
    var description: String {
        "\(chordWords)"
    }
}

class ChordWordViewModel: ObservableObject, Identifiable {
    
    private static let chordsTransposingPattern = "([^A-G]*)([A-G][#b]?)([^A-G]*)"

    @Published var fontSize: Float
    @Published var chords: String?
    public let word: String

    var id = UUID()
    private var disposables = Set<AnyCancellable>()

    init(_ chordWord: ChordWordEntity, userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.chords = chordWord.hasChords ? chordWord.chords : nil
        self.word = chordWord.word
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
        self.chords = matches.compactMap { match -> String? in
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
        }.reduce("", { partialResult, newChords in
            return partialResult + newChords
        })
    }
}

extension ChordWordViewModel: Hashable, Equatable {
    static func == (lhs: ChordWordViewModel, rhs: ChordWordViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChordWordViewModel: CustomStringConvertible {
    var description: String {
        "word: \(word), chords: \(String(describing: chords)), fontSize: \(fontSize)"
    }
}
