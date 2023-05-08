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

        let languages = self.convertToSongResults(hymn.languages)
        if !languages.isEmpty {
            buttons.append(.languages(languages))
        }

        let mp3Path = hymn.music?[DatumValue.mp3.rawValue]
        if let mp3Url = mp3Path.flatMap({ path -> URL? in
            HymnalNet.url(path: path)
        }), self.systemUtil.isNetworkAvailable() {
            buttons.append(.musicPlayback(AudioPlayerViewModel(url: mp3Url)))
        }

        let relevant = self.convertToSongResults(hymn.relevant)
        if !relevant.isEmpty {
            buttons.append(.relevant(relevant))
        }

        buttons.append(.tags)

        if let url = "https://soundcloud.com/search/results?q=\(hymn.title)".toEncodedUrl,
            self.systemUtil.isNetworkAvailable() {
            buttons.append(.soundCloud(SoundCloudViewModel(url: url)))
        }

        if let url = "https://www.youtube.com/results?search_query=\(hymn.title)".toEncodedUrl,
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

    private func convertToSongResults(_ songLinks: [SongLink]?) -> [SongResultViewModel] {
        guard let songLinks = songLinks else {
            return [SongResultViewModel]()
        }

        return songLinks.map { songLink in
            let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: songLink.reference)).eraseToAnyView()
            return SongResultViewModel(stableId: String(describing: songLink.reference), title: songLink.name, destinationView: destination)
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
