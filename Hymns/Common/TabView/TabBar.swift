import SwiftUI

/**
 * Custom tab bar that has draws an accented indicator bar below each tab.
 * https://www.objc.io/blog/2020/02/25/swiftui-tab-bar/
 */
struct TabBar<TabItemType: TabItem>: View {

    @Binding var currentTab: TabItemType
    let tabItems: [TabItemType]

    var body: some View {
        HStack {
            ForEach(tabItems) { tabItem in
                Spacer()
                Button(
                    action: {
                        withAnimation(.default) {
                            self.currentTab = tabItem
                        }
                },
                    label: {
                        Group {
                            if self.isSelected(tabItem) {
                                tabItem.selectedLabel
                            } else {
                                tabItem.unselectedLabel
                            }
                        }.accessibility(label: tabItem.a11yLabel).padding()
                })
                    .accentColor(self.isSelected(tabItem) ? .accentColor : .primary)
                    .anchorPreference(
                        key: FirstNonNilPreferenceKey<Anchor<CGRect>>.self,
                        value: .bounds,
                        transform: { anchor in self.isSelected(tabItem) ? .some(anchor) : nil }
                )
                Spacer()
            }
        }.backgroundPreferenceValue(FirstNonNilPreferenceKey<Anchor<CGRect>>.self) { boundsAnchor in
            GeometryReader { proxy in
                boundsAnchor.map { anchor in
                    indicator(
                        width: proxy[anchor].width,
                        offset: .init(
                            width: proxy[anchor].minX,
                            height: proxy[anchor].height - 4 // Make the indicator a little higher
                        )
                    )
                }
            }
        }
    }

    private func isSelected(_ tabItem: TabItemType) -> Bool {
        tabItem == currentTab
    }
}

struct FirstNonNilPreferenceKey<T>: PreferenceKey {
    static var defaultValue: T? { nil }

    static func reduce(value: inout T?, nextValue: () -> T?) {
        value = value ?? nextValue()
    }
}

private func indicator(width: CGFloat, offset: CGSize) -> some View {
    Rectangle()
        .foregroundColor(.accentColor)
        .frame(width: width, height: 3, alignment: .bottom)
        .offset(offset)
}

#if DEBUG
struct TabBar_Previews: PreviewProvider {

    static var previews: some View {
        var home: HomeTab = .home
        let homeSelected = TabBar(
            currentTab: Binding<HomeTab>(
                get: {home},
                set: {home = $0}),
            tabItems: [
                .home,
                .browse,
                .favorites,
                .settings
        ])

        var browse: HomeTab = .browse
        let browseSelected = TabBar(
            currentTab: Binding<HomeTab>(
                get: {browse},
                set: {browse = $0}),
            tabItems: [
                .home,
                .browse,
                .favorites,
                .settings
        ])

        return Group {
            homeSelected.toPreviews("home tab selected")
            browseSelected.previewLayout(.sizeThatFits).previewDisplayName("browse tab selected")
        }.previewLayout(.fixed(width: 350, height: 50))
    }
}
#endif
