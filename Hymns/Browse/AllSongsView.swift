import SwiftUI
import Resolver

struct AllSongsView: View {

    @ObservedObject private var viewModel: AllSongsViewModel

    init(viewModel: AllSongsViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.hymnTypes, id: \.self) { hymnType in
            NavigationLink(destination: BrowseResultsListView(viewModel: BrowseResultsListViewModel(hymnType: hymnType))) {
                Text(hymnType.displayTitle)
            }
        }.padding(.top).background(Color(.systemBackground)).listStyle(PlainListStyle())
    }
}

#if DEBUG
struct AllSongsView_Previews: PreviewProvider {
    static var previews: some View {
        AllSongsView()
    }
}
#endif
