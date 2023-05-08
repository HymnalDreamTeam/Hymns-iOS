import Combine
import Foundation
import Resolver

class BrowseResultsListViewModel: ObservableObject {

    @Published var title: String
    @Published var songResults: [SongResultViewModel]?

    private let backgroundQueue: DispatchQueue
    private let dataStore: HymnDataStore
    private let mainQueue: DispatchQueue
    private let resultType: HymnAttribute
    private let songbaseStore: SongbaseStore
    private let tagStore: TagStore

    private var disposables = Set<AnyCancellable>()

    convenience init(tag: UiTag) {
        self.init(resultType: .tag(tag: tag))
    }

    convenience init(subcategory: String, hymnType: HymnType? = nil) {
        self.init(resultType: .subcategory(subcategory: subcategory, hymnType: hymnType))
    }

    convenience init(category: String, subcategory: String? = nil, hymnType: HymnType? = nil) {
        if let subcategory = subcategory {
            self.init(resultType: .subcategory(category: category, subcategory: subcategory, hymnType: hymnType))
        } else {
            self.init(resultType: .category(category: category, hymnType: hymnType))
        }
    }

    convenience init(author: String) {
        self.init(resultType: .author(author))
    }

    convenience init(composer: String) {
        self.init(resultType: .composer(composer))
    }

    convenience init(key: String) {
        self.init(resultType: .key(key))
    }

    convenience init(time: String) {
        self.init(resultType: .time(time))
    }

    convenience init(meter: String) {
        self.init(resultType: .meter(meter))
    }

    convenience init(scriptures: String) {
        self.init(resultType: .scriptures(scriptures))
    }

    convenience init(hymnCode: String) {
        self.init(resultType: .hymnCode(hymnCode))
    }

    convenience init(hymnType: HymnType) {
        self.init(resultType: .hymnType(hymnType))
    }

    private init(resultType: HymnAttribute,
                 backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
                 dataStore: HymnDataStore = Resolver.resolve(),
                 mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
                 songbaseStore: SongbaseStore = Resolver.resolve(),
                 tagStore: TagStore = Resolver.resolve()) {
        self.title = resultType.title
        self.resultType = resultType
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.mainQueue = mainQueue
        self.songbaseStore = songbaseStore
        self.tagStore = tagStore
    }

    // swiftlint:disable:next cyclomatic_complexity
    func fetchResults() {
        switch resultType {
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
        case .author(let author):
            subscribeToPublisher(dataStore.getResultsBy(author: author))
        case .composer(let composer):
            subscribeToPublisher(dataStore.getResultsBy(composer: composer))
        case .key(let key):
            subscribeToPublisher(dataStore.getResultsBy(key: key))
        case .time(let time):
            subscribeToPublisher(dataStore.getResultsBy(time: time))
        case .meter(let meter):
            subscribeToPublisher(dataStore.getResultsBy(meter: meter))
        case .scriptures(let scriptures):
            subscribeToPublisher(dataStore.getResultsBy(scriptures: scriptures))
        case .hymnCode(let hymnCode):
            subscribeToPublisher(dataStore.getResultsBy(hymnCode: hymnCode))
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
        let publisher = hymnType == .songbaseOther ? songbaseStore.getAllSongs().map { songbaseResults -> [SongResultEntity] in
            songbaseResults.map { songbaseResult -> SongResultEntity in
                SongResultEntity(hymnType: .songbaseOther, hymnNumber: String(songbaseResult.bookIndex), title: songbaseResult.title)
            }
        }.eraseToAnyPublisher() : dataStore.getAllSongs(hymnType: hymnType)

        return publisher
            .subscribe(on: backgroundQueue)
            .map({ songResults -> [SongResultViewModel] in
                songResults
                    .sorted(by: { result1, result2 in
                        let leadingNumbers1 = result1.hymnNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)[0]
                        let leadingNumbers2 = result2.hymnNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)[0]

                        if leadingNumbers1.isEmpty {
                            // If there are no leading numbers, they are automatically put to the end
                            return false
                        } else if leadingNumbers2.isEmpty {
                            // If there are no leading numbers, they are automatically put to the end
                            return true
                        } else if let hymnNumber1 = leadingNumbers1.toInteger, let hymnNumber2 = leadingNumbers2.toInteger, hymnNumber1 != hymnNumber2 {
                            // Sort the tuples by the numeric part first
                            return hymnNumber1 < hymnNumber2
                        } else {
                            return result1.hymnNumber < result2.hymnNumber
                        }
                    }).map({ songResult -> SongResultViewModel in
                        let hymnIdentifier = HymnIdentifier(hymnType: songResult.hymnType, hymnNumber: songResult.hymnNumber)
                        let title = "\(songResult.hymnNumber). \(songResult.title)"
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

extension BrowseResultsListViewModel: Hashable {
    static func == (lhs: BrowseResultsListViewModel, rhs: BrowseResultsListViewModel) -> Bool {
        lhs.title == rhs.title && lhs.resultType == rhs.resultType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(resultType)
    }
}
