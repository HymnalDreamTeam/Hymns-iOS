import SwiftUI
import Resolver

struct DisplayHymnView: View {

    @ObservedObject private var viewModel: DisplayHymnViewModel
    @State private var dialogModel: DialogViewModel<AnyView>?
    @State private var displayType: DisplayType?

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), viewModel: DisplayHymnViewModel) {
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ActivityIndicator().maxSize()
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ScrollView(showsIndicators: false) {
                            // Create an invisible view at the top of the scroll view to help calculate scroll position.
                            Color.clear
                                .frame(height: 0)
                                .overlay {
                                    GeometryReader { geometry in
                                        Color.clear.preference(key: DisplayHymnView.VerticalScrollTopKey.self,
                                                               value: geometry.frame(in: .named("scrollview")).minY)
                                    }
                                }
                            VStack(spacing: 0) {
                                DisplayHymnToolbar(viewModel: viewModel)
                                if viewModel.tabItems.count > 1 {
                                    IndicatorTabView(currentTab: self.$viewModel.currentTab,
                                                     tabItems: self.viewModel.tabItems,
                                                     tabSpacing: .custom(spacing: 20))
                                } else {
                                    viewModel.currentTab.content
                                }
                            }.overlay(
                                Color.clear
                                    .preference(key: VerticalHeightKey.self, value: geometry.size.height)
                            ).frame(height: displayType?.toHeight(geometry), alignment: .top)
                            // Create an invisible view at the bottom of the scroll view to help calculate scroll position.
                            Color.green
                                .frame(height: 0)
                                .overlay {
                                    GeometryReader { geometry in
                                        Color.clear.preference(key: DisplayHymnView.VerticalScrollBottomKey.self,
                                                               value: geometry.frame(in: .named("scrollview")).maxY)
                                    }
                                }
                        }.onPreferenceChange(VerticalScrollTopKey.self) { verticalScroll in
                            self.verticalScrollTop = verticalScroll
                        }.onPreferenceChange(VerticalScrollBottomKey.self) { verticalScrollBottom in
                            self.verticalScrollBottom = verticalScrollBottom
                        }.onPreferenceChange(VerticalHeightKey.self) { verticalHeight in
                            self.verticalHeight = verticalHeight
                        }.onPreferenceChange(DisplayTypeKey.self) { displayType in
                            self.displayType = displayType
                        }.coordinateSpace(name: "scrollview").environment(\.selectableTextContainerSize, geometry.size)
                        viewModel.bottomBar.map { viewModel in
                            DisplayHymnBottomBar(dialogModel: self.$dialogModel, viewModel: viewModel)
                                .padding(.bottom, bottomBarOffset)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear
                                            .preference(key: BottomBarHeight.self, value: geometry.size.height)
                                    }
                                ).onPreferenceChange(BottomBarHeight.self) { height in
                                    if initialBottomBarHeight == nil {
                                        initialBottomBarHeight = height
                                    }
                                }.maxSize(alignment: .bottom)

                        }
                        Dialog(viewModel: $dialogModel).map { dialog in
                            dialog.zIndex(1)
                        }
                    }.maxSize()
                }
            }
        }.hideNavigationBar()
            .onAppear {
                self.viewModel.fetchHymn()
            }.task {
                firebaseLogger.logScreenView(screenName: "DisplayHymnView")
            }.background(Color(.systemBackground))
    }

    enum DisplayType {
        case error
        case lyrics
        case inlineChords
        case sheetMusic

        func toHeight(_ geometry: GeometryProxy) -> CGFloat? {
            switch self {
            case .lyrics, .inlineChords:
                return nil
            case .error, .sheetMusic:
                return geometry.size.height
            }
        }
    }

    struct DisplayTypeKey: PreferenceKey {
        static let defaultValue: DisplayType? = nil
        static func reduce(value: inout DisplayType?,
                           nextValue: () -> DisplayType?) {
            value = value ?? nextValue()
        }
    }

    /** Used for coordinating the bottom bar with the user's scroll to hide/show **/
    @State private var bottomBarOffset: CGFloat = 0

    @State private var initialBottomBarHeight: CGFloat?

    @State private var verticalHeight: CGFloat?
    @State private var verticalScrollBottom: CGFloat?
    @State private var verticalScrollTop: CGFloat? {
        didSet {
            guard let verticalScrollTop = verticalScrollTop,
                  let verticalScrollBottom = verticalScrollBottom,
                  let verticalHeight = verticalHeight,
                  let initialBottomBarHeight = initialBottomBarHeight,
                  let oldVerticalScrollTop = oldValue else {
                return
            }

            // The scroll view is "bouncing" off either the top or the bottom.
            if verticalScrollTop >= 0 || verticalScrollBottom < verticalHeight {
                return
            }

            let scrollDifference = verticalScrollTop - oldVerticalScrollTop
            if scrollDifference > 0 { // Scrolling down
                // Show the bottom bar when scrolling down, but only up to its original position.
                bottomBarOffset = min(bottomBarOffset + scrollDifference, 0)
            } else { // Scrolling up
                // Hide the bottom bar when scrolling up, but only up to a certain point, so it can still
                // be reshown when the user scrolls down again.
                bottomBarOffset = max(-initialBottomBarHeight, bottomBarOffset + scrollDifference)
            }
        }
    }

    struct VerticalScrollTopKey: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }

    struct VerticalScrollBottomKey: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }

    struct VerticalHeightKey: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }

    struct BottomBarHeight: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }
    /***********************************************************************************************************************/
}

struct HymnNotExistsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image("error illustration")
            Text("This hymn does not exist. Please try a different one.", comment: "Empty state for hymn lyrics.")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal)
            Spacer()
        }.preference(key: DisplayHymnView.DisplayTypeKey.self, value: .error)
    }
}

#if DEBUG
struct DisplayHymnView_Previews: PreviewProvider {
    static var previews: some View {
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "sdf", lyrics: [VerseEntity]())

        let loadingViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "998"))
        loadingViewModel.isLoaded = false
        let loading = DisplayHymnView(viewModel: loadingViewModel)

        let errorViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "998"))
        errorViewModel.isLoaded = true
        errorViewModel.title = "Blue Songbook 998"
        errorViewModel.isFavorited = false
        let error = DisplayHymnView(viewModel: errorViewModel)

        let classic40ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40)
        classic40ViewModel.isLoaded = true
        classic40ViewModel.title = "Hymn 40"
        classic40ViewModel.isFavorited = true
        let classic40LyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40, lyrics: classic40_preview.lyrics)!
        classic40ViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: classic40LyricsViewModel).eraseToAnyView())
        classic40ViewModel.tabItems = [classic40ViewModel.currentTab, .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]
        classic40ViewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40, hymn: hymn)
        let classic40 = DisplayHymnView(viewModel: classic40ViewModel)

        let classic1151ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        classic1151ViewModel.isLoaded = true
        classic1151ViewModel.title = "Hymn 1151"
        classic1151ViewModel.isFavorited = false
        let classic1151LyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, lyrics: classic1151_preview.lyrics)!
        classic1151ViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: classic1151LyricsViewModel).maxSize().eraseToAnyView())
        classic1151ViewModel.tabItems = [classic1151ViewModel.currentTab, .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]
        classic1151ViewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        let classic1151 = DisplayHymnView(viewModel: classic1151ViewModel)

        let classic1151MusicViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        classic1151MusicViewModel.isLoaded = true
        classic1151MusicViewModel.title = "Hymn 1151"
        classic1151MusicViewModel.isFavorited = false
        classic1151MusicViewModel.currentTab = .music(Text("%_PREVIEW_% Music here").eraseToAnyView())
        classic1151MusicViewModel.tabItems = [.lyrics(HymnLyricsView(viewModel: classic1151LyricsViewModel).maxSize().eraseToAnyView()),
                                              classic1151MusicViewModel.currentTab]
        classic1151MusicViewModel.bottomBar = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        let classic1151Music = DisplayHymnView(viewModel: classic1151MusicViewModel)

        let classic1334ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334)
        classic1334ViewModel.isLoaded = true
        classic1334ViewModel.title = "Hymn 1334"
        classic1334ViewModel.isFavorited = nil
        let classic1334LyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334, lyrics: classic1334_preview.lyrics)!
        classic1334ViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: classic1334LyricsViewModel).maxSize().eraseToAnyView())
        classic1334ViewModel.tabItems = [HymnTab]()
        let classic1334BottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        let classic1334SongInfoDialogViewModel = SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                                                         hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn1151, title: "", lyrics: nil, author: "MC"))!
        classic1334SongInfoDialogViewModel.songInfo = [SongInfoViewModel(type: .hymnCode, values: ["value1", "value2"])]
        classic1334BottomBarViewModel.buttons = [
            .share("Shareable lyrics"),
            .languages([SongResultViewModel(stableId: "Empty title view", title: "language", destinationView: EmptyView().eraseToAnyView())]),
            .relevant([SongResultViewModel(stableId: "Empty relevant view", title: "relevant", destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .songInfo(classic1334SongInfoDialogViewModel)
        ]
        classic1334ViewModel.bottomBar = classic1334BottomBarViewModel
        let classic1334 = DisplayHymnView(viewModel: classic1334ViewModel)
        return Group {
            loading.previewDisplayName("loading")
            error.previewDisplayName("error")
            classic40.previewDisplayName("classic 40")
            classic1151.previewDisplayName("classic 1151")
            classic1151Music.previewDisplayName("classic 1151 music")
            classic1334.previewDisplayName("classic 1134")
        }
    }
}
#endif
