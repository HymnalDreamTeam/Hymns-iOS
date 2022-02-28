import Combine
import Foundation
import Resolver

class BrowseResultsListViewModel: ObservableObject {

    @Published var title: String
    @Published var songResults: [SongResultViewModel]?

    private let backgroundQueue: DispatchQueue
    private let dataStore: HymnDataStore
    private let mainQueue: DispatchQueue
    private let resultsType: ResultsType
    private let songbaseStore: SongbaseStore
    private let tagStore: TagStore

    private var disposables = Set<AnyCancellable>()

    init(tag: UiTag, backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         dataStore: HymnDataStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         songbaseStore: SongbaseStore = Resolver.resolve(),
         tagStore: TagStore = Resolver.resolve()) {
        self.title = String(format: NSLocalizedString("Songs tagged with \"%@\"", comment: "Title of a list of songs tagged with a particular tag."),
                            tag.title)
        self.resultsType = .tag(tag: tag)
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.songbaseStore = songbaseStore
        self.tagStore = tagStore
    }

    init(category: String, subcategory: String? = nil,
         hymnType: HymnType? = nil,
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         dataStore: HymnDataStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         songbaseStore: SongbaseStore = Resolver.resolve(),
         tagStore: TagStore = Resolver.resolve()) {

        if let subcategory = subcategory {
            self.title = subcategory
        } else {
            self.title = category
        }
        self.resultsType = .category(category: category, subcategory: subcategory, hymnType: hymnType)
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.songbaseStore = songbaseStore
        self.tagStore = tagStore
    }

    init(hymnType: HymnType, backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         dataStore: HymnDataStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         songbaseStore: SongbaseStore = Resolver.resolve(),
         tagStore: TagStore = Resolver.resolve()) {
        self.title = hymnType.displayTitle
        self.resultsType = .allSongs(hymnType: hymnType)
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.songbaseStore = songbaseStore
        self.tagStore = tagStore
    }

    func fetchResults() {
        switch resultsType {
        case .tag(let tag):
            tagStore.getSongsByTag(tag)
                .receive(on: backgroundQueue)
                .map({ songResults -> [SongResultViewModel] in
                    songResults.map { songResult -> SongResultViewModel in
                        return Transformers.toSongResultsViewModel(entity: songResult)
                    }
                })
                .receive(on: mainQueue)
                .replaceError(with: [SongResultViewModel]())
                .sink(receiveValue: { [weak self] viewModels in
                    guard let self = self else { return }
                    self.songResults = viewModels
                }).store(in: &disposables)
        case .category(let category, let subcategory, let hymnType):
            dataStore.getResultsBy(category: category, hymnType: hymnType, subcategory: subcategory)
                .subscribe(on: backgroundQueue)
                .map({ songResults -> [SongResultViewModel] in
                    songResults.map { songResult -> SongResultViewModel in
                        return Transformers.toSongResultsViewModel(entity: songResult)
                    }
                })
                .receive(on: mainQueue)
                .replaceError(with: [SongResultViewModel]())
                .sink(receiveValue: { [weak self] viewModels in
                    guard let self = self else { return }
                    self.songResults = viewModels
                }).store(in: &disposables)
        case .allSongs(let hymnType):
            // If hymnType is songbase, then use the songbase store instead of the data store.
            let publisher = hymnType == .songbase ? songbaseStore.getAllSongs().map { songbaseResults -> [SongResultEntity] in
                songbaseResults.map { songbaseResult -> SongResultEntity in
                    SongResultEntity(hymnType: .songbase, hymnNumber: String(songbaseResult.bookIndex),
                                     queryParams: nil, title: songbaseResult.title)
                }
            }.eraseToAnyPublisher() : dataStore.getAllSongs(hymnType: hymnType)

            return publisher
                .subscribe(on: backgroundQueue)
                .map({ songResults -> [SongResultViewModel] in
                    songResults
                        .filter({ entity -> Bool in
                            if (entity.hymnType == .chinese || entity.hymnType == .chineseSupplement) && entity.queryParams != nil {
                                // Filter out the chinese songs where they have query params (essentially the gb=1) songs
                                // so we don't end up showing double results.
                                return false
                            }
                            return true
                        })
                        .compactMap({ songResult -> SongResultEntity? in
                            if !songResult.hymnNumber.isPositiveInteger {
                                return nil
                            }
                            return songResult
                        }).sorted(by: { (result1, result2) -> Bool in
                            guard let hymnNumber1 = result1.hymnNumber.toInteger, let hymnNumber2 = result2.hymnNumber.toInteger else {
                                return false
                            }
                            return hymnNumber1 < hymnNumber2
                        }).map({ songResult -> SongResultViewModel in
                            let hymnIdentifier = HymnIdentifier(hymnType: songResult.hymnType, hymnNumber: songResult.hymnNumber, queryParams: songResult.queryParams)

                            var title = "\(songResult.hymnNumber). \(songResult.title)"
                            if hymnType == .cebuano || hymnType == .german {
                                // Don't show hymn number here since the numbers are not continuous and showing a list
                                // of non-continous numbers is weird.
                                title = songResult.title
                            }
                            let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymnIdentifier)).eraseToAnyView()
                            return SongResultViewModel(stableId: String(describing: hymnIdentifier), title: title, destinationView: destination)
                        })
                })
                .replaceError(with: [SongResultViewModel]())
                .receive(on: mainQueue)
                .sink(receiveValue: { [weak self] viewModels in
                    guard let self = self else { return }
                    self.songResults = viewModels
                }).store(in: &disposables)
        }
    }
}

private enum ResultsType {
    case tag(tag: UiTag)
    case category(category: String, subcategory: String? = nil, hymnType: HymnType? = nil)
    case allSongs(hymnType: HymnType)
}
