import SwiftUI

struct HomeTabView: View {

    @AppStorage("show_preferred_search_language_announcement") var showPreferredSearchLanguageAnnouncement = true

    @Binding var selectedTab: HomeTab

    var body: some View {
        HStack {
            Button(action: {
                self.selectedTab = .search
            }, label: {
                HomeTab.search.getImage(selectedTab == HomeTab.search)
                    .padding()
                    .foregroundColor(self.selectedTab == .search ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: HomeTab.search.a11yLabel)
            })
            Spacer()
            Button(action: {
                self.selectedTab = .browse
            }, label: {
                HomeTab.browse.getImage(selectedTab == HomeTab.browse)
                    .padding()
                    .foregroundColor(self.selectedTab == .browse ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: HomeTab.browse.a11yLabel)
            })
            Spacer()
            Button(action: {
                self.selectedTab = .favorites
            }, label: {
                HomeTab.favorites.getImage(selectedTab == HomeTab.favorites)
                    .padding()
                    .foregroundColor(self.selectedTab == .favorites ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: HomeTab.favorites.a11yLabel)
            })
            Spacer()
            Button(action: {
                self.selectedTab = .settings
            }, label: {
                HomeTab.settings.getImage(selectedTab == HomeTab.settings)
                    .padding()
                    .foregroundColor(self.selectedTab == .settings ? .accentColor : .secondary)
                    .font(.system(size: buttonSize))
                    .accessibility(label: HomeTab.settings.a11yLabel)
                    .badge(shouldShow: Binding(get: {
                        // Can add future values here with OR operator (||)
                        showPreferredSearchLanguageAnnouncement
                    }, set: { _ in
                        // Do nothing, since this should only ever read the value, not write it.
                    }))
            })
        }
    }
}

#Preview("HomeTabView search", traits: .sizeThatFitsLayout) {
    HomeTabView(selectedTab: .constant(.search))
}

#Preview("HomeTabView browse", traits: .sizeThatFitsLayout) {
    HomeTabView(selectedTab: .constant(.browse))
}

#Preview("HomeTabView favorites", traits: .sizeThatFitsLayout) {
    HomeTabView(selectedTab: .constant(.favorites))
}

#Preview("settings", traits: .sizeThatFitsLayout) {
    HomeTabView(selectedTab: .constant(.settings))
}

#Preview("HomeTabView settings without badge", traits: .sizeThatFitsLayout) {
    HomeTabView(showPreferredSearchLanguageAnnouncement: false, selectedTab: .constant(.settings))
}
