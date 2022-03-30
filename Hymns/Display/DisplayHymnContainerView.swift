import SwiftUIPager
import SwiftUI

struct DisplayHymnContainerView: View {

    @ObservedObject private var viewModel: DisplayHymnContainerViewModel

    init(viewModel: DisplayHymnContainerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            guard let hymns = self.viewModel.hymns else {
                return ActivityIndicator().maxSize().onAppear {
                    self.viewModel.populateHymns()
                }.eraseToAnyView()
            }
            if hymns.count == 1, let onlyHymn = hymns.first {
                return DisplayHymnView(viewModel: onlyHymn).eraseToAnyView()
            }
            return Pager(page: .withIndex(viewModel.currentHymn),
                         data: Array(0..<hymns.count),
                         id: \.self,
                         content: { index in
                DisplayHymnView(viewModel: hymns[index])
            }).onPageChanged({ newHymn in
                self.viewModel.currentHymn = newHymn
            }).allowsDragging(viewModel.swipeEnabled).eraseToAnyView()
        }
    }
}
