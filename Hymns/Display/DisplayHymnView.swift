import Prefire
import Resolver
import SwiftUI

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
                        }.coordinateSpace(name: "scrollview")
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
                // Disable the idle timer when the view appears
                UIApplication.shared.isIdleTimerDisabled = true
                self.viewModel.fetchHymn()
            }.onDisappear {
                // Re-enable the idle timer when the view disappears
                UIApplication.shared.isIdleTimerDisabled = false
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
struct DisplayHymnView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"),
                                  title: "sdf", lyrics: [VerseEntity]())

        let loadingViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "998"))
        loadingViewModel.isLoaded = false
        let loading = DisplayHymnView(viewModel: loadingViewModel)

        let errorViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "998"))
        errorViewModel.isLoaded = true
        errorViewModel.title = "Blue Songbook 998"
        errorViewModel.isFavorited = false
        let error = DisplayHymnView(viewModel: errorViewModel)

        let lyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40,
                                                  lyrics: classic40_preview.lyrics.verses)!

        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let singleTabViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "4099"))
        singleTabViewModel.isLoaded = true
        singleTabViewModel.title = "Hymn 4099"
        singleTabViewModel.isFavorited = true
        singleTabViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        singleTabViewModel.tabItems = [singleTabViewModel.currentTab]
        let singleTab = DisplayHymnView(viewModel: singleTabViewModel)

        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let multipleTabsViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "5100"))
        multipleTabsViewModel.isLoaded = true
        multipleTabsViewModel.title = "Super new song"
        multipleTabsViewModel.isFavorited = true
        multipleTabsViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView())
        multipleTabsViewModel.tabItems = [multipleTabsViewModel.currentTab, .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]
        let multipleTabs = DisplayHymnView(viewModel: multipleTabsViewModel)

        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let multipleTabsMusicViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "5100"))
        multipleTabsMusicViewModel.isLoaded = true
        multipleTabsMusicViewModel.title = "Super new song music"
        multipleTabsMusicViewModel.currentTab = .music(Text("%_PREVIEW_% Music here").eraseToAnyView())
        multipleTabsMusicViewModel.tabItems = [.lyrics(HymnLyricsView(viewModel: lyricsViewModel).eraseToAnyView()),
                                               multipleTabsMusicViewModel.currentTab]
        let multipleTabsMusic = DisplayHymnView(viewModel: multipleTabsMusicViewModel)

        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let fullSongViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "5100"))
        fullSongViewModel.isLoaded = true
        fullSongViewModel.title = "Hymn 1334"
        fullSongViewModel.isFavorited = nil
        let fullSongLyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334,
                                                          lyrics: classic1334_preview.lyrics.verses)!
        fullSongViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: fullSongLyricsViewModel).eraseToAnyView())
        fullSongViewModel.tabItems = [fullSongViewModel.currentTab,
                                      .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]
        let fullSongBottomBarViewModel = DisplayHymnBottomBarViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151, hymn: hymn)
        let fullSongSongInfoDialogViewModel = SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                                                      hymn: UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn1151,
                                                                                   title: "", lyrics: nil, author: "MC"))!
        fullSongSongInfoDialogViewModel.songInfo = [SongInfoViewModel(type: .hymnCode, values: ["value1", "value2"])]
        fullSongBottomBarViewModel.buttons = [
            .share("Shareable lyrics"),
            .languages([SingleSongResultViewModel(stableId: "Empty title view", title: "language",
                                                  destinationView: EmptyView().eraseToAnyView())]),
            .relevant([SingleSongResultViewModel(stableId: "Empty relevant view", title: "relevant",
                                                 destinationView: EmptyView().eraseToAnyView())]),
            .musicPlayback(AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)),
            .songInfo(fullSongSongInfoDialogViewModel)
        ]
        fullSongViewModel.bottomBar = fullSongBottomBarViewModel
        let fullSong = DisplayHymnView(viewModel: fullSongViewModel)

        return Group {
            loading.previewDisplayName("loading")
            error.previewDisplayName("error")
            singleTab.previewDisplayName("single tab")
            multipleTabs.previewDisplayName("multiple tabs")
            multipleTabsMusic.previewDisplayName("multiple tabs music")
            fullSong.previewDisplayName("full song")
        }.snapshot(delay: 0.5)
    }
}
#endif
