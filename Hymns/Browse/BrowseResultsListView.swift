import SwiftUI

struct BrowseResultsListView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: BrowseResultsListViewModel

    init(viewModel: BrowseResultsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .accessibility(label: Text("Go back"))
                        .accentColor(.primary).padding()
                })
                Text(viewModel.title).font(.body).fontWeight(.bold)
                Spacer()
            }

            Group { () -> AnyView in
                guard let songResults = self.viewModel.songResults else {
                    return ActivityIndicator().maxSize().eraseToAnyView()
                }
                guard !songResults.isEmpty else {
                    return ErrorView().maxSize().eraseToAnyView()
                }
                return List(songResults, id: \.title) { songResult in
                    NavigationLink(destination: songResult.destinationView) {
                        SongResultView(viewModel: songResult)
                    }
                }.resignKeyboardOnDragGesture().eraseToAnyView()
            }
        }.onAppear {
            self.viewModel.fetchResults()
        }.hideNavigationBar()
    }
}

struct BrowseResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        let emptyViewModel = BrowseResultsListViewModel(tag: UiTag(title: "Best songs", color: .none))
        let empty = BrowseResultsListView(viewModel: emptyViewModel)

        let resultObjects = [SongResultViewModel(title: "Hymn 114", destinationView: EmptyView().eraseToAnyView()),
                             SongResultViewModel(title: "Cup of Christ", destinationView: EmptyView().eraseToAnyView()),
                             SongResultViewModel(title: "Avengers - Endgame", destinationView: EmptyView().eraseToAnyView())]
        let resultsViewModel = BrowseResultsListViewModel(category: "Experience of Christ")
        resultsViewModel.songResults = resultObjects
        let results = BrowseResultsListView(viewModel: resultsViewModel)

        return Group {
            empty.previewDisplayName("error state")
            results.previewDisplayName("browse results")
        }
    }
}
