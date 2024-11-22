import Combine
import Foundation
import Resolver
import SwiftUI

// swiftlint:disable:next type_body_length
class SearchViewModel: ObservableObject {

    @AppStorage("has_seen_search_by_type_tooltip") var hasSeenSearchByTypeTooltip = false {
        willSet {
            self.showSearchByTypeToolTip = !newValue
        }
    }
    @AppStorage("preferred_search_language") var preferredSearchLanguage: Language = .english

    @Published var searchActive: Bool = false
    @Published var searchParameter = "" {
        didSet {
            self.analytics.logQueryChanged(previousQuery: oldValue, newQuery: searchParameter)
        }
    }
    @Published var showSearchByTypeToolTip: Bool = false
    @Published var songResults: [SongResultViewModel] = [SongResultViewModel]()
    @Published var label: String?
    @Published var state: HomeResultState = .loading

    @Environment(\.locale) var locale: Locale

    private var currentPage = 1
    private var hasMorePages = false
    private var isLoading = false
    private var currentQuery = ""

    private var converter: Converter
    private var disposables = Set<AnyCancellable>()
    private let analytics: FirebaseLogger
    private let backgroundQueue: DispatchQueue
    private let dataStore: HymnDataStore
    private let firebaseLogger: FirebaseLogger
    private let historyStore: HistoryStore
    private let mainQueue: DispatchQueue
    private let repository: SongResultsRepository

    init(analytics: FirebaseLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         converter: Converter = Resolver.resolve(),
         dataStore: HymnDataStore = Resolver.resolve(),
         firebaseLogger: FirebaseLogger = Resolver.resolve(),
         historyStore: HistoryStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         repository: SongResultsRepository = Resolver.resolve()) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.converter = converter
        self.dataStore = dataStore
        self.firebaseLogger = firebaseLogger
        self.historyStore = historyStore
        self.mainQueue = mainQueue
        self.repository = repository

        // Initialize HymnDataStore early and start doing the heavy copying work on the background.
        backgroundQueue.async {
            let _: HymnDataStore = Resolver.resolve()
        }
        self.showSearchByTypeToolTip = !self.hasSeenSearchByTypeTooltip
    }

    func setUp() {
        $searchActive
            .receive(on: mainQueue)
            .sink { searchActive in
                self.analytics.logSearchActive(isActive: searchActive)
                if !searchActive {
                    self.resetState()
                    self.fetchRecentSongs()
                    return
                }
        }.store(in: &disposables)

        $searchParameter
            // Ignore the first call with an empty string since it's take care of already by $searchActive
            .dropFirst()
            // Debounce works by waiting a bit until the user stops typing and before sending a value
            .debounce(for: .seconds(0.3), scheduler: mainQueue)
            .sink { searchParameter in
                if searchParameter == self.currentQuery {
                    return
                }
                self.currentQuery = searchParameter
                self.refreshSearchResults()
        }.store(in: &disposables)
    }

    func tearDown() {
        self.disposables.removeAll()
    }

    private func resetState() {
        currentPage = 1
        hasMorePages = false
        songResults = [SongResultViewModel]()
        state = .loading
    }

    /// Hymn types to search for, give a certain language.
    private func searchTypes(language: Language) -> [HymnType] {
        switch language {
        case .english:
            return [.classic]
        case .chineseTraditional:
            // Special case to return both Chinese and Chinese supplement hymns if the language is Chinese.
            return [.chinese, .chineseSupplement]
        case .chineseSimplified:
            // Special case to return both Chinese and Chinese supplement hymns if the language is Chinese.
            return [.chineseSimplified, .chineseSupplementSimplified]
        case .cebuano:
            return [.cebuano]
        case .tagalog:
            return [.tagalog]
        case .dutch:
            return [.dutch]
        case .german:
            return [.liederbuch]
        case .french:
            return [.french]
        case .spanish:
            return [.spanish]
        case .portuguese:
            return [.portuguese]
        case .korean:
            return [.korean]
        case .japanese:
            return [.japanese]
        case .indonesian:
            return [.indonesian]
        case .farsi:
            return [.farsi]
        case .russian:
            return [.russian]
        case .hebrew:
            return [.hebrew]
        case .slovak:
            return [.slovak]
        case .estonian:
            return [.estonian]
        case .arabic:
            return [.arabic]
        case .UNRECOGNIZED(_):
            return [HymnType]()
        }
    }

    private func refreshSearchResults() {
        // Changes in searchActive are taken care of already by $searchActive
        if !self.searchActive {
            return
        }

        resetState()

        if self.searchParameter.isEmpty {
            self.fetchRecentSongs()
            return
        }

        if searchParameter.trim().isPositiveInteger {
            if searchParameter.trim().count > 6 {
                self.fetchByHymnCode(searchParameter.trim(), searchParameter: searchParameter)
                return
            }

            let hymnTypes = searchTypes(language: preferredSearchLanguage)
            fetchByHymnTypes(hymnTypes: hymnTypes, hymnNumber: searchParameter.trim(), searchParameter: searchParameter)
            return
        }

        if let hymnType = RegexUtil.getHymnType(searchQuery: searchParameter.trim()),
           let hymnNumber = RegexUtil.getHymnNumber(searchQuery: searchParameter.trim()) {
            let hymnTypes: [HymnType]
            if hymnType == .chinese || hymnType == .chineseSupplement {
                hymnTypes = [.chinese, .chineseSupplement]
            } else if hymnType == .chineseSimplified || hymnType == .chineseSupplementSimplified {
                hymnTypes = [.chineseSimplified, .chineseSupplementSimplified]
            } else {
                hymnTypes = [hymnType]
            }
            fetchByHymnTypes(hymnTypes: hymnTypes, hymnNumber: hymnNumber, searchParameter: searchParameter)
            return
        }

        self.performSearch(page: currentPage)
    }

    private func fetchRecentSongs() {
        label = nil
        state = .loading
        historyStore.recentSongs()
            .map({ recentSongs -> [SingleSongResultViewModel] in
                recentSongs.map { recentSong -> SingleSongResultViewModel in
                    let identifier = HymnIdentifier(wrapper: recentSong.hymnIdentifier)
                    let title = recentSong.songTitle ?? identifier.displayTitle
                    let label = recentSong.songTitle != nil ? identifier.displayTitle : nil
                    let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: identifier, storeInHistoryStore: true)).eraseToAnyView()
                    return SingleSongResultViewModel(stableId: String(describing: identifier), title: title,
                                               label: label, destinationView: destination)
                }
            })
            .map({ singleSongResultViewModels -> [SongResultViewModel] in
                singleSongResultViewModels.map({ .single($0) })
            })
            .replaceError(with: [SongResultViewModel]())
            .receive(on: mainQueue)
            .sink(receiveValue: { [weak self] songResults in
                guard let self = self else { return }

                if self.searchActive && !self.searchParameter.isEmpty {
                    // If the recent songs db changes while recent songs shouldn't be shown (there's an active search going on),
                    // we don't want to randomly replace the search results with updated db results.
                    return
                }
                self.state = .results
                self.songResults = songResults
                if !self.songResults.isEmpty {
                    self.label = NSLocalizedString("Recent hymns", comment: "Recent hymns label on the Home/Search screen.")
                }
            }).store(in: &disposables)
    }

    private func fetchByHymnTypes(hymnTypes: [HymnType], hymnNumber: String, searchParameter: String) {
        label = nil
        // let hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
        dataStore.getHymns(by: hymnTypes)
            .replaceError(with: [SongResultEntity]())
            .map({ songResults -> [SingleSongResultViewModel] in
                guard !hymnNumber.isEmpty else {
                    return [SingleSongResultViewModel]()
                }
                return songResults
                    .filter({ songResultEntity in
                        songResultEntity.hymnNumber.contains(hymnNumber)
                    }).sorted(by: { entity1, entity2 in
                        guard let number1 = entity1.hymnNumber.toInteger else {
                            return false
                        }
                        guard let number2 = entity2.hymnNumber.toInteger else {
                            return true
                        }
                        return number1 < number2
                    }).map { songResultEntity -> SingleSongResultViewModel in
                        let identifier = HymnIdentifier(hymnType: songResultEntity.hymnType, hymnNumber: songResultEntity.hymnNumber)
                        let stableId = String(describing: identifier)
                        let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: identifier, storeInHistoryStore: true)).eraseToAnyView()
                        if let title = songResultEntity.title {
                            return SingleSongResultViewModel(stableId: stableId, title: title, label: identifier.displayTitle, destinationView: destination)
                        } else {
                            return SingleSongResultViewModel(stableId: stableId, title: identifier.displayTitle, destinationView: destination)
                        }
                    }
            }).map({ singleSongResultViewModels -> [SongResultViewModel] in
                singleSongResultViewModels.map({ .single($0) })
            }).subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(receiveValue: { [weak self] songResults in
                guard let self = self else { return }
                if searchParameter.trim() != self.searchParameter.trim() {
                    // search parameter has changed by the time the call completed, so just drop this.
                    return
                }
                self.songResults += songResults.filter { songResult in
                    !self.songResults.map({$0.stableId}).contains(songResult.stableId)
                }
                self.state = self.songResults.isEmpty ? .empty : .results
            }).store(in: &disposables)
    }

    private func fetchByHymnCode(_ hymnCode: String, searchParameter: String) {
        label = nil
        repository.search(hymnCode: hymnCode)
            .replaceError(with: [SongResultEntity]())
            .subscribe(on: backgroundQueue)
            .map({ songResults -> [MultiSongResultViewModel] in
                self.converter.toMultiSongResultViewModels(songResultEntities: songResults, storeInHistoryStore: true)
            }).map({ multiSongResultViewModels -> [SongResultViewModel] in
                multiSongResultViewModels.map({ .multi($0) })
            }).receive(on: mainQueue)
            .sink { songResults in
                if searchParameter.trim() != self.searchParameter.trim() {
                    // search parameter has changed by the time the call completed, so just drop this.
                    return
                }
                self.songResults = songResults
                self.state = songResults.isEmpty ? .empty : .results
        }.store(in: &disposables)
    }

    func loadMore(at songResult: SongResultViewModel) {
        if !shouldLoadMore(songResult) {
            return
        }

        currentPage += 1
        performSearch(page: currentPage)
    }

    private func shouldLoadMore(_ songResult: SongResultViewModel) -> Bool {
        let thresholdMet = songResults.firstIndex(of: songResult) ?? 0 > songResults.count - 5
        return hasMorePages && !isLoading && thresholdMet
    }

    private func performSearch(page: Int) {
        label = nil

        let searchInput = self.searchParameter
        if searchInput.isEmpty {
            firebaseLogger.logError(EmptySearchInputError(errorDescription: "Search parameter should never be empty during a song fetch"))
            return
        }

        isLoading = true
        repository
            .search(searchParameter: searchParameter.trim(), pageNumber: page)
            .map({ songResultsPage -> ([MultiSongResultViewModel], Bool) in
                self.converter.toMultiSongResultViewModels(songResultsPage: songResultsPage)
            })
            .map({ (multiSongResultViewModels, hasMorePages) in
                (multiSongResultViewModels.map { .multi($0) }, hasMorePages)
            })
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(
                receiveCompletion: { [weak self] state in
                    guard let self = self else { return }

                    if searchInput != self.searchParameter {
                        // search parameter has changed by the time the call completed, so just drop this.
                        return
                    }

                    // Call is completed, so set isLoading to false.
                    self.isLoading = false

                    // If there are no more pages and still no results, then we should show the empty state.
                    if !self.hasMorePages && self.songResults.isEmpty {
                        self.state = .empty
                    }

                    switch state {
                    case .failure:
                        // If a call fails, then we assume there are no more pages to load.
                        self.hasMorePages = false
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] (songResults, hasMorePages) in
                    guard let self = self else { return }
                    if searchInput != self.searchParameter {
                        // search parameter has changed by the time results came back, so just drop this.
                        return
                    }

                    // Filter out duplicates
                    self.songResults.append(contentsOf: songResults.filter({ newViewModel -> Bool in
                        !self.songResults.contains(newViewModel)
                    }))
                    self.hasMorePages = hasMorePages
                    if !self.songResults.isEmpty {
                        self.state = .results
                    }
            }).store(in: &disposables)
    }
}

/**
 * Encapsulates the different state the home screen results page can take.
 */
enum HomeResultState {
    /**
     * Currently displaying results.
     */
    case results

    /**
     * Currently displaying the loading state.
     */
    case loading

    /**
     * Currently displaying an no-results state.
     */
    case empty
}

extension Resolver {
    public static func registerHomeViewModel() {
        register {SearchViewModel()}.scope(.graph)
    }
}
