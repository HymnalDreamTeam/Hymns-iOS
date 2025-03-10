import Prefire
import Resolver
import SwiftUI

struct HymnMusicView: View {

    @ObservedObject var viewModel: HymnMusicViewModel

    init(viewModel: HymnMusicViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.musicViews.count > 1 {
            return IndicatorTabView(currentTab: self.$viewModel.currentTab,
                                    tabItems: self.viewModel.musicViews,
                                    tabSpacing: .custom(spacing: 25),
                                    showIndicator: false,
                                    showDivider: false).eraseToAnyView()
        } else {
            return self.viewModel.currentTab.content
        }
    }
}

#if DEBUG
struct HymnMusicView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let error = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: []))
        let pianoOnly = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.piano(Text("%_PREVIEW_% Piano sheet music here").eraseToAnyView())]))
        let guitarOnly = HymnMusicView(viewModel: HymnMusicViewModel(musicViews: [.guitar(Text("%_PREVIEW_% Guitar sheet music here").eraseToAnyView())]))
        let pianoSelectedViewModel = HymnMusicViewModel(musicViews: [.piano(Text("%_PREVIEW_% Piano sheet music here").eraseToAnyView()),
                                                                     .guitar(Text("%_PREVIEW_% Guitar sheet music here").eraseToAnyView())])
        let pianoSelected = HymnMusicView(viewModel: pianoSelectedViewModel)

        let guitar: HymnMusicTab = .guitar(Text("%_PREVIEW_% Guitar sheet music here").eraseToAnyView())
        let guitarSelectedViewModel = HymnMusicViewModel(musicViews: [.piano(Text("%_PREVIEW_% Piano sheet music here").eraseToAnyView()),
                                                                      guitar])
        guitarSelectedViewModel.currentTab = guitar
        let guitarSelected = HymnMusicView(viewModel: guitarSelectedViewModel)
        return Group {
            error.previewDisplayName("error")
            pianoOnly.previewDisplayName("piano only")
            guitarOnly.previewDisplayName("guitar only")
            pianoSelected.previewDisplayName("piano selected")
            guitarSelected.previewDisplayName("guitar selected")
        }
    }
}
#endif
