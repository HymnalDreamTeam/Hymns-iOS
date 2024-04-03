import SwiftUI
import Resolver

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
struct DisplayHymnToolbar_Previews: PreviewProvider {
    static var previews: some View {
        let loading = DisplayHymnToolbar(viewModel: DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))

        let classic40ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40)
        classic40ViewModel.title = "Hymn 40"
        classic40ViewModel.isFavorited = true
        let classic40 = DisplayHymnToolbar(viewModel: classic40ViewModel)

        let classic1151ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        classic1151ViewModel.title = "Hymn 1151"
        classic1151ViewModel.isFavorited = false
        let classic1151 = DisplayHymnToolbar(viewModel: classic1151ViewModel)

        let cupOfChristViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        cupOfChristViewModel.title = "Cup of Christ"
        cupOfChristViewModel.isFavorited = true
        let cupOfChrist = DisplayHymnToolbar(viewModel: cupOfChristViewModel)
        return Group {
            loading.previewDisplayName("loading")
            classic40.previewDisplayName("classic 40")
            classic1151.previewDisplayName("classic 1151")
            cupOfChrist.toPreviews("cup of christ")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
