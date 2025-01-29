import Combine
import Foundation
import Resolver
import SwiftUI

class HymnLyricsViewModel: ObservableObject {

    @Published var showTransliterationButton = false
    @Published var transliterate = false
    @Published var lyrics: NSAttributedString = NSMutableAttributedString(string: "")

    private let identifier: HymnIdentifier
    private let mainQueue: DispatchQueue
    private let userDefaultsManager: UserDefaultsManager

    private var disposables = Set<AnyCancellable>()

    init?(hymnToDisplay identifier: HymnIdentifier, lyrics: [VerseEntity]?,
          mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
          userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.identifier = identifier
        self.mainQueue = mainQueue
        self.userDefaultsManager = userDefaultsManager

        guard let lyrics = lyrics, !lyrics.isEmpty else {
            return nil
        }

        self.showTransliterationButton = lyrics.first.flatMap { firstVerse in
            firstVerse.lines.first
        }.flatMap { fisrtLine in
            fisrtLine.hasTransliteration
        } ?? false

        $transliterate
            .receive(on: mainQueue)
            .sink { _ in
                if let lyrics = self.createAttributedString(verses: lyrics, fontSize: userDefaultsManager.fontSize) {
                    self.lyrics = lyrics
                }
        }.store(in: &disposables)

        userDefaultsManager
            .fontSizeSubject
            .sink { fontSize in
                if let lyrics = self.createAttributedString(verses: lyrics, fontSize: fontSize) {
                    self.lyrics = lyrics
                }
            }.store(in: &disposables)
    }

    private func createAttributedString(verses: [VerseEntity], fontSize: Float) -> NSAttributedString? {
        let lyrics: [VerseEntity]
        if userDefaultsManager.shouldRepeatChorus {
            lyrics = duplicateChorus(verses)
        } else {
            lyrics = verses
        }
        let lyricsString = NSMutableAttributedString(string: "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = UIFont.systemFont(ofSize: CGFloat(fontSize)).lineHeight * 0.4
        paragraphStyle.paragraphSpacing = UIFont.systemFont(ofSize: CGFloat(fontSize)).lineHeight * 0.1
        var verseNumber = 0
        for verse in lyrics {
            let label: String?
            switch verse.verseType {
            case .verse:
                verseNumber += 1
                label = "\(verseNumber)"
            case .chorus:
                label = NSLocalizedString("Chorus", comment: "Indicator that that the verse is of type 'chorus'.")
            case .note:
                label = nil
            case .other:
                label = NSLocalizedString("Other", comment: "Indicator that that the verse is of type 'other'.")
            case .copyright, .doNotDisplay, .UNRECOGNIZED:
                continue
            }
            label.map { label in
                lyricsString.append(
                    NSAttributedString(string: "\(label)\n",
                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize) * 0.80, weight: .bold),
                                                    NSAttributedString.Key.foregroundColor: UIColor(Color.gray),
                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            }
            let font = verse.verseType == .note ? UIFont.italicSystemFont(ofSize: CGFloat(fontSize * 0.7)) :
            UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)
            for line in verse.lines {
                if line.hasTransliteration, !line.transliteration.isEmpty, transliterate {
                    lyricsString.append(NSAttributedString(string: "\(line.transliteration)\n",
                                                           attributes: [NSAttributedString.Key.font: font,
                                                                        NSAttributedString.Key.foregroundColor: UIColor(Color.primary),
                                                                        NSAttributedString.Key.paragraphStyle: paragraphStyle]))
                }
                lyricsString.append(NSAttributedString(string: "\(line.lineContent)\n",
                                                       attributes: [NSAttributedString.Key.font: font,
                                                                    NSAttributedString.Key.foregroundColor: UIColor(Color.primary),
                                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            }
            lyricsString.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: font]))
        }
        if lyricsString.string.isEmpty {
            return nil
        }
        return lyricsString
    }

    private func duplicateChorus(_ verses: [VerseEntity]) -> [VerseEntity] {
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

        var newVerses = [VerseEntity]()
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
