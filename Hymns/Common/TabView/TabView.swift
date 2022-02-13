import Foundation
import SwiftUI

/**
 * Custom `TabView` that uses a custom `TabBar` which draws an accented indicator below each tab.
 * Idea for this `TabView` class taken from: https://github.com/innoreq/IRScrollableTabView
 */
public struct IndicatorTabView<TabType: TabItem>: View {
    @Binding private var currentTab: TabType

    private let geometry: GeometryProxy
    private let tabItems: [TabType]
    private let tabAlignment: TabAlignment

    init(geometry: GeometryProxy, currentTab: Binding<TabType>, tabItems: [TabType], tabAlignment: TabAlignment = .top) {
        self._currentTab = currentTab
        self.geometry = geometry
        self.tabItems = tabItems
        self.tabAlignment = tabAlignment
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if tabAlignment == .top {
                VStack(spacing: 0) {
                    TabBar(currentTab: $currentTab, geometry: geometry, tabItems: tabItems)
                    Divider()
                }
            }
            currentTab.content
            if tabAlignment == .bottom {
                VStack(spacing: 0) {
                    Divider()
                    TabBar(currentTab: $currentTab, geometry: geometry, tabItems: tabItems)
                }
            }
        }
    }
}

public enum TabAlignment {
    case top
    case bottom
}

#if DEBUG
struct IndicatorTabView_Previews: PreviewProvider {

    static var previews: some View {

        let viewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40)
        viewModel.lyrics = [VerseViewModel(verseNumber: "1", verseLines: classic40_preview.lyrics[0].verseContent),
                            VerseViewModel(verseLines: classic40_preview.lyrics[1].verseContent),
                            VerseViewModel(verseNumber: "2", verseLines: classic40_preview.lyrics[2].verseContent),
                            VerseViewModel(verseNumber: "3", verseLines: classic40_preview.lyrics[3].verseContent),
                            VerseViewModel(verseNumber: "4", verseLines: classic40_preview.lyrics[4].verseContent)]
        let selectedTab: HymnLyricsTab = .lyrics(HymnLyricsView(viewModel: viewModel).eraseToAnyView())
        let selectedTabBinding: Binding<HymnLyricsTab> = .constant(selectedTab)
        let tabItems: [HymnLyricsTab] = [
            selectedTab,
            .chords(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: URL(string: "http://www.hymnal.net/en/hymn/h/40/f=gtpdf")!)).eraseToAnyView()),
            .guitar(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: URL(string: "http://www.hymnal.net/en/hymn/h/40/f=pdf")!)).eraseToAnyView()),
            .piano(DisplayHymnPdfView(viewModel: DisplayHymnPdfViewModel(url: URL(string: "http://www.hymnal.net/en/hymn/h/40/f=ppdf")!)).eraseToAnyView())]

        return Group {
            GeometryReader { geometry in
                IndicatorTabView(geometry: geometry, currentTab: selectedTabBinding, tabItems: tabItems)
                    .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                    .previewDisplayName("iPhone XS Max")
            }
            GeometryReader { geometry in
                IndicatorTabView(geometry: geometry, currentTab: selectedTabBinding, tabItems: tabItems, tabAlignment: .bottom)
                    .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                    .previewDisplayName("iPhone XS Max bottom tabs")
            }
            GeometryReader { geometry in
                IndicatorTabView(geometry: geometry, currentTab: selectedTabBinding, tabItems: tabItems)
                    .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                    .previewDisplayName("iPhone SE")
            }
            GeometryReader { geometry in
                IndicatorTabView(geometry: geometry, currentTab: selectedTabBinding, tabItems: tabItems)
                    .previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
                    .previewDisplayName("iPad Air 2")
            }
        }
    }
}
#endif
