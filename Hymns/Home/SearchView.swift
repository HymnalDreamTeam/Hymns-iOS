import Prefire
import Resolver
import SwiftUI

struct SearchView: View {

    @ObservedObject private var viewModel: SearchViewModel

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), viewModel: SearchViewModel = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.searchActive {
                CustomTitle(title: NSLocalizedString("Look up any hymn", comment: "Home tab title."))
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            }

            SearchBar(
                searchText: $viewModel.searchParameter,
                searchActive: $viewModel.searchActive,
                placeholderText: NSLocalizedString("Search by number or keyword", comment: "Search bar hint text."))
            .padding(.horizontal)
            .padding(.top, viewModel.searchActive ? nil : .zero)
            .toolTip(tapAction: {
                self.viewModel.hasSeenSearchByTypeTooltip = true
            }, label: {
                HStack(alignment: .center, spacing: CGFloat.zero) {
                    Image(systemName: "xmark").padding()
                    Text("Try searching by hymn type (e.g. ns151, ch1, s3)", comment: "Tooltip showing the user how to best utilize search.").font(.caption).padding(.trailing)
                }
            }, configuration: ToolTipConfiguration(arrowConfiguration:
                                                    ToolTipConfiguration.ArrowConfiguration(
                                                        height: 7,
                                                        position:
                                                            ToolTipConfiguration.ArrowConfiguration.Position(
                                                                midX: 0.5, alignmentType: .percentage)),
                                                   bodyConfiguration:
                                                    ToolTipConfiguration.BodyConfiguration(cornerRadius: 10)),
                     shouldShow: self.$viewModel.showSearchByTypeToolTip)

            viewModel.label.map {
                Text($0).fontWeight(.bold).padding(.top).padding(.leading).foregroundColor(Color("darkModeSubtitle"))
            }

            if viewModel.state == .loading {
                ActivityIndicator().maxSize()
            } else if viewModel.state == .empty {
                Text("Did not find any songs matching:\n\"\(viewModel.searchParameter)\".\nPlease try a different request", comment: "Empty state for the search screen.")
                    .padding().multilineTextAlignment(.center).maxSize(alignment: .center)
            } else {
                if viewModel.songResults.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("empty search illustration").resizable().aspectRatio(contentMode: .fit).padding()
                        Spacer()
                    }.padding(.horizontal)
                    Spacer()
                } else {
                    List(viewModel.songResults, id: \.stableId) { songResult in
                        NavigationLink(value: Route.songResult(songResult)) {
                            switch songResult {
                            case .single(let viewModel):
                                SingleSongResultView(viewModel: viewModel).padding(.trailing)
                            case .multi(let viewModel):
                                MultiSongResultView(viewModel: viewModel).padding(.trailing)
                            }
                        }.onAppear {
                            self.viewModel.loadMore(at: songResult)
                        }.maxWidth()
                    }.listStyle(.plain).resignKeyboardOnDragGesture()
                }
            }
        }.onAppear {
            firebaseLogger.logScreenView(screenName: "HomeView")
            self.viewModel.setUp()
        }
    }
}

#if DEBUG
struct SearchView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let loadingViewModel = NoOpSearchViewModel()
        let loading = SearchView(viewModel: loadingViewModel)

        let emptyViewModel = NoOpSearchViewModel()
        emptyViewModel.state = .results
        let empty = SearchView(viewModel: emptyViewModel)

        let recentSongsViewModel = NoOpSearchViewModel()
        recentSongsViewModel.state = .results
        recentSongsViewModel.label = "Recent hymns"
        recentSongsViewModel.songResults = [
            .single(SingleSongResultViewModel(stableId: "classic1151", title: "Hymn 1151", destinationView: EmptyView().eraseToAnyView())),
            .single(SingleSongResultViewModel(stableId: "classic2", title: "Classic 2", destinationView: EmptyView().eraseToAnyView()))]
        let recentSongs = SearchView(viewModel: recentSongsViewModel)

        let searchActiveViewModel = NoOpSearchViewModel()
        searchActiveViewModel.state = .results
        searchActiveViewModel.searchActive = true
        let searchActive = SearchView(viewModel: searchActiveViewModel)

        let searchingViewModel = NoOpSearchViewModel()
        searchingViewModel.state = .loading
        searchingViewModel.searchActive = true
        searchingViewModel.searchParameter = "She loves me not"
        let searching = SearchView(viewModel: searchingViewModel)

        let searchResultsViewModel = NoOpSearchViewModel()
        searchResultsViewModel.state = .results
        searchResultsViewModel.searchActive = true
        searchResultsViewModel.searchParameter = "Do you love me?"
        searchResultsViewModel.showSearchByTypeToolTip = false
        searchResultsViewModel.songResults = [.multi(PreviewSongResults.drinkARiver),
                                              .multi(PreviewSongResults.sinfulPastMulti),
                                              .multi(PreviewSongResults.hymn1334Multi)]
        let searchResults = SearchView(viewModel: searchResultsViewModel)

        let noResultsViewModel = NoOpSearchViewModel()
        noResultsViewModel.state = .empty
        noResultsViewModel.searchActive = true
        noResultsViewModel.searchParameter = "She loves me not"
        let noResults = SearchView(viewModel: noResultsViewModel)

        return Group {
            loading.previewDisplayName("loading")
            empty.previewDisplayName("empty")
            NavigationStack {
                recentSongs
            }.previewDisplayName("recent songs")
            searchActive.previewDisplayName("search active")
            searching.previewDisplayName("searching")
            NavigationStack {
                searchResults
            }.previewDisplayName("results")
            noResults.previewDisplayName("no results")
        }.snapshot(delay: 0.5)
    }
}

class NoOpSearchViewModel: SearchViewModel {
    override func setUp() {
        // no op
    }
}
#endif
