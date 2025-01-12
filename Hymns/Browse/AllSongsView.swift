import SwiftUI
import Resolver

struct AllSongsView: View {

    @ObservedObject private var viewModel: AllSongsViewModel

    init(viewModel: AllSongsViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.hymnTypes, id: \.self) { hymnType in
            NavigationLink(value: Route.browseResults(BrowseResultsListViewModel(hymnType: hymnType))) {
                Text(hymnType.displayTitle)
            }.listRowSeparator(.hidden)
        }.padding(.top).background(Color(.systemBackground)).listStyle(PlainListStyle())
    }
}

#Preview {
    AllSongsView()
}
