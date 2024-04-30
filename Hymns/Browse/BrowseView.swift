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
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
#endif
