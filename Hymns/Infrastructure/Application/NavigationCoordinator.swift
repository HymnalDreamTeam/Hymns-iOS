import Resolver
import SwiftUI

class NavigationCoordinator: ObservableObject {

    @Published var stack = [Route]()

    private let firebaseLogger: FirebaseLogger = Resolver.resolve()

    func route(_ route: Route) -> AnyView {
        switch route {
        case .home:
            return HomeContainerView().eraseToAnyView()
        case .display(let viewModel):
            return DisplayHymnContainerView(viewModel: viewModel).eraseToAnyView()
        case .browseResults(let viewModel):
            return BrowseResultsListView(viewModel: viewModel).eraseToAnyView()
        case .songResult(let viewModel):
            return viewModel.destinationView
        case .versionInformation:
            return VersionView().eraseToAnyView()
        }
    }

    func showSongResult(_ viewModel: SongResultViewModel) {
        stack.append(.songResult(viewModel))
    }

    func jumpBackToRoot() {
        stack.removeAll()
    }

    func goBack() {
        if stack.isEmpty {
            firebaseLogger.logError(BackStackError(errorDescription: "Back stack is empty on back click"))
            stack.removeAll()
        } else {
            stack.removeLast()
        }
    }

    func showVersionInformation() {
        stack.append(.versionInformation)
    }
}

enum Route: Hashable {
    case home
    case display(DisplayHymnContainerViewModel)
    case browseResults(BrowseResultsListViewModel)
    case songResult(SongResultViewModel)
    case versionInformation
}
