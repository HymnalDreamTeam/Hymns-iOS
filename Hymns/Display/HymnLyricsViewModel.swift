import Combine
import Foundation
import Resolver

class HymnLyricsViewModel: ObservableObject {

    @UserDefault("repeat_chorus", defaultValue: false) var shouldRepeatChorus: Bool

    @Published var lyrics: [VerseViewModel]? = [VerseViewModel]()
    @Published var showTransliterationButton = false

    private let identifier: HymnIdentifier
    private let mainQueue: DispatchQueue
    private let repository: HymnsRepository

    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier,
         hymnsRepository repository: HymnsRepository = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self.identifier = identifier
        self.mainQueue = mainQueue
        self.repository = repository
    }

    func fetchLyrics() {
        var latestValue: [VerseViewModel]? = [VerseViewModel]()
        var showTransliterationButton = false
        repository
            .getHymn(identifier)
            .map({ [weak self] hymn -> [VerseViewModel]? in
                guard let self = self, let hymn = hymn, let lyrics = hymn.lyrics, !lyrics.isEmpty else {
                    return nil
                }
                return self.convertToViewModels(verses: lyrics)
            })
            .receive(on: mainQueue)
            .sink(receiveCompletion: { [weak self] state in
                guard let self = self else { return }
                if state == .finished {
                    // Only display the lyrics if the call is finished and we aren't getting any more values
                    self.lyrics = latestValue
                    self.showTransliterationButton = showTransliterationButton
                }
                }, receiveValue: { [weak self ] lyrics in
                    guard let self = self else { return }
                    latestValue = lyrics
                    showTransliterationButton = self.containsTransliteration(viewModels: lyrics)
            }).store(in: &disposables)
    }

    func convertToViewModels(verses: [Verse]) -> [VerseViewModel] {
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

    private func containsTransliteration(viewModels: [VerseViewModel]?) -> Bool {
        guard
            let viewModels = viewModels,
            let firstViewModel = viewModels.first,
            let firstLine = firstViewModel.verseLines.first else {
                return false
        }
        return firstLine.transliteration != nil
    }
}
