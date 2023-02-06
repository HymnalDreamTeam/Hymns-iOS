import SwiftUI
import Resolver

@available(iOS 16, *)
struct HomeContainerView: View {

    private let searchView = SearchView()
    private let browseView = BrowseView()
    private let favoritesView = FavoritesView()
    private let settingsView = SettingsView()

    @State private var selectedTab: HomeTab = .none

    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator = Resolver.resolve(), selectedTab: HomeTab = .none) {
        self.coordinator = coordinator
        self.selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack(path: $coordinator.stack) {
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
                    .background(Color(red: colorScheme == .light ? 0.95 : 0.05,
                                      green: colorScheme == .light ? 0.95 : 0.05,
                                      blue: colorScheme == .light ? 0.95 : 0.05))
            }.navigationDestination(for: Route.self) { route in
                coordinator.route(route)
            }.hideNavigationBar().edgesIgnoringSafeArea(.bottom)
        }.onAppear {
            // App crashes on startup without this
            if self.selectedTab == .none {
                self.selectedTab = .search
            }
        }
    }
}

#if DEBUG
@available(iOS 16, *)
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
