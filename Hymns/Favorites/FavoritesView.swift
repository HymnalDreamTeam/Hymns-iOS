import FirebaseAnalytics
import Resolver
import SwiftUI

struct FavoritesView: View {

    @ObservedObject private var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            CustomTitle(title: NSLocalizedString("Favorites", comment: "Favorites tab title"))
            Group { () -> AnyView in
                guard let favorites = self.viewModel.favorites else {
                    return ActivityIndicator().maxSize().eraseToAnyView()
                }
                guard !favorites.isEmpty else {
                    return VStack(spacing: 25) {
                        Image("empty favorites illustration")
                        Text("Tap the heart on any hymn to add as a favorite")
                    }.maxSize().offset(y: -25).eraseToAnyView()
                }
                return List(favorites, id: \.stableId) { favorite in
                    NavigationLink(destination: favorite.destinationView) {
                        SongResultView(viewModel: favorite)
                    }
                }.listStyle(PlainListStyle()).id(viewModel.favorites).resignKeyboardOnDragGesture().eraseToAnyView()
            }
        }.onAppear {
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "FavoritesView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
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
