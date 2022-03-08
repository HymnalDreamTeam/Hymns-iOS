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
    private let tabSpacing: TabSpacing
    private let showIndicator: Bool

    init(geometry: GeometryProxy, currentTab: Binding<TabType>, tabItems: [TabType],
         tabAlignment: TabAlignment = .top, tabSpacing: TabSpacing = .maxWidth, showIndicator: Bool = true) {
        self._currentTab = currentTab
        self.geometry = geometry
        self.tabItems = tabItems
        self.tabAlignment = tabAlignment
        self.tabSpacing = tabSpacing
        self.showIndicator = showIndicator
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if tabAlignment == .top {
                VStack(spacing: 0) {
                    TabBar(currentTab: $currentTab, geometry: geometry, tabItems: tabItems, tabSpacing: tabSpacing,
                           showIndicator: showIndicator)
                    Divider()
                }
            }
            currentTab.content
            if tabAlignment == .bottom {
                VStack(spacing: 0) {
                    Divider()
                    TabBar(currentTab: $currentTab, geometry: geometry, tabItems: tabItems, tabSpacing: tabSpacing,
                           showIndicator: showIndicator)
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

        let selectedTab: HymnTab = .lyrics(Text("%_PREVIEW_% Lyrics here").eraseToAnyView())
        let selectedTabBinding: Binding<HymnTab> = .constant(selectedTab)
        let tabItems: [HymnTab] = [selectedTab, .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]

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
