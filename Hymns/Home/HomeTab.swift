import Foundation
import SwiftUI

enum HomeTab {
    case none
    case search
    case browse
    case favorites
    case settings
}

extension HomeTab: TabItem {

    var id: HomeTab { self }

    var content: some View {
        switch self {
        case .none, .search:
            return SearchView().eraseToAnyView()
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

    var a11yLabel: Text {
        switch self {
        case .none:
            return Text("")
        case .search:
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
        case .search:
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
