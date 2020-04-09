import Resolver
import SwiftUI

struct SearchView: View {
    @ObservedObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchInput)
                List {
                    ForEach(self.viewModel.songResults) { songResult in
                        NavigationLink(destination: songResult.destinationView) {
                            SongResultView(viewModel: songResult)
                        }
                    }
                }.padding(.trailing, -32.0) // Removes the carat on the right
            }
        }.navigationBarHidden(true) //hides the default nav bar to input the custom "x" instead
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: SearchViewModel(backgroundQueue: Resolver.resolve(name: "background"), mainQueue: Resolver.resolve(name: "main"), repository: Resolver.resolve()))
    }
}
