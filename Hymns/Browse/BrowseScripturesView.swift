import Resolver
import SwiftUI

struct BrowseScripturesView: View {

    @ObservedObject private var viewModel: BrowseScripturesViewModel

    init(viewModel: BrowseScripturesViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group<AnyView> {
            guard let scriptures = viewModel.scriptures else {
                return ErrorView().maxSize().eraseToAnyView()
            }

            guard !scriptures.isEmpty else {
                return ActivityIndicator().maxSize().onAppear {
                    self.viewModel.fetchScriptureSongs()
                }.eraseToAnyView()
            }

            return List(scriptures) { scriptureViewModel in
                ScriptureView(viewModel: scriptureViewModel).listRowSeparator(.hidden)
            }.listStyle(.plain).eraseToAnyView()
        }.background(Color(.systemBackground))
    }
}

#if DEBUG
struct BrowseScripturesView_Previews: PreviewProvider {
    static var previews: some View {
        let errorViewModel = BrowseScripturesViewModel()
        errorViewModel.scriptures = nil
        let error = BrowseScripturesView(viewModel: errorViewModel)

        let loadingViewModel = BrowseScripturesViewModel()
        let loading = BrowseScripturesView(viewModel: loadingViewModel)

        let resultsViewModel = BrowseScripturesViewModel()
        resultsViewModel.scriptures
            = [ScriptureViewModel(book: .genesis,
                                  scriptureSongs: [ScriptureSongViewModel(reference: "1:1", title: "Tree of life", hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist),
                                                   ScriptureSongViewModel(reference: "1:26", title: "God created man", hymnIdentifier: PreviewHymnIdentifiers.hymn1151)]),
               ScriptureViewModel(book: .revelation,
                                  scriptureSongs: [ScriptureSongViewModel(reference: "13:5", title: "White horse?", hymnIdentifier: PreviewHymnIdentifiers.hymn40)])]
        let results = BrowseScripturesView(viewModel: resultsViewModel)
        return Group {
            error.previewDisplayName("Error")
            loading.previewDisplayName("Loading")
            results.previewDisplayName("Results")
        }
    }
}
#endif
