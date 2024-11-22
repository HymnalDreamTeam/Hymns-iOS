import SwiftUI
import Resolver

struct BrowseResultsListView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var coordinator: NavigationCoordinator
    @ObservedObject private var viewModel: BrowseResultsListViewModel

    init(viewModel: BrowseResultsListViewModel, coordinator: NavigationCoordinator = Resolver.resolve()) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TitleWithBackButton(viewModel.title)
            Group { () -> AnyView in
                guard let songResults = self.viewModel.songResults else {
                    return ActivityIndicator().maxSize().eraseToAnyView()
                }
                guard !songResults.isEmpty else {
                    return ErrorView().maxSize().eraseToAnyView()
                }
                return List(songResults, id: \.stableId) { songResult in
                    NavigationLink(value: Route.songResult(.single(songResult))) {
                        SingleSongResultView(viewModel: songResult)
                    }.listRowSeparator(.hidden)
                }.listStyle(.plain).resignKeyboardOnDragGesture().eraseToAnyView()
            }
        }.onAppear {
            self.viewModel.fetchResults()
        }.hideNavigationBar()
    }
}

#if DEBUG
struct BrowseResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyViewModel = BrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        let empty = BrowseResultsListView(viewModel: emptyViewModel)

        let resultObjects = [SingleSongResultViewModel(stableId: "Hymn 114", title: "Hymn 114", destinationView: EmptyView().eraseToAnyView()),
                             SingleSongResultViewModel(stableId: "Cup of Christ", title: "Cup of Christ", destinationView: EmptyView().eraseToAnyView()),
                             SingleSongResultViewModel(stableId: "Avengers - Endgame", title: "Avengers - Endgame", destinationView: EmptyView().eraseToAnyView())]
        let resultsViewModel = BrowseResultsListViewModel(category: "Experience of Christ")
        resultsViewModel.songResults = resultObjects
        let results = BrowseResultsListView(viewModel: resultsViewModel)

        return Group {
            empty.previewDisplayName("error state")
            results.previewDisplayName("browse results")
        }
    }
}
#endif
