import Foundation
import SwiftUI

enum HomeTab {
    case none
    case home
    case browse
    case favorites
    case settings
}

extension HomeTab: TabItem {

    var id: HomeTab { self }

    var content: some View {
        switch self {
        case .none:
            return HomeView().eraseToAnyView()
        case .home:
            return HomeView().eraseToAnyView()
        case .browse:
            return BrowseView().eraseToAnyView()
        case .favorites:
            return FavoritesView().eraseToAnyView()
        case .settings:
            return SettingsView().eraseToAnyView()
        }
    }

    var selectedLabel: some View {
        return getImage(true)
    }

    var unselectedLabel: some View {
        return getImage(false)
    }

    // TODO refactor home tab to search
    var a11yLabel: Text {
        switch self {
        case .none:
            return Text("")
        case .home:
            return Text("Search tab", comment: "A11y label for the search tab icon.")
        case .browse:
            return Text("Browse tab", comment: "A11y label for the browse tab icon.")
        case .favorites:
            return Text("Favorites tab", comment: "A11y label for the favorites tab icon.")
        case .settings:
            return Text("Settings tab", comment: "A11y label for the settings tab icon.")
        }
    }

    func getImage(_ isSelected: Bool) -> Image {
        switch self {
        case .none:
            return Image(systemName: "magnifyingglass")
        case .home:
            return Image(systemName: "magnifyingglass")
        case .browse:
            return isSelected ? Image(systemName: "book.fill") : Image(systemName: "book")
        case .favorites:
            return isSelected ? Image(systemName: "heart.fill") : Image(systemName: "heart")
        case .settings:
            return Image(systemName: "gear")
        }
    }
}
