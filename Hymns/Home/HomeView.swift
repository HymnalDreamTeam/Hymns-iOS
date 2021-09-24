import FirebaseAnalytics
import Resolver
import SwiftUI

struct HomeView: View {

    @ObservedObject private var viewModel: HomeViewModel
    @State var currentClicked: AnyView = EmptyView().eraseToAnyView()
    @State var activeNav = false

    init(viewModel: HomeViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.searchActive {
                CustomTitle(title: NSLocalizedString("Look up any hymn", comment: "Home tab title"))
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            }

            SearchBar(
                searchText: $viewModel.searchParameter,
                searchActive: $viewModel.searchActive,
                placeholderText: NSLocalizedString("Search by number or keyword", comment: "Search bar hint text"))
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

            viewModel.label.map {
                Text($0).fontWeight(.bold).padding(.top).padding(.leading).foregroundColor(Color("darkModeSubtitle"))
            }

            if viewModel.state == .loading {
                ActivityIndicator().maxSize()
            } else if viewModel.state == .empty {
                Text("Did not find any songs matching:\n\"\(viewModel.searchParameter)\".\nPlease try a different request")
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
                    List(viewModel.songResults) { songResult in
                        Button(action: {
                            currentClicked = songResult.destinationView
                            activeNav = true
                        }, label: {
                            NavigationLink(destination: EmptyView(), label: {
                                SongResultView(viewModel: songResult)
                            })
                        }
                        ).foregroundColor(.primary)
                            .onAppear {
                                self.viewModel.loadMore(at: songResult)
                            }
                    }.resignKeyboardOnDragGesture()
                }
            }
            NavigationLink(destination: currentClicked, isActive: $activeNav) {
                EmptyView()
            }
        }.onAppear {
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "HomeView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let defaultViewModel = HomeViewModel()

        let recentSongsViewModel = HomeViewModel()
        recentSongsViewModel.state = .results
        recentSongsViewModel.label = "Recent hymns"
        recentSongsViewModel.songResults = [PreviewSongResults.cupOfChrist, PreviewSongResults.hymn1151, PreviewSongResults.hymn1334]

        let recentSongsEmptyViewModel = HomeViewModel()
        recentSongsEmptyViewModel.state = .results

        let searchActiveViewModel = HomeViewModel()
        searchActiveViewModel.state = .results
        searchActiveViewModel.searchActive = true

        let loadingViewModel = HomeViewModel()
        loadingViewModel.state = .loading
        loadingViewModel.searchActive = true
        loadingViewModel.searchParameter = "She loves me not"

        let searchResults = HomeViewModel()
        searchResults.state = .results
        searchResults.searchActive = true
        searchResults.searchParameter = "Do you love me?"
        searchResults.songResults = [PreviewSongResults.hymn480, PreviewSongResults.hymn1334, PreviewSongResults.hymn1151]

        let noResultsViewModel = HomeViewModel()
        noResultsViewModel.state = .empty
        noResultsViewModel.searchActive = true
        noResultsViewModel.searchParameter = "She loves me not"

        return Group {
            HomeView(viewModel: defaultViewModel)
                .previewDisplayName("Default state")
            HomeView(viewModel: recentSongsViewModel)
                .previewDisplayName("Recent songs")
            HomeView(viewModel: recentSongsEmptyViewModel)
                .previewDisplayName("No recent songs")
            HomeView(viewModel: searchActiveViewModel)
                .previewDisplayName("Active search without recent songs")
            HomeView(viewModel: loadingViewModel)
                .previewDisplayName("Active search loading")
            HomeView(viewModel: searchResults)
                .previewDisplayName("Search results")
            HomeView(viewModel: noResultsViewModel)
                .previewDisplayName("No results")
        }
    }
}
#endif
