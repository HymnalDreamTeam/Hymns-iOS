import Foundation
import SwiftUI

enum HomeTab {
    case home
    case browse
    case favorites
    case settings
}

extension HomeTab: TabItem {

    var id: HomeTab { self }

    var content: some View {
        switch self {
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

    var a11yLabel: Text {
        switch self {
        case .home:
            return Text("Search tab")
        case .browse:
            return Text("Favorites tab")
        case .favorites:
            return Text("Browse tab")
        case .settings:
            return Text("Settings tab")
        }
    }

    func getImage(_ isSelected: Bool) -> Image {
        switch self {
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
