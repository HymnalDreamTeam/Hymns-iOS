import Foundation
import Prefire
import SwiftUI

/**
 * Custom `TabView` that uses a custom `TabBar` which draws an accented indicator below each tab.
 * Idea for this `TabView` class taken from: https://github.com/innoreq/IRScrollableTabView
 */
public struct IndicatorTabView<TabType: TabItem>: View {
    @Binding private var currentTab: TabType

    private let tabItems: [TabType]
    private let tabAlignment: TabAlignment
    private let tabSpacing: TabSpacing
    private let showIndicator: Bool
    private let showDivider: Bool

    init(currentTab: Binding<TabType>,
         tabItems: [TabType],
         tabAlignment: TabAlignment = .top,
         tabSpacing: TabSpacing = .maxWidth,
         showIndicator: Bool = true,
         showDivider: Bool = true) {
        self._currentTab = currentTab
        self.tabItems = tabItems
        self.tabAlignment = tabAlignment
        self.tabSpacing = tabSpacing
        self.showIndicator = showIndicator
        self.showDivider = showDivider
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if tabAlignment == .top {
                VStack(spacing: 0) {
                    TabBar(currentTab: $currentTab, tabItems: tabItems, tabSpacing: tabSpacing,
                           showIndicator: showIndicator)
                    if showDivider {
                        Divider()
                    }
                }
            }
            currentTab.content
            if tabAlignment == .bottom {
                VStack(spacing: 0) {
                    if showDivider {
                        Divider()
                    }
                    TabBar(currentTab: $currentTab, tabItems: tabItems, tabSpacing: tabSpacing,
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
struct IndicatorTabView_Previews: PreviewProvider, PrefireProvider {

    static var previews: some View {

        let selectedTab: HymnTab = .lyrics(Text("%_PREVIEW_% Lyrics here").maxSize().eraseToAnyView())
        let selectedTabBinding: Binding<HymnTab> = .constant(selectedTab)
        let tabItems: [HymnTab] = [selectedTab, .music(Text("%_PREVIEW_% Music here").eraseToAnyView())]

        return Group {
            IndicatorTabView(currentTab: selectedTabBinding,
                             tabItems: tabItems)
                .previewDisplayName("top tabs -- divider")
            IndicatorTabView(currentTab: selectedTabBinding,
                             tabItems: tabItems,
                             showDivider: false)
                .previewDisplayName("top tabs -- no divider")
            IndicatorTabView(currentTab: selectedTabBinding,
                             tabItems: tabItems,
                             tabAlignment: .bottom)
                .previewDisplayName("bottom tabs -- divider")
            IndicatorTabView(currentTab: selectedTabBinding,
                             tabItems: tabItems,
                             tabAlignment: .bottom,
                             showDivider: false)
                .previewDisplayName("bottom tabs -- no divider")
            IndicatorTabView(currentTab: selectedTabBinding,
                             tabItems: tabItems,
                             tabSpacing: .custom(spacing: 250),
                             showIndicator: false)
                .previewDisplayName("custom tab spacing + no show indicator")
        }
    }
}
#endif
