import Combine
import SwiftUI
import RealmSwift
import Resolver

class FavoritesViewModel: ObservableObject {

    @Published var favorites: [SongResultViewModel]?

    private let favoriteStore: FavoriteStore
    private let mainQueue: DispatchQueue
    private var disposables = Set<AnyCancellable>()

    init(favoriteStore: FavoriteStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self.favoriteStore = favoriteStore
        self.mainQueue = mainQueue
    }

    func fetchFavorites() {
        favoriteStore.favorites()
            .map({ entities -> [SongResultViewModel] in
                entities.map { entity -> SongResultViewModel in
                    let identifier = HymnIdentifier(entity.hymnIdentifierEntity)
                    return SongResultViewModel(
                        title: entity.songTitle,
                        destinationView: DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: identifier)).eraseToAnyView())
                }
            })
            .replaceError(with: [SongResultViewModel]())
            .receive(on: mainQueue)
            .sink(receiveValue: { results in
                if self.favorites != results {
                    self.favorites = results
                }
            }).store(in: &disposables)
    }
}

extension Resolver {
    public static func registerFavoritesViewModel() {
        register {FavoritesViewModel()}.scope(graph)
    }
}
