import Combine
import Foundation
import Resolver

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
// swiftlint:enable identifier_name cyclomatic_complexity

extension ChordLineEntity {
    init(_ chordWords: [ChordWordEntity]) {
        self.chordWords = chordWords
    }
}

extension ChordLineEntity {
    var hasChords: Bool {
        chordWords.contains { chordWord in
            chordWord.hasChords && !chordWord.chords.trim().isEmpty
        }
    }
}

extension ChordWordEntity {

    init(_ word: String) {
        self.word = word
    }

    init(_ word: String, chords: String) {
        self.word = word
        self.chords = chords
    }
}
