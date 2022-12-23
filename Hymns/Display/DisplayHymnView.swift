import FirebaseAnalytics
import SwiftUI
import Resolver

struct DisplayHymnView: View {

    @ObservedObject private var viewModel: DisplayHymnViewModel
    @State private var dialogModel: DialogViewModel<AnyView>?

    init(viewModel: DisplayHymnViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if !viewModel.isLoaded {
                ActivityIndicator().maxSize()
            } else {
                VStack(spacing: 0) {
                    if #available(iOS 16, *) {
                        DisplayHymnToolbar(viewModel: viewModel)
                    } else {
                        DisplayHymnToolbar15(viewModel: viewModel)
                    }
                    if viewModel.tabItems.count > 1 {
                        GeometryReader { geometry in
                            IndicatorTabView(geometry: geometry,
                                             currentTab: self.$viewModel.currentTab,
                                             tabItems: self.viewModel.tabItems,
                                             tabSpacing: .custom(spacing: 20))
                        }
                    } else {
                        viewModel.currentTab.content
                    }
                    if #available(iOS 16, *) {
                        viewModel.bottomBar.map { viewModel in
                            DisplayHymnBottomBar(dialogModel: self.$dialogModel, viewModel: viewModel).maxWidth()
                        }
                    } else {
                        viewModel.bottomBar.map { viewModel in
                            DisplayHymnBottomBar15(dialogModel: self.$dialogModel, viewModel: viewModel).maxWidth()
                        }
                    }
                }
                Dialog(viewModel: $dialogModel).map { dialog in
                    dialog.zIndex(1)
                }
            }
        }.hideNavigationBar()
            .onAppear {
                self.viewModel.fetchHymn()
        }.background(Color(.systemBackground))
    }
}

struct HymnNotExistsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("error illustration")
            Text("This hymn does not exist. Please try a different one.", comment: "Empty state for hymn lyrics.")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal)
        }
    }
}

#if DEBUG
struct DisplayHymnView_Previews: PreviewProvider {
    static var previews: some View {
        let hymn: UiHymn = UiHymn(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "23"), title: "sdf", lyrics: [Verse]())

        let loading = DisplayHymnView(viewModel: DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))

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
            classic40.previewDisplayName("classic 40")
            classic1151.previewDisplayName("classic 1151")
            classic1151Music.previewDisplayName("classic 1151 music")
            classic1334.previewDisplayName("classic 1134")
        }
    }
 }
 #endif
