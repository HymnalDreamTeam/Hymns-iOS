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
                    let label = "\(identifier.hymnType.displayLabel) \(identifier.hymnNumber)"
                    let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: identifier)).eraseToAnyView()
                    return SongResultViewModel(stableId: String(describing: identifier), title: entity.songTitle,
                                               label: label, destinationView: destination)
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
        register {FavoritesViewModel()}.scope(.graph)
    }
}
