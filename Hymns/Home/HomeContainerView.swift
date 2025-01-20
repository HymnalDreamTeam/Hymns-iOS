import SwiftUI
import Resolver

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
