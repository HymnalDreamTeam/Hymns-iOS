import Foundation
import SwiftUI
import Resolver

/// Home container for devices running iOS 15 and earlier. This was primarily because NavigationStack was introduced in iOS 16, so it and its components cannot be used with anything less than iOS 16.
struct HomeContainerView15: View {

    private let searchView = SearchView15()
    private let browseView = BrowseView()
    private let favoritesView = FavoritesView()
    private let settingsView = SettingsView()

    @State var selectedTab: HomeTab = .none

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if selectedTab == .search {
                        searchView
                    } else if selectedTab == .browse {
                        browseView
                    } else if selectedTab == .favorites {
                        favoritesView
                    } else if selectedTab == .settings {
                        settingsView
                    }
                }
                Spacer()
                HomeTabView(selectedTab: $selectedTab)
                    .padding([.horizontal, .bottom])
                    .frame(width: .none, height: 80, alignment: .top)
                    .background(Color(red: 0.7, green: 0.7, blue: 0.7).opacity(0.1))
            }.hideNavigationBar().edgesIgnoringSafeArea(.bottom)
        }.onAppear {
            // App crashes on startup without this
            if self.selectedTab == .none {
                self.selectedTab = .search
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct HomeContainerView15_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // preview all tabs
            HomeContainerView15(selectedTab: .search).previewDisplayName("Home tab")
            HomeContainerView15(selectedTab: .browse).previewDisplayName("Browse tab")
            HomeContainerView15(selectedTab: .favorites).previewDisplayName("Favorites tab")
            HomeContainerView15(selectedTab: .settings).previewDisplayName("Settings tab")
            // preview localization
            HomeContainerView15().environment(\.locale, .init(identifier: "de")).previewDisplayName("German")
            HomeContainerView15().environment(\.locale, .init(identifier: "es")).previewDisplayName("Spanish")
            // preview different sizes
            HomeContainerView15()
                .previewDevice("iPhone 13")
                .previewDisplayName("iPhone 13")
            HomeContainerView15()
                .previewDevice("iPhone XS Max")
                .previewDisplayName("iPhone XS Max")
            HomeContainerView15()
                .previewLayout(.device)
                .previewDevice("iPad Air 2")
                .previewDisplayName("iPad Air 2")
            // preview dark mode
            HomeContainerView15().environment(\.colorScheme, .dark).previewDisplayName("Dark mode")
        }
    }
}
#endif
