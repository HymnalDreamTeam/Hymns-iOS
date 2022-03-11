import Combine
import Foundation
import Resolver

class HymnLyricsViewModel: ObservableObject {

    @UserDefault("repeat_chorus", defaultValue: false) var shouldRepeatChorus: Bool

    @Published var lyrics: [VerseViewModel] = [VerseViewModel]()
    @Published var showTransliterationButton = false

    private let identifier: HymnIdentifier

    private var disposables = Set<AnyCancellable>()

    init?(hymnToDisplay identifier: HymnIdentifier, lyrics: [Verse]?) {
        self.identifier = identifier

        guard let lyrics = lyrics else {
            return nil
        }

        let viewModels = convertToViewModels(lyrics)
        self.lyrics = viewModels
        self.showTransliterationButton = viewModels.first.flatMap { fisrtVerse in
            fisrtVerse.verseLines.first
        }.flatMap { fisrtLine in
            fisrtLine.transliteration
        } != nil

        if viewModels.isEmpty {
            return nil
        }
    }

    private func convertToViewModels(_ verses: [Verse]) -> [VerseViewModel] {
        let lyrics: [Verse]
        if self.shouldRepeatChorus {
            lyrics = duplicateChorus(verses)
        } else {
            lyrics = verses
        }

        var verseViewModels = [VerseViewModel]()
        var verseNumber = 0
        for verse in lyrics {
            if verse.verseType == .chorus || verse.verseType == .other {
                verseViewModels.append(VerseViewModel(verseLines: verse.verseContent, transliteration: verse.transliteration))
            } else {
                verseNumber += 1
                verseViewModels.append(VerseViewModel(verseNumber: "\(verseNumber)", verseLines: verse.verseContent, transliteration: verse.transliteration))
            }
        }
        return verseViewModels
    }

    private func duplicateChorus(_ verses: [Verse]) -> [Verse] {
        let choruses = verses.filter { verse -> Bool in
            verse.verseType == .chorus
        }
        if choruses.count > 1 {
            // There is more than 1 chorus, so don't duplicate anything
            return verses
        }

        guard let chorus = choruses.first else {
            // There are no choruses in this song, so there is nothing to duplicate
            return verses
        }

        var newVerses = [Verse]()
        for (index, verse) in verses.enumerated() {
            newVerses.append(verse)
            if verse.verseType != .verse {
                // Don't duplicate the chorus for non-verses
                continue
            }

            if verse == verses.last && verse.verseType != .chorus {
                // last verse is not a chorus, so add in a chorus
                newVerses.append(chorus)
            } else {
                let nextVerse = verses[index + 1]
                if nextVerse.verseType != .chorus {
                    newVerses.append(chorus)
                }
            }
        }
        return newVerses
    }
}
