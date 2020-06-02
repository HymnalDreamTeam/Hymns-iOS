import Combine
import Foundation
import Resolver

class DisplayHymnBottomBarViewModel: ObservableObject {

    typealias Title = String
    @Published var songInfo: SongInfoDialogViewModel
    @Published var shareableLyrics: String = ""
    @Published var languages = [SongResultViewModel]()
    @Published var relevant = [SongResultViewModel]()
    @Published var tags = [TagSheetView]()
    @Published var mp3Path: URL?
    @Published var title: String = ""

    private let analytics: AnalyticsLogger
    let identifier: HymnIdentifier
    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let repository: HymnsRepository

    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier,
         analytics: AnalyticsLogger = Resolver.resolve(),
         hymnsRepository repository: HymnsRepository = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background")) {
        self.analytics = analytics
        self.identifier = identifier
        self.songInfo = SongInfoDialogViewModel(hymnToDisplay: identifier)
        self.mainQueue = mainQueue
        self.repository = repository
        self.backgroundQueue = backgroundQueue
    }

    func fetchHymn() {
        repository
            .getHymn(identifier)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(
                receiveValue: { [weak self] hymn in
                    guard let self = self, let hymn = hymn, !hymn.lyrics.isEmpty else {
                        return
                    }

                    let title: Title
                    if self.identifier.hymnType == .classic {
                        title = "Hymn \(self.identifier.hymnNumber)"
                    } else {
                        title = hymn.title.replacingOccurrences(of: "Hymn: ", with: "")
                    }
                    self.title = title

                    self.shareableLyrics = self.convertToOneString(verses: hymn.lyrics)
                    self.languages = self.convertToSongResults(hymn.languages)
                    self.relevant = self.convertToSongResults(hymn.relevant)

                    let mp3Path = hymn.music?.data.first(where: { datum -> Bool in
                        datum.value == DatumValue.mp3.rawValue
                    })?.path
                    self.mp3Path = mp3Path.flatMap({ path -> URL? in
                        HymnalNet.url(path: path)
                    })
            }).store(in: &disposables)
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
                return SongResultViewModel(title: title, destinationView: DisplayHymnView(viewModel: DisplayHymnViewModel(hymnToDisplay: hymnIdentifier)).eraseToAnyView())
            }
        }  ?? [SongResultViewModel]()
    }

    private func convertToOneString(verses: [Verse]) -> String {
        var shareableLyrics = ""
        for verse in verses {
            for verseLine in verse.verseContent {
                shareableLyrics += (verseLine + "\n")
            }
            shareableLyrics += "\n"
        }
        return shareableLyrics
    }
}

extension DisplayHymnBottomBarViewModel: Equatable {
    static func == (lhs: DisplayHymnBottomBarViewModel, rhs: DisplayHymnBottomBarViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
