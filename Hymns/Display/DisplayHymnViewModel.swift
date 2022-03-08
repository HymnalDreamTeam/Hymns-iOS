import Combine
import RealmSwift
import Resolver
import SwiftUI

class DisplayHymnViewModel: ObservableObject {

    typealias Title = String
    typealias Lyrics = [Verse]

    @Published var isLoaded = false
    @Published var title: String = ""
    @Published var currentTab: HymnTab
    @Published var tabItems: [HymnTab] = [HymnTab]()
    @Published var isFavorited: Bool?
    @Published var bottomBar: DisplayHymnBottomBarViewModel?

    let identifier: HymnIdentifier

    private let analytics: AnalyticsLogger
    private let backgroundQueue: DispatchQueue
    private let favoriteStore: FavoriteStore
    private let historyStore: HistoryStore
    private let mainQueue: DispatchQueue
    private let pdfLoader: PDFLoader
    private let repository: HymnsRepository
    private let systemUtil: SystemUtil
    private let storeInHistoryStore: Bool

    /**
     * Title of song for when the song is displayed as a song result in a list of results. Used to store into the Favorites/Recents store.
     */
    private var resultsTitle: String = ""
    private var disposables = Set<AnyCancellable>()

    init(analytics: AnalyticsLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         favoriteStore: FavoriteStore = Resolver.resolve(),
         hymnToDisplay identifier: HymnIdentifier,
         hymnsRepository repository: HymnsRepository = Resolver.resolve(),
         historyStore: HistoryStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         pdfPreloader: PDFLoader = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve(),
         storeInHistoryStore: Bool = false) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.currentTab = .lyrics(HymnLyricsView(viewModel: HymnLyricsViewModel(hymnToDisplay: identifier)).maxSize().eraseToAnyView())
        self.favoriteStore = favoriteStore
        self.historyStore = historyStore
        self.identifier = identifier
        self.mainQueue = mainQueue
        self.pdfLoader = pdfPreloader
        self.repository = repository
        self.systemUtil = systemUtil
        self.storeInHistoryStore = storeInHistoryStore
    }

    func fetchHymn() {
        analytics.logDisplaySong(hymnIdentifier: identifier)
        repository
            .getHymn(identifier)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(
                receiveValue: { [weak self] hymn in
                    guard let self = self else { return }
                    self.isLoaded = true
                    guard let hymn = hymn else { return }

                    switch self.identifier.hymnType {
                    case .newTune, .newSong, .children, .howardHigashi:
                        self.title = hymn.title
                    default:
                        self.title = String(format: self.identifier.hymnType.displayLabel, self.identifier.hymnNumber)
                    }
                    self.resultsTitle = hymn.title

                    let lyricsTab: HymnTab = .lyrics(HymnLyricsView(viewModel: HymnLyricsViewModel(hymnToDisplay: self.identifier)).maxSize().eraseToAnyView())
                    self.currentTab = lyricsTab
                    self.tabItems = [lyricsTab]

                    if let musicView = self.getHymnMusic(hymn) {
                        self.tabItems.append(.music(musicView.eraseToAnyView()))
                    }

                    self.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: self.identifier)
                    self.fetchFavoriteStatus()
                    if self.storeInHistoryStore {
                        self.historyStore.storeRecentSong(hymnToStore: self.identifier, songTitle: self.resultsTitle)
                    }
            }).store(in: &disposables)
    }

    private func getHymnMusic(_ hymn: UiHymn) -> HymnMusicView? {
        var hymnMusic = [HymnMusicTab]()
        if self.systemUtil.isNetworkAvailable() {
            let pianoPath = hymn.pdfSheet?.data.first(where: { datum -> Bool in
                datum.value == DatumValue.piano.rawValue
            })?.path
            if let pianoUrl = pianoPath.flatMap({ path -> URL? in
                HymnalNet.url(path: path)
            }) {
                self.pdfLoader.load(url: pianoUrl)
                hymnMusic.append(.piano(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: pianoUrl)).eraseToAnyView()))
            }

            let chordsPath = hymn.pdfSheet?.data.first(where: { datum -> Bool in
                datum.value == DatumValue.text.rawValue
            })?.path
            if let chordsUrl = chordsPath.flatMap({ path -> URL? in
                HymnalNet.url(path: path)
            }) {
                self.pdfLoader.load(url: chordsUrl)
                hymnMusic.append(.guitar(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: chordsUrl)).eraseToAnyView()))
            } else {
                let guitarSheetPath = hymn.pdfSheet?.data.first(where: { datum -> Bool in
                    datum.value == DatumValue.guitar.rawValue
                })?.path
                if let guitarSheetUrl = guitarSheetPath.flatMap({ path -> URL? in
                    HymnalNet.url(path: path)
                }) {
                    self.pdfLoader.load(url: guitarSheetUrl)
                    hymnMusic.append(.guitar(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: guitarSheetUrl)).eraseToAnyView()))
                }
            }
        }

        guard !hymnMusic.isEmpty else {
            return nil
        }

       return HymnMusicView(viewModel: HymnMusicViewModel(musicViews: hymnMusic))
    }

    func fetchFavoriteStatus() {
        favoriteStore.isFavorite(hymnIdentifier: identifier)
            .compactMap({ isFavorited -> Bool? in
                isFavorited
            })
            .replaceError(with: nil)
            .receive(on: mainQueue)
            .sink(receiveValue: { isFavorited in
                self.isFavorited = isFavorited
            }).store(in: &disposables)
    }

    func toggleFavorited() {
        isFavorited.map { isFavorited in
            if isFavorited {
                favoriteStore.deleteFavorite(primaryKey: FavoriteEntity.createPrimaryKey(hymnIdentifier: self.identifier))
            } else {
                favoriteStore.storeFavorite(FavoriteEntity(hymnIdentifier: self.identifier, songTitle: self.resultsTitle))
            }
        }
    }
}

extension DisplayHymnViewModel: Hashable {
    static func == (lhs: DisplayHymnViewModel, rhs: DisplayHymnViewModel) -> Bool {
        lhs.identifier == rhs.identifier && lhs.storeInHistoryStore == rhs.storeInHistoryStore
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(storeInHistoryStore)
    }
}
