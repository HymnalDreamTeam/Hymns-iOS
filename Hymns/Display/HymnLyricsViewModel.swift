import Combine
import Foundation
import Resolver
import SwiftUI

class HymnLyricsViewModel: ObservableObject {

    @Published var showTransliterationButton = false
    @Published var transliterate = false
    @Published var lyricsString: NSAttributedString = NSMutableAttributedString(string: "")

    private let identifier: HymnIdentifier
    private let userDefaultsManager: UserDefaultsManager

    private var disposables = Set<AnyCancellable>()

    init?(hymnToDisplay identifier: HymnIdentifier, lyrics: [VerseEntity]?,
          userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        guard let lyrics = lyrics else {
            return nil
        }

        self.identifier = identifier
        self.userDefaultsManager = userDefaultsManager

        self.showTransliterationButton = lyrics.first.flatMap { firstVerse in
            firstVerse.lines.first
        }.flatMap { fisrtLine in
            fisrtLine.transliteration
        } != nil

        guard let lyricsString = createAttributedString(verses: lyrics, fontSize: userDefaultsManager.fontSize) else {
            return nil
        }
        self.lyricsString = lyricsString

        userDefaultsManager
            .fontSizeSubject
            .sink { fontSize in
                if let lyricsString = self.createAttributedString(verses: lyrics, fontSize: fontSize) {
                    self.lyricsString = lyricsString
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
        paragraphStyle.paragraphSpacing = UIFont.systemFont(ofSize: CGFloat(fontSize)).lineHeight * 0.5
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
            case .copyright, .doNotDisplay, .other:
                continue
            }
            label.map { label in
                lyricsString.append(
                    NSAttributedString(string: "\(label)\n",
                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize) * 0.8, weight: .bold),
                                                    NSAttributedString.Key.foregroundColor: UIColor(Color.gray),
                                                    NSAttributedString.Key.paragraphStyle: paragraphStyle]))
            }
            let font = verse.verseType == .note ? UIFont.italicSystemFont(ofSize: CGFloat(fontSize * 0.7)) :
                                                  UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)
            for line in verse.lines {
                if let transliteration = line.transliteration, transliterate {
                    lyricsString.append(NSAttributedString(string: "\(transliteration)\n",
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
