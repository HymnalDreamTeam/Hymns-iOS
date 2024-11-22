import Combine
import SwiftUI
import RealmSwift
import Resolver

class FavoritesViewModel: ObservableObject {

    @Published var favorites: [SingleSongResultViewModel]?

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
            .map({ entities -> [SingleSongResultViewModel] in
                entities.map { entity -> SingleSongResultViewModel in
                    let identifier = HymnIdentifier(wrapper: entity.hymnIdentifier)
                    let title = entity.songTitle ?? identifier.displayTitle
                    let label = entity.songTitle != nil ? identifier.displayTitle : nil
                    let destination = DisplayHymnContainerView(viewModel: DisplayHymnContainerViewModel(hymnToDisplay: identifier)).eraseToAnyView()
                    return SingleSongResultViewModel(stableId: String(describing: identifier), title: title,
                                               label: label, destinationView: destination)
                }
            })
            .replaceError(with: [SingleSongResultViewModel]())
            .receive(on: mainQueue)
            .sink(receiveValue: { results in
                if self.favorites != results {
                    self.favorites = results
                }
            }).store(in: &disposables)
    }

    func tearDown() {
        disposables.removeAll()
    }
}

extension Resolver {
    public static func registerFavoritesViewModel() {
        register {FavoritesViewModel()}.scope(.graph)
    }
}
