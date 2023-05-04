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
        self.currentTab = .lyrics(HymnNotExistsView().maxSize().eraseToAnyView())
        self.favoriteStore = favoriteStore
        self.historyStore = historyStore
        self.identifier = identifier
        self.mainQueue = mainQueue
        self.pdfLoader = pdfPreloader
        self.repository = repository
        self.systemUtil = systemUtil
        self.storeInHistoryStore = storeInHistoryStore
    }

    // swiftlint:disable:next cyclomatic_complexity
    func fetchHymn() {
        analytics.logDisplaySong(hymnIdentifier: identifier)

        let hymnPublisher: AnyPublisher<UiHymn?, Never> = {
            if identifier.hymnType != .songbase {
                return repository.getHymn(identifier)
            } else {
                return Just<UiHymn?>(nil).eraseToAnyPublisher()
            }
        }()
        let songbasePublisher: AnyPublisher<SongbaseSong?, Never> = {
            if let hymnType = identifier.hymnType.toSongbaseBook,
               identifier.hymnNumber.isPositiveInteger,
               let hymnNumber = Int(identifier.hymnNumber) {
                return repository.getSongbase(bookId: hymnType, bookIndex: hymnNumber)
            } else {
                return Just<SongbaseSong?>(nil).eraseToAnyPublisher()
            }
        }()

        var latestValue: UiHymn?
        Publishers.CombineLatest(hymnPublisher, songbasePublisher)
            .map({ uiHymn, songbaseSong -> UiHymn? in
                guard let songbaseSong = songbaseSong else {
                    return uiHymn
                }

                let chordLines = songbaseSong.chords.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map {  ChordLine(String($0)) }
                guard let uiHymn = uiHymn else {
                    return UiHymnBuilder(hymnIdentifier: self.identifier, title: songbaseSong.title).chords(chordLines).build()
                }

                let chordsFound = chordLines.contains { chordLine in
                    chordLine.hasChords
                }
                // Songbase song found, but no chords in songbase song, so then just return without setting chords.
                if !chordsFound {
                    return uiHymn
                }

                return uiHymn.builder.chords(chordLines).build()
            })
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(receiveCompletion: { [weak self] state in
                guard let self = self else { return }
                // Only display the hymn if the call is finished and we aren't getting any more values
                if state == .finished {
                    self.isLoaded = true
                    guard let hymn = latestValue else {
                        return
                    }

                    switch self.identifier.hymnType {
                    case .newTune, .newSong, .children, .howardHigashi:
                        self.title = hymn.title
                    default:
                        self.title = String(format: self.identifier.hymnType.displayLabel, self.identifier.hymnNumber)
                    }
                    self.resultsTitle = hymn.title

                    self.tabItems.removeAll()
                    if let lyrics = HymnLyricsViewModel(hymnToDisplay: self.identifier, lyrics: hymn.lyrics) {
                        let lyricsTab: HymnTab = .lyrics(HymnLyricsView(viewModel: lyrics).maxSize().eraseToAnyView())
                        self.tabItems.append(lyricsTab)
                    }

                    if let musicView = self.getHymnMusic(hymn) {
                        self.tabItems.append(.music(musicView.eraseToAnyView()))
                    }

                    if let firstTab = self.tabItems.first {
                        self.currentTab = firstTab
                    }

                    self.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: self.identifier, hymn: hymn)
                    self.fetchFavoriteStatus()
                    if self.storeInHistoryStore {
                        self.historyStore.storeRecentSong(hymnToStore: self.identifier, songTitle: self.resultsTitle)
                    }
                }
            }, receiveValue: { value in
                latestValue = value
            }).store(in: &disposables)
    }

    private func getHymnMusic(_ hymn: UiHymn) -> HymnMusicView? {
        var hymnMusic = [HymnMusicTab]()

        let chordsPath = hymn.pdfSheet?[DatumValue.text.rawValue]
        let chordsUrl = chordsPath.flatMap({ path -> URL? in
            HymnalNet.url(path: path)
        })
        let guitarSheetPath = hymn.pdfSheet?[DatumValue.guitar.rawValue]
        let guitarSheetUrl = guitarSheetPath.flatMap({ path -> URL? in
            HymnalNet.url(path: path)
        })
        let guitarUrl = self.systemUtil.isNetworkAvailable() ? chordsUrl ?? guitarSheetUrl : nil
        if let guitarUrl = guitarUrl {
            self.pdfLoader.load(url: guitarUrl)
        }

        if let chords = hymn.chords {
            hymnMusic.append(.guitar(InlineChordsView(viewModel: InlineChordsViewModel(chords: chords, guitarUrl: guitarUrl)).eraseToAnyView()))
        } else if let guitarUrl = guitarUrl {
            hymnMusic.append(.guitar(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: guitarUrl)).eraseToAnyView()))
        }

        if self.systemUtil.isNetworkAvailable() {
            let pianoPath = hymn.pdfSheet?[DatumValue.piano.rawValue]
            if let pianoUrl = pianoPath.flatMap({ path -> URL? in
                HymnalNet.url(path: path)
            }) {
                self.pdfLoader.load(url: pianoUrl)
                hymnMusic.append(.piano(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: pianoUrl)).eraseToAnyView()))
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
