import Prefire
import SwiftUI
import SwiftUIPager

struct DisplayHymnContainerView: View {

    @ObservedObject private var viewModel: DisplayHymnContainerViewModel

    init(viewModel: DisplayHymnContainerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            guard let hymns = self.viewModel.hymns else {
                return ActivityIndicator().maxSize().onAppear {
                    self.viewModel.populateHymns()
                }.eraseToAnyView()
            }
            if hymns.count == 1, let onlyHymn = hymns.first {
                return DisplayHymnView(viewModel: onlyHymn).eraseToAnyView()
            }
            return Pager(page: .withIndex(viewModel.currentHymn),
                         data: Array(0..<hymns.count),
                         id: \.self,
                         content: { index in
                DisplayHymnView(viewModel: hymns[index])
            }).onPageChanged({ newHymn in
                self.viewModel.currentHymn = newHymn
            }).allowsDragging(viewModel.swipeEnabled).eraseToAnyView()
        }
    }
}

#if DEBUG
struct DisplayHymnContainerView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let classic40LyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40,
                                                           lyrics: classic40_preview.lyrics.verses)!
        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let classic40ViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "4000"))
        classic40ViewModel.isLoaded = true
        classic40ViewModel.title = "Classic 40"
        classic40ViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: classic40LyricsViewModel).eraseToAnyView())
        classic40ViewModel.tabItems = [classic40ViewModel.currentTab]

        let classic1334LyricsViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334,
                                                             lyrics: classic1334_preview.lyrics.verses)!
        // Set hymnNumber to be outside the range of existing hymns, otherwise the preview will try to fetch the real song
        // instead of use fake data, making it non-deterministic.
        let classic1334ViewModel = DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "13340"))
        classic1334ViewModel.isLoaded = true
        classic1334ViewModel.title = "Classic 1334"
        classic1334ViewModel.currentTab = .lyrics(HymnLyricsView(viewModel: classic1334LyricsViewModel).eraseToAnyView())
        classic1334ViewModel.tabItems = [classic1334ViewModel.currentTab]

        let loadingViewModel = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "23"))
        let loading = DisplayHymnContainerView(viewModel: loadingViewModel)

        let oneHymnViewModel = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "40"))
        oneHymnViewModel.hymns = [classic40ViewModel]
        let oneHymn = DisplayHymnContainerView(viewModel: oneHymnViewModel)

        let zeroHymnsViewModel = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "40"))
        zeroHymnsViewModel.hymns = []
        let zeroHymns = DisplayHymnContainerView(viewModel: zeroHymnsViewModel)

        let multipleHymnsViewModel = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "1334"))
        multipleHymnsViewModel.hymns = [classic40ViewModel, classic1334ViewModel]
        let multipleHymns = DisplayHymnContainerView(viewModel: multipleHymnsViewModel)

        return Group {
            loading.previewDisplayName("loading")
            zeroHymns.previewDisplayName("zero hymns")
            oneHymn.previewDisplayName("one hymn")
            multipleHymns.previewDisplayName("multiple hymns")
        }
    }
}
#endif
