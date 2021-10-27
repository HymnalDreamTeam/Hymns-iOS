import SwiftUI
import Resolver

struct HomeContainerView: View {

    private let browseView = BrowseView()
    private let favoritesView = FavoritesView()
    private let settingsView = SettingsView()

    @State var selectedTab: HomeTab = .none

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView()
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

                // Need to hide iOS 15 methods from iOS 14 builder so build doesn't fail
                // https://stackoverflow.com/questions/68798163/is-it-possible-to-hide-code-based-on-sdk-version
                #if __IPHONE_15_0
                if #available(iOS 15.0, *) {
                    // Need to set the tab bar appearance to avoid the default transparent appearance
                    // https://stackoverflow.com/a/69296019/1907538
                    UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
                }
                #endif
            }.hideNavigationBar().background(Color(.yellow))
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
