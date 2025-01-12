import Prefire
import Resolver
import SwiftUI

struct BrowseView: View {

    @ObservedObject private var viewModel: BrowseViewModel

    private let firebaseLogger: FirebaseLogger

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(), viewModel: BrowseViewModel = Resolver.resolve()) {
        self.firebaseLogger = firebaseLogger
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            CustomTitle(title: NSLocalizedString("Browse", comment: "Browse tab title."))
            VStack {
                IndicatorTabView(
                    currentTab: self.$viewModel.currentTab,
                    tabItems: self.viewModel.tabItems)
            }
        }.onAppear {
            firebaseLogger.logScreenView(screenName: "BrowseView")
        }
    }
}

#if DEBUG
struct BrowseView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let classicSelectedViewModel = BrowseViewModel()
        classicSelectedViewModel.currentTab = .classic(Text("classic songs").maxSize().eraseToAnyView())
        let classicSelected = BrowseView(viewModel: classicSelectedViewModel)

        let allSelectedViewModel = BrowseViewModel()
        allSelectedViewModel.currentTab = .all(Text("all songs").maxSize().eraseToAnyView())
        let allSelected = BrowseView(viewModel: allSelectedViewModel)
        return Group {
            classicSelected.previewDisplayName("classic selected")
            allSelected.previewDisplayName("all selected")
        }
    }
}
#endif
