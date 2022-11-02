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

    convenience init(tag: UiTag) {
        self.init(resultsType: .tag(tag: tag))
    }

    convenience init(subcategory: String, hymnType: HymnType? = nil) {
        self.init(resultsType: .subcategory(subcategory: subcategory, hymnType: hymnType))
    }

    convenience init(category: String, subcategory: String? = nil, hymnType: HymnType? = nil) {
        if let subcategory = subcategory {
            self.init(resultsType: .subcategory(category: category, subcategory: subcategory, hymnType: hymnType))
        } else {
            self.init(resultsType: .category(category: category, hymnType: hymnType))
        }
    }

    convenience init(hymnType: HymnType) {
        self.init(resultsType: .hymnType(hymnType: hymnType))
    }

    private init(resultsType: ResultsType,
                 backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
                 dataStore: HymnDataStore = Resolver.resolve(),
                 mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
                 songbaseStore: SongbaseStore = Resolver.resolve(),
                 tagStore: TagStore = Resolver.resolve()) {
        self.title = resultsType.title
        self.resultsType = resultsType
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.songbaseStore = songbaseStore
        self.tagStore = tagStore
    }

    func fetchResults() {
        switch resultsType {
        case .tag(let tag):
            subscribeToPublisher(tagStore.getSongsByTag(tag))
        case .category(let category, let hymnType):
            if let hymnType = hymnType {
                subscribeToPublisher(dataStore.getResultsBy(category: category, hymnType: hymnType))
            } else {
                subscribeToPublisher(dataStore.getResultsBy(category: category))
            }
        case .subcategory(let category, let subcategory, let hymnType):
            if let category = category, let hymnType = hymnType {
                // Both hymn type and category are not nil
                subscribeToPublisher(dataStore.getResultsBy(category: category, subcategory: subcategory, hymnType: hymnType))
            } else if let hymnType = hymnType {
                // hymn type is not nil but category is nil
                subscribeToPublisher(dataStore.getResultsBy(subcategory: subcategory, hymnType: hymnType))
            } else if let category = category {
                // hymn type is nil but category is not nil
                subscribeToPublisher(dataStore.getResultsBy(category: category, subcategory: subcategory))
            } else {
                // both hymn type and category are nil
                subscribeToPublisher(dataStore.getResultsBy(subcategory: subcategory))
            }
        case .hymnType(let hymnType):
            fetchByHymnType(hymnType)
        }
    }

    private func subscribeToPublisher(_ publisher: AnyPublisher<[SongResultEntity], ErrorType>) {
        publisher
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
    }

    private func fetchByHymnType(_ hymnType: HymnType) {
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
                    }).filter({ songResult -> Bool in
                        // Only show the songs with a positive integer as the hymn number. In other words, skip the weird ones.
                        songResult.hymnNumber.isPositiveInteger
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

private enum ResultsType {
    case category(category: String, hymnType: HymnType? = nil)
    case subcategory(category: String? = nil, subcategory: String, hymnType: HymnType? = nil)
    case hymnType(hymnType: HymnType)
    case tag(tag: UiTag)

    var label: String {
        switch self {
        case .category:
            return NSLocalizedString("Category", comment: "Label for 'Category'.")
        case .subcategory:
            return NSLocalizedString("Subcategory", comment: "Label for 'Subcategory'.")
        case .hymnType:
            return NSLocalizedString("Hymn Type", comment: "Label for 'Hymn Type'.")
        case .tag:
            return NSLocalizedString("Tags", comment: "Label for 'Tags'.")
        }
    }

    var title: String {
        switch self {
        case .category(let category, _):
            return category
        case .subcategory(_, let subcategory, _):
            return subcategory
        case .hymnType(let hymnType):
            return hymnType.displayTitle
        case .tag(let tag):
            return String(format: NSLocalizedString("Songs tagged with \"%@\"", comment: "Title of a list of songs tagged with a particular tag."), tag.title)
        }
    }
}
