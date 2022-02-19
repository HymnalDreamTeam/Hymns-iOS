import FirebaseAnalytics
import Resolver
import SwiftUI

struct BrowseView: View {

    @ObservedObject private var viewModel: BrowseViewModel

    init(viewModel: BrowseViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            CustomTitle(title: NSLocalizedString("Browse", comment: "Browse tab title."))
            VStack {
                GeometryReader { geometry in
                    IndicatorTabView(geometry: geometry,
                                     currentTab: self.$viewModel.currentTab,
                                     tabItems: self.viewModel.tabItems)
                }
            }
        }.onAppear {
            let params: [String: Any] = [
                AnalyticsParameterScreenName: "BrowseView"]
            Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
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
