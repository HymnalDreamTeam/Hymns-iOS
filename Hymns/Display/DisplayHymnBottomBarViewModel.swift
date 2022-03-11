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

    private let analytics: AnalyticsLogger
    private let systemUtil: SystemUtil

    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier,
         hymn: UiHymn,
         analytics: AnalyticsLogger = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.analytics = analytics
        self.identifier = identifier
        self.systemUtil = systemUtil
        self.buttons = [BottomBarButton]()

        // For small screen, lower the number of tabs to 5.
        if systemUtil.isSmallScreen() {
            overflowThreshold = 5
        }

        populateHymn(hymn)
    }

    func populateHymn(_ hymn: UiHymn) {
        var buttons = [BottomBarButton]()

        if let lyrics = hymn.lyrics {
            buttons.append(.share(self.convertToOneString(verses: lyrics)))
        }

        buttons.append(.fontSize(FontPickerViewModel()))

        let languages = self.convertToSongResults(hymn.languages)
        if !languages.isEmpty {
            buttons.append(.languages(languages))
        }

        let mp3Path = hymn.music?.data.first(where: { datum -> Bool in
            datum.value == DatumValue.mp3.rawValue
        })?.path
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

        let songInfo = SongInfoDialogViewModel(hymnToDisplay: self.identifier, hymn: hymn)
        if let songInfo = songInfo {
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

    private func convertToSongResults(_ option: MetaDatum?) -> [SongResultViewModel] {
        option.map { metaDatum -> [SongResultViewModel] in
            metaDatum.data.compactMap {datum -> SongResultViewModel? in
                guard let hymnType = RegexUtil.getHymnType(path: datum.path), let hymnNumber = RegexUtil.getHymnNumber(path: datum.path) else {
                    self.analytics.logError(message: "error happened when trying to parse song language", extraParameters: ["path": datum.path, "value": datum.value])
                    return nil
                }
                let queryParams = RegexUtil.getQueryParams(path: datum.path)
                let title = datum.value
                let hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber, queryParams: queryParams)
                let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymnIdentifier)).eraseToAnyView()
                return SongResultViewModel(stableId: String(describing: hymnIdentifier), title: title, destinationView: destination)
            }
        }  ?? [SongResultViewModel]()
    }

    private func convertToOneString(verses: [Verse]) -> String {
        verses.flatMap { verse in
            verse.verseContent
        }.joined(separator: "\n")
    }
}

extension DisplayHymnBottomBarViewModel: Equatable {
    static func == (lhs: DisplayHymnBottomBarViewModel, rhs: DisplayHymnBottomBarViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
