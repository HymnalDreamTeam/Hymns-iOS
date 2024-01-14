import Combine
import Foundation
import Resolver

class DisplayHymnBottomBarViewModel: ObservableObject {

    /**
     * Threshold for determining if there should be an overflow menu or not
     */
    public var overflowThreshold = 6

    @Published var buttons: [BottomBarButton]
    @Published var overflowButtons: [BottomBarButton]?

    let identifier: HymnIdentifier

    private let analytics: FirebaseLogger
    private let systemUtil: SystemUtil

    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier,
         hymn: UiHymn,
         analytics: FirebaseLogger = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.analytics = analytics
        self.identifier = identifier
        self.systemUtil = systemUtil
        self.buttons = [BottomBarButton]()

        // For small screen, lower the number of tabs to 5.
        if systemUtil.isSmallScreen() {
            overflowThreshold = 5
        }

        populateButtons(hymn)
    }

    private func populateButtons(_ hymn: UiHymn) {
        var buttons = [BottomBarButton]()

        if let lyrics = hymn.lyrics {
            buttons.append(.share(self.convertToOneString(verses: lyrics)))
        }

        buttons.append(.fontSize(FontPickerViewModel()))

        let languages = self.convertLanguagesToSongResults(hymn.languages)
        if !languages.isEmpty {
            buttons.append(.languages(languages))
        }

        let mp3Path = hymn.music?[DatumValue.mp3.rawValue]
        if let mp3Url = mp3Path.flatMap({ path -> URL? in
            URLComponents(string: path)?.url
        }), self.systemUtil.isNetworkAvailable() {
            buttons.append(.musicPlayback(AudioPlayerViewModel(url: mp3Url)))
        }

        let relevant = self.convertRelevantsToSongResults(hymn.relevant)
        if !relevant.isEmpty {
            buttons.append(.relevant(relevant))
        }

        buttons.append(.tags)

        if let title = hymn.title, let url = "https://soundcloud.com/search/results?q=\(title)".toEncodedUrl,
            self.systemUtil.isNetworkAvailable() {
            buttons.append(.soundCloud(SoundCloudViewModel(url: url)))
        }

        if let title = hymn.title, let url = "https://www.youtube.com/results?search_query=\(title)".toEncodedUrl,
            self.systemUtil.isNetworkAvailable() {
            buttons.append(.youTube(url))
        }

        if let songInfo = SongInfoDialogViewModel(hymnToDisplay: self.identifier, hymn: hymn) {
            buttons.append(.songInfo(songInfo))
        }

        self.buttons = [BottomBarButton]()
        if buttons.count > self.overflowThreshold {
            self.buttons.append(contentsOf: buttons[0..<(self.overflowThreshold - 1)])
            var overflowButtons = [BottomBarButton]()
            overflowButtons.append(contentsOf: buttons[(self.overflowThreshold - 1)..<buttons.count])
            self.overflowButtons = overflowButtons
        } else {
            self.buttons.append(contentsOf: buttons)
            self.overflowButtons = nil
        }
    }

    private func convertLanguagesToSongResults(_ languages: [HymnIdentifier]?) -> [SongResultViewModel] {
        guard var languages = languages else {
            return [SongResultViewModel]()
        }

        // If both German and Liederbuch exist, then remove German and show only
        // Liederbuch. This is because they likely both point to the same song
        // but with different numbering, which is confusing to the user.
        if languages.map({ language in
            language.hymnType
        }).filter({ hymnType in
            hymnType == .german || hymnType == .liederbuch
        }).count > 1 {
            languages.removeAll { language in
                language.hymnType == .german
            }
        }
        return languages.map { language in
            let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: language)).eraseToAnyView()
            return SongResultViewModel(stableId: String(describing: language),
                                       title: String(format: language.hymnType.displayLabel, language.hymnNumber),
                                       destinationView: destination)
        }
    }

    private func convertRelevantsToSongResults(_ relevants: [HymnIdentifier]?) -> [SongResultViewModel] {
        guard let relevants = relevants else {
            return [SongResultViewModel]()
        }

        return relevants.map { relevant in
            let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: relevant)).eraseToAnyView()
            return SongResultViewModel(stableId: String(describing: relevant), title: relevant.displayTitle, destinationView: destination)
        }
    }

    private func convertToOneString(verses: [VerseEntity]) -> String {
        verses.flatMap { verse in
            verse.lines
        }.compactMap { line in
            line.lineContent
        }.joined(separator: "\n")
    }
}

extension DisplayHymnBottomBarViewModel: Equatable {
    static func == (lhs: DisplayHymnBottomBarViewModel, rhs: DisplayHymnBottomBarViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
