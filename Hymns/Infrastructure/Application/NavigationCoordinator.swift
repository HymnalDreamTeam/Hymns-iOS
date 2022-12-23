import SwiftUI

class NavigationCoordinator: ObservableObject {

    @Published var stack = [Route]()

    func route(_ route: Route) -> AnyView {
        switch route {
        case .home:
            if #available(iOS 16, *) {
                return HomeContainerView().eraseToAnyView()
            } else {
                return HomeContainerView15().eraseToAnyView()
            }
        case .display(let viewModel):
            return DisplayHymnContainerView(viewModel: viewModel).eraseToAnyView()
        case .browseResults(let viewModel):
            return BrowseResultsListView(viewModel: viewModel).eraseToAnyView()
        case .songResult(let viewModel):
            return viewModel.destinationView
        }
    }

    func showSongResult(_ viewModel: SongResultViewModel) {
        stack.append(.songResult(viewModel))
    }

    func jumpBackToRoot() {
        stack.removeAll()
    }

    func goBack() {
        stack.removeLast()
    }
}

enum Route: Hashable {
    case home
    case display(DisplayHymnContainerViewModel)
    case browseResults(BrowseResultsListViewModel)
    case songResult(SongResultViewModel)
}
