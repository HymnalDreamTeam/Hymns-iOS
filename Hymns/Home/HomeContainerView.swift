import SwiftUI
import Resolver

struct HomeContainerView: View {

    private let browseView = BrowseView()
    private let favoritesView = FavoritesView()
    private let settingsView = SettingsView()

    @State var selectedTab: HomeTab = .none

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if selectedTab == .search {
                        // HomeView should still be recreated or else the label doesn't get removed when you clear history
                        SearchView()
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
struct HomeContainerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // preview all tabs
            HomeContainerView(selectedTab: .search).previewDisplayName("Home tab")
            HomeContainerView(selectedTab: .browse).previewDisplayName("Browse tab")
            HomeContainerView(selectedTab: .favorites).previewDisplayName("Favorites tab")
            HomeContainerView(selectedTab: .settings).previewDisplayName("Settings tab")
            // preview localization
            HomeContainerView().environment(\.locale, .init(identifier: "de")).previewDisplayName("German")
            HomeContainerView().environment(\.locale, .init(identifier: "es")).previewDisplayName("Spanish")
            // preview different sizes
            HomeContainerView()
                .previewDevice("iPhone 13")
                .previewDisplayName("iPhone 13")
            HomeContainerView()
                .previewDevice("iPhone XS Max")
                .previewDisplayName("iPhone XS Max")
            HomeContainerView()
                .previewLayout(.device)
                .previewDevice("iPad Air 2")
                .previewDisplayName("iPad Air 2")
            // preview dark mode
            HomeContainerView().environment(\.colorScheme, .dark).previewDisplayName("Dark mode")
        }
    }
}
#endif
