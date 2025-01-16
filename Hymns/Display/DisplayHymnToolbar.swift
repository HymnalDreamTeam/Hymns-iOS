import Prefire
import Resolver
import SwiftUI

struct DisplayHymnToolbar: View {

    @ObservedObject private var viewModel: DisplayHymnViewModel
    @ObservedObject private var coordinator: NavigationCoordinator

    private let firebaseLogger: FirebaseLogger

    init(viewModel: DisplayHymnViewModel,
         coordinator: NavigationCoordinator = Resolver.resolve(),
         firebaseLogger: FirebaseLogger = Resolver.resolve()) {
        self.coordinator = coordinator
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Button(action: {
                firebaseLogger.logButtonClick("back", file: #file)
                coordinator.goBack()
            }, label: {
                Image(systemName: "chevron.left")
                    .accessibility(label: Text("Go back", comment: "A11y label for going back."))
                    .accentColor(.primary).padding()
            })
            Spacer()
            Text(viewModel.title).fontWeight(.bold)
            Spacer()
            HStack {
                Button(action: {
                    firebaseLogger.logButtonClick("jumpBackToRoot", file: #file)
                    coordinator.jumpBackToRoot()
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .accessibility(label: Text("Close", comment: "A11y label for closing the song and going back direclty to the home screen from a hymn page."))
                        .accentColor(.primary)
                })
                viewModel.isFavorited.map { isFavorited in
                    Button(action: {
                        firebaseLogger.logButtonClick("toggleFavorite", file: #file)
                        self.viewModel.toggleFavorited()
                    }, label: {
                        isFavorited ?
                        Image(systemName: "heart.fill")
                            .accessibility(label: Text("Unmark song as a favorite", comment: "A11y label for unmarking a song as favorite.")).accentColor(.accentColor) :
                        Image(systemName: "heart")
                            .accessibility(label: Text("Mark song as a favorite", comment: "A11y label for marking a song as favorite.")).accentColor(.primary)
                    }).padding(.leading)
                }
            }.padding(.vertical).padding(.trailing)
        }
    }
}

#if DEBUG
struct DisplayHymnToolbar_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let loading = DisplayHymnToolbar(viewModel: DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))

        let missingFavoriteViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        missingFavoriteViewModel.title = "Cup of Christ"
        let missingFavorite = DisplayHymnToolbar(viewModel: missingFavoriteViewModel)

        let notFavoriteViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        notFavoriteViewModel.title = "Hymn 1151"
        notFavoriteViewModel.isFavorited = false
        let notFavorite = DisplayHymnToolbar(viewModel: notFavoriteViewModel)

        let favoriteViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40)
        favoriteViewModel.title = "Hymn 40"
        favoriteViewModel.isFavorited = true
        let favorite = DisplayHymnToolbar(viewModel: favoriteViewModel)

        return Group {
            loading.previewDisplayName("loading")
            missingFavorite.previewDisplayName("missing favorite")
            notFavorite.previewDisplayName("not favorite")
            favorite.previewDisplayName("favorite")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
