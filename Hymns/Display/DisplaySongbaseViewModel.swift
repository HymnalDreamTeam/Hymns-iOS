import Combine
import Foundation
import Resolver

class DisplaySongbaseViewModel: ObservableObject {

    @Published var chords: [ChordLine] = [ChordLine]()

    private let analytics: AnalyticsLogger
    private let backgroundQueue: DispatchQueue
    private let bookId: Int
    private let bookIndex: Int
    private let mainQueue: DispatchQueue
    private let repository: HymnsRepository

    private var disposables = Set<AnyCancellable>()

    init(analytics: AnalyticsLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         bookId: Int,
         bookIndex: Int,
         hymnsRepository repository: HymnsRepository = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.bookId = bookId
        self.bookIndex = bookIndex
        self.mainQueue = mainQueue
        self.repository = repository
    }

    func fetchHymn() {
        repository
            .getSongbase(bookId: bookId, bookIndex: bookIndex)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(
                receiveValue: { [weak self] song in
                    guard let self = self else { return }
                    guard let song = song else { return }
                    // split lyrics up by new line
                    self.chords = song.chords.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map {  ChordLine(String($0)) }
                }).store(in: &disposables)
    }
}

struct ChordLine: Identifiable {

    var id = UUID()

    let words: [ChordWord]

    init(_ line: String) {
        let words = line.split(omittingEmptySubsequences: false, whereSeparator: \.isWhitespace)

        // If there is no chord pattern found
        let chordPatternFound = line.range(of: SongbaseSong.chordsPattern, options: .regularExpression) != nil
        if !chordPatternFound {
            self.words = words.map { word in
                ChordWord(String(word), chords: nil)
            }
            return
        }

        // If there is at least one chord in the line
        self.words = words.map { word in
            let wordRange = NSRange(word.startIndex..<word.endIndex, in: word)
            let chordPattern = NSRegularExpression(SongbaseSong.chordsPattern, options: [])
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

            let wordWithoutChords = word.replacingOccurrences(of: SongbaseSong.chordsPattern,
                                                              with: "", options: .regularExpression)
            return ChordWord(wordWithoutChords, chords: chords)
        }
    }
}

/// Represents a word that could optionally have a chord associated with it.
struct ChordWord: Hashable, Identifiable {

    public let chords: [String]?
    public let word: String
    public var chordString: String? {
        guard let chords = chords else {
            return nil
        }

        let chordsString = chords.joined(separator: " ")
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
