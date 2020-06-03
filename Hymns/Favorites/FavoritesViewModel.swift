import Combine
import SwiftUI
import RealmSwift
import Resolver

class FavoritesViewModel: ObservableObject {

    @Published var tags = [SongResultViewModel]()

    let objectWillChange = ObservableObjectPublisher()
    private var notificationToken: NotificationToken?
    private let favoritesStore: FavoritesStore

    init(favoritesStore: FavoritesStore = Resolver.resolve()) {
        self.favoritesStore = favoritesStore
    }

    deinit {
        notificationToken?.invalidate()
    }

    func fetchTags(_ tagSelected: String) {
        let result: Results<FavoriteEntity> = favoritesStore.specificTag(tagSelected: tagSelected)

        notificationToken = result.observe { _ in
            self.objectWillChange.send()
        }

        tags = result.map { (tag) -> SongResultViewModel in
            let identifier = HymnIdentifier(tag.hymnIdentifierEntity)
            return SongResultViewModel(
                title: tag.songTitle,
                destinationView: DisplayHymnView(viewModel: DisplayHymnViewModel(hymnToDisplay: identifier)).eraseToAnyView())
        }
    }

    func fetchTagsName() {
        let result: Results<FavoriteEntity> = favoritesStore.getAllTags()

        notificationToken = result.observe { _ in
            self.objectWillChange.send()
        }

        tags = result.map { (tag) -> SongResultViewModel in
            let identifier = HymnIdentifier(tag.hymnIdentifierEntity)
            return SongResultViewModel(
                title: tag.tags,
                destinationView: DisplayHymnView(viewModel: DisplayHymnViewModel(hymnToDisplay: identifier)).eraseToAnyView())
        }
    }

    func fetchHymnTags(hymnSelected: HymnIdentifier) {
        let result: Results<FavoriteEntity> = favoritesStore.specificHymn(hymnIdentifier: hymnSelected)

        notificationToken = result.observe { _ in
            self.objectWillChange.send()
        }

        tags = result.map { (tag) -> SongResultViewModel in
            let identifier = HymnIdentifier(tag.hymnIdentifierEntity)
            return SongResultViewModel(
                title: tag.tags,
                destinationView: DisplayHymnView(viewModel: DisplayHymnViewModel(hymnToDisplay: identifier)).eraseToAnyView())
        }
    }
}

extension Resolver {
    public static func registerFavoritesViewModel() {
        register {FavoritesViewModel()}.scope(graph)
    }
}
