import Prefire
import Resolver
import SwiftUI

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
struct BrowseResultsListView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let emptyViewModel = NoOpBrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        emptyViewModel.songResults = []
        let empty = BrowseResultsListView(viewModel: emptyViewModel)

        let loadingViewModel = NoOpBrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        loadingViewModel.songResults = nil
        let loading = BrowseResultsListView(viewModel: loadingViewModel)

        let resultObjects = [SingleSongResultViewModel(stableId: "Hymn 114", title: "Hymn 114", destinationView: EmptyView().eraseToAnyView()),
                             SingleSongResultViewModel(stableId: "Cup of Christ", title: "Cup of Christ", destinationView: EmptyView().eraseToAnyView()),
                             SingleSongResultViewModel(stableId: "Avengers - Endgame", title: "Avengers - Endgame", destinationView: EmptyView().eraseToAnyView())]
        let resultsViewModel = NoOpBrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        resultsViewModel.songResults = resultObjects
        let results = BrowseResultsListView(viewModel: resultsViewModel)

        return Group {
            empty.previewDisplayName("error")
            loading.previewDisplayName("loading")
            results.previewDisplayName("results")
        }
    }
}

class NoOpBrowseResultsListViewModel: BrowseResultsListViewModel {

    override func fetchResults() {
        // no op
    }
}
#endif
