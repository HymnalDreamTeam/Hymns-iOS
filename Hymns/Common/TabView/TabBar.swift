import SwiftUI

/**
 * Custom tab bar that has draws an accented indicator bar below each tab.
 * https://www.objc.io/blog/2020/02/25/swiftui-tab-bar/
 */
struct TabBar<TabItemType: TabItem>: View {

    private let indicatorSpacingExtra: CGFloat = 32 // indicator goes a little beyond the tab itself

    @Binding var currentTab: TabItemType
    let geometry: GeometryProxy
    let tabItems: [TabItemType]
    let tabSpacing: TabSpacing
    let showIndicator: Bool

    @State private var width = CGFloat.zero

    init(currentTab: Binding<TabItemType>, geometry: GeometryProxy, tabItems: [TabItemType], tabSpacing: TabSpacing, showIndicator: Bool) {
        self._currentTab = currentTab
        self.geometry = geometry
        self.tabItems = tabItems
        self.tabSpacing = tabSpacing
        self.showIndicator = showIndicator
    }

    var body: some View {
        if width <= 0 {
            // First we calculate the width of all the tabs by putting them into a ZStack. We do this in order to
            // set the width of the eventual HStack appropriately. If the total width is less than then width of
            // the containing GeometryProxy, then we should set the width to the width of the geometry proxy so
            // that the tabs take up the entire width and are equaly spaced. However, if the total width is greater
            // than or equal to the width of the containing GeometryProxy, then we should set the frame's width to
            // nil to allow it to scroll offscreen.
            return ZStack {
                ForEach(tabItems) { tabItem in
                    Button(
                        action: {},
                        label: {
                            Group {
                                if self.isSelected(tabItem) {
                                    tabItem.selectedLabel
                                } else {
                                    tabItem.unselectedLabel
                                }
                            }.accessibility(label: tabItem.a11yLabel).padding(.vertical)
                        })
                }.anchorPreference(key: TabWidthPreferenceKey.self, value: .bounds) { anchor in
                    return self.geometry[anchor].width
                }
            }.onPreferenceChange(TabWidthPreferenceKey.self) { width in
                self.width = width
            }.eraseToAnyView()
        } else {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: calculateHStackSpacing()) {
                    ForEach(tabItems) { tabItem in
                        if tabSpacing == .maxWidth {
                            Spacer()
                        }
                        Button(action: {
                            withAnimation(.default) {
                                self.currentTab = tabItem
                            }
                        }, label: {
                            Group {
                                if self.isSelected(tabItem) {
                                    tabItem.selectedLabel
                                } else {
                                    tabItem.unselectedLabel
                                }
                            }.accessibility(label: tabItem.a11yLabel).padding(.vertical)
                        }).accentColor(self.isSelected(tabItem) ? .accentColor : .primary)
                            .anchorPreference(
                                key: FirstNonNilPreferenceKey<Anchor<CGRect>>.self,
                                value: .bounds,
                                transform: { anchor in
                                    // Find the anchor where the current tab item is selected.
                                    self.isSelected(tabItem) ? .some(anchor) : nil
                                }
                            )
                        if tabSpacing == .maxWidth {
                            Spacer()
                        }
                    }
                }.frame(width: self.width > geometry.size.width ? nil : geometry.size.width)
            }.backgroundPreferenceValue(FirstNonNilPreferenceKey<Anchor<CGRect>>.self) { boundsAnchor in
                if showIndicator {
                    // Create the indicator.
                    GeometryReader { proxy in
                        boundsAnchor.map { anchor in
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(width: proxy[anchor].width + indicatorSpacingExtra, height: 3, alignment: .bottom)
                                .offset(.init(
                                    width: proxy[anchor].minX - 16,
                                    height: proxy[anchor].height - 4)) // Make the indicator a little higher
                        }
                    }
                }
            }.background(Color(.systemBackground)).eraseToAnyView()
        }
    }

    private func isSelected(_ tabItem: TabItemType) -> Bool {
        tabItem == currentTab
    }

    private func calculateHStackSpacing() -> CGFloat {
        switch tabSpacing {
        case .maxWidth:
            return 0
        case .custom(let spacing):
            return (showIndicator ? indicatorSpacingExtra : 0) + CGFloat(spacing)
        }
    }
}

/**
 * Finds the first non-nil preference key.
 *
 * This is used for finding the first selected tab item so we can draw the indicator.
 */
struct FirstNonNilPreferenceKey<T>: PreferenceKey {
    static var defaultValue: T? { nil }

    static func reduce(value: inout T?, nextValue: () -> T?) {
        value = value ?? nextValue()
    }
}

/**
 * Preference key to calculate the cumulative width of all the tabs.
 *
 * This is used to determine if we need to scroll off-screen or not and is used to set the frame width for the tab's HStack.
 */
struct TabWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

enum TabSpacing: Equatable {
    case maxWidth
    case custom(spacing: Int)
}

#if DEBUG
struct TabBar_Previews: PreviewProvider {

    static var previews: some View {
        var search: HomeTab = .search
        var browse: HomeTab = .browse
        let lyricsTab: HymnTab = .lyrics(EmptyView().eraseToAnyView())
        return Group {
            GeometryReader { geometry in
                TabBar(
                    currentTab: .constant(lyricsTab),
                    geometry: geometry,
                    tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
                    tabSpacing: .maxWidth,
                    showIndicator: true)
            }.previewDisplayName("lyrics tab selected")
            GeometryReader { geometry in
                TabBar(
                    currentTab: Binding<HomeTab>(
                        get: {search},
                        set: {search = $0}),
                    geometry: geometry,
                    tabItems: [.search, .browse, .favorites, .settings],
                    tabSpacing: .maxWidth,
                    showIndicator: true)
            }.previewDisplayName("home tab selected")
            GeometryReader { geometry in
                TabBar(
                    currentTab: Binding<HomeTab>(
                        get: {browse},
                        set: {browse = $0}),
                    geometry: geometry,
                    tabItems: [.search, .browse, .favorites, .settings],
                    tabSpacing: .maxWidth,
                    showIndicator: true)
            }.previewDisplayName("browse tab selected")
            GeometryReader { geometry in
                TabBar(
                    currentTab: .constant(lyricsTab),
                    geometry: geometry,
                    tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
                    tabSpacing: .custom(spacing: 0),
                    showIndicator: true)
            }.previewDisplayName("custom spacing")
            GeometryReader { geometry in
                TabBar(
                    currentTab: .constant(lyricsTab),
                    geometry: geometry,
                    tabItems: [lyricsTab, .music(EmptyView().eraseToAnyView())],
                    tabSpacing: .custom(spacing: 5),
                    showIndicator: false)
            }.previewDisplayName("no indicator")
        }.previewLayout(.fixed(width: 375, height: 50))
    }
}
#endif
