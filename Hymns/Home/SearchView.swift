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
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let defaultViewModel = SearchViewModel()

        let recentSongsViewModel = SearchViewModel()
        recentSongsViewModel.state = .results
        recentSongsViewModel.label = "Recent hymns"
        recentSongsViewModel.songResults = [.single(PreviewSongResults.cupOfChrist),
                                            .single(PreviewSongResults.hymn1151),
                                            .single(PreviewSongResults.hymn1334)]

        let recentSongsEmptyViewModel = SearchViewModel()
        recentSongsEmptyViewModel.state = .results

        let searchActiveViewModel = SearchViewModel()
        searchActiveViewModel.state = .results
        searchActiveViewModel.searchActive = true

        let loadingViewModel = SearchViewModel()
        loadingViewModel.state = .loading
        loadingViewModel.searchActive = true
        loadingViewModel.searchParameter = "She loves me not"

        let searchResults = SearchViewModel()
        searchResults.state = .results
        searchResults.searchActive = true
        searchResults.searchParameter = "Do you love me?"
        searchResults.songResults = [.multi(PreviewSongResults.drinkARiver),
                                     .multi(PreviewSongResults.sinfulPastMulti),
                                     .multi(PreviewSongResults.hymn1334Multi)]

        let noResultsViewModel = SearchViewModel()
        noResultsViewModel.state = .empty
        noResultsViewModel.searchActive = true
        noResultsViewModel.searchParameter = "She loves me not"

        return Group {
            SearchView(viewModel: defaultViewModel)
                .previewDisplayName("Default state")
            SearchView(viewModel: recentSongsViewModel)
                .previewDisplayName("Recent songs")
            SearchView(viewModel: recentSongsEmptyViewModel)
                .previewDisplayName("No recent songs")
            SearchView(viewModel: searchActiveViewModel)
                .previewDisplayName("Active search without recent songs")
            SearchView(viewModel: loadingViewModel)
                .previewDisplayName("Active search loading")
            SearchView(viewModel: searchResults)
                .previewDisplayName("Search results")
            SearchView(viewModel: noResultsViewModel)
                .previewDisplayName("No results")
        }
    }
}
#endif
