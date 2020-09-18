import SwiftUI
import Resolver

struct HomeContainerView: View {

    private let homeView = HomeView()
    private let browseView = BrowseView()
    private let favoritesView = FavoritesView()
    private let settingsView = SettingsView()

    @State var selectedTab: HomeTab = .none

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                homeView
                    .tabItem {HomeTab.home.getImage(selectedTab == HomeTab.home).font(.system(size: buttonSize))}
                    .tag(HomeTab.home)
                    .hideNavigationBar()

                browseView
                    .tabItem { HomeTab.browse.getImage(selectedTab == HomeTab.browse).font(.system(size: buttonSize))}
                    .tag(HomeTab.browse)
                    .hideNavigationBar()

                favoritesView
                    .tabItem {HomeTab.favorites.getImage(selectedTab == HomeTab.favorites).font(.system(size: buttonSize))}
                    .tag(HomeTab.favorites)
                    .hideNavigationBar()

                settingsView
                    .tabItem {HomeTab.settings.getImage(selectedTab == HomeTab.settings).font(.system(size: buttonSize))}
                    .tag(HomeTab.settings)
                    .hideNavigationBar()
            }.onAppear {
                if self.selectedTab == .none {
                    self.selectedTab = .home
                }
                UITabBar.appearance().unselectedItemTintColor = .label
            }.hideNavigationBar()
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct HomeContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // preview all tabs
            HomeContainerView(selectedTab: .home).previewDisplayName("Home tab")
            HomeContainerView(selectedTab: .browse).previewDisplayName("Browse tab")
            HomeContainerView(selectedTab: .favorites).previewDisplayName("Favorites tab")
            HomeContainerView(selectedTab: .settings).previewDisplayName("Settings tab")
            // preview localization
            HomeContainerView().environment(\.locale, .init(identifier: "de")).previewDisplayName("German")
            HomeContainerView().environment(\.locale, .init(identifier: "es")).previewDisplayName("Spanish")
            // preview different sizes
            HomeContainerView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
                .previewDisplayName("iPhone SE")
            HomeContainerView()
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
                .previewDisplayName("iPhone XS Max")
            HomeContainerView()
                .previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
                .previewDisplayName("iPad Air 2")
            // preview dark mode
            HomeContainerView().environment(\.colorScheme, .dark).previewDisplayName("Dark mode")
        }
    }
}
#endif
