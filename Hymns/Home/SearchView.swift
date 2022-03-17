import FirebaseAnalytics
import Resolver
import SwiftUI

struct SearchView: View {

    @ObservedObject private var viewModel: SearchViewModel
    @State private var resultToShow: SongResultViewModel?

    init(viewModel: SearchViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.searchActive {
                CustomTitle(title: NSLocalizedString("Look up any hymn", comment: "Home tab title."))
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            }

            if #available(iOS 15.0, *) {
                SearchBar(
                    searchText: $viewModel.searchParameter,
                    searchActive: $viewModel.searchActive,
                    placeholderText: NSLocalizedString("Search by number or keyword", comment: "Search bar hint text."))
                    .padding(.horizontal)
                    .padding(.top, viewModel.searchActive ? nil : .zero)
                    .alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                        dimens[HorizontalAlignment.center] // align tool tip to the end of the view
                    })
                    .alignmentGuide(.toolTipVerticalAlignment, computeValue: { dimens -> CGFloat in
                        dimens[.bottom] // align tool tip to bottom of the view
                    }).overlay(
                        self.viewModel.showSearchByTypeToolTip ?
                        ToolTipView(tapAction: {
                            self.viewModel.hasSeenSearchByTypeTooltip = true
                        }, label: {
                            HStack(alignment: .center, spacing: CGFloat.zero) {
                                Image(systemName: "xmark").padding()
                                Text("Try searching by hymn type (e.g. ns151, ch1, s3)", comment: "Tooltip showing the user how to best utilize search.").font(.caption).padding(.trailing)
                            }
                        }, configuration:
                                        ToolTipConfiguration(cornerRadius: 10,
                                                             arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 0.5, alignmentType: .percentage),
                                                             arrowHeight: 7)).alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                                                                 dimens[HorizontalAlignment.center]
                                                             }).eraseToAnyView() : EmptyView().eraseToAnyView(),
                        alignment: .toolTipAlignment).zIndex(1)
            } else {
                OldSearchBar(
                    searchText: $viewModel.searchParameter,
                    searchActive: $viewModel.searchActive,
                    placeholderText: NSLocalizedString("Search by number or keyword", comment: "Search bar hint text."))
                    .padding(.horizontal)
                    .padding(.top, viewModel.searchActive ? nil : .zero)
                    .alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                        dimens[HorizontalAlignment.center] // align tool tip to the end of the view
                    })
                    .alignmentGuide(.toolTipVerticalAlignment, computeValue: { dimens -> CGFloat in
                        dimens[.bottom] // align tool tip to bottom of the view
                    }).overlay(
                        self.viewModel.showSearchByTypeToolTip ?
                        ToolTipView(tapAction: {
                            self.viewModel.hasSeenSearchByTypeTooltip = true
                        }, label: {
                            HStack(alignment: .center, spacing: CGFloat.zero) {
                                Image(systemName: "xmark").padding()
                                Text("Try searching by hymn type (e.g. ns151, ch1, s3)").font(.caption).padding(.trailing)
                            }
                        }, configuration:
                                        ToolTipConfiguration(cornerRadius: 10,
                                                             arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 0.5, alignmentType: .percentage),
                                                             arrowHeight: 7)).alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                                                                 dimens[HorizontalAlignment.center]
                                                             }).eraseToAnyView() : EmptyView().eraseToAnyView(),
                        alignment: .toolTipAlignment).zIndex(1)
            }

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
                        HStack(alignment: .center) {
                            Button(action: {
                                self.viewModel.tearDown()
                                self.resultToShow = songResult
                            }, label: {
                                SongResultView(viewModel: songResult).padding(.trailing)
                            })
                            Spacer()
                            NavigationLink(destination: songResult.destinationView, tag: songResult, selection: self.$resultToShow) {
                                EmptyView()
                            }.frame(width: 0, height: 0).padding(.trailing)
                        }.onAppear {
                            self.viewModel.loadMore(at: songResult)
                        }.maxWidth()
                    }.listStyle(PlainListStyle()).resignKeyboardOnDragGesture()
                }
            }
        }.onAppear {
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "HomeView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
            resultToShow = nil
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
        recentSongsViewModel.songResults = [PreviewSongResults.cupOfChrist, PreviewSongResults.hymn1151, PreviewSongResults.hymn1334]

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
        searchResults.songResults = [PreviewSongResults.hymn480, PreviewSongResults.hymn1334, PreviewSongResults.hymn1151]

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
