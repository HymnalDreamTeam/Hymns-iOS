import Resolver
import SwiftUI

struct FavoritesView: View {

    @ObservedObject private var viewModel: FavoritesViewModel
    @State private var favoriteToShow: SongResultViewModel?

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), viewModel: FavoritesViewModel = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            CustomTitle(title: NSLocalizedString("Favorites", comment: "Favorites tab title."))
            Group { () -> AnyView in
                guard let favorites = self.viewModel.favorites else {
                    return ActivityIndicator().maxSize().eraseToAnyView()
                }
                guard !favorites.isEmpty else {
                    return VStack(spacing: 25) {
                        Image("empty favorites illustration")
                        Text("Tap the heart on any hymn to add as a favorite.", comment: "Empty state for favorited songs.")
                    }.maxSize().offset(y: -25).eraseToAnyView()
                }
                return List(favorites, id: \.stableId) { favorite in
                    if #available(iOS 16, *) {
                        NavigationLink(value: Route.songResult(favorite)) {
                            SongResultView(viewModel: favorite)
                        }.padding(.trailing).listRowSeparator(.hidden).maxWidth()
                    } else {
                        HStack(alignment: .center) {
                            Button(action: {
                                self.viewModel.tearDown()
                                self.favoriteToShow = favorite
                            }, label: {
                                SongResultView(viewModel: favorite).padding(.trailing)
                            })
                            Spacer()
                            NavigationLink(destination: favorite.destinationView, tag: favorite, selection: self.$favoriteToShow) {
                                EmptyView()
                            }.frame(width: 0, height: 0).padding(.trailing)
                        }.listRowSeparator(.hidden).maxWidth()
                    }
                }.listStyle(.plain).id(viewModel.favorites).resignKeyboardOnDragGesture().eraseToAnyView()
            }
        }.onAppear {
            firebaseLogger.logScreenView(screenName: "FavoritesView")
            self.viewModel.fetchFavorites()
        }
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let loadingViewModel = FavoritesViewModel()
        let loading = FavoritesView(viewModel: loadingViewModel)

        let emptyViewModel = FavoritesViewModel()
        emptyViewModel.favorites = [SongResultViewModel]()
        let empty = FavoritesView(viewModel: emptyViewModel)

        let favoritesViewModel = FavoritesViewModel()
        favoritesViewModel.favorites = [PreviewSongResults.cupOfChrist, PreviewSongResults.hymn1151, PreviewSongResults.joyUnspeakable, PreviewSongResults.sinfulPast]
        let favorites = FavoritesView(viewModel: favoritesViewModel)

        return Group {
            loading.previewDisplayName("loading")
            empty.previewDisplayName("empty")
            favorites.previewDisplayName("favorites")
        }
    }
}
#endif
