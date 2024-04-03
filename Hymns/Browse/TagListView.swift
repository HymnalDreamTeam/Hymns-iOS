import SwiftUI
import Resolver

struct TagListView: View {

    @ObservedObject private var viewModel: TagListViewModel

    init(viewModel: TagListViewModel = Resolver.resolve()) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            guard let tags = viewModel.tags else {
                return ActivityIndicator().maxSize().eraseToAnyView()
            }
            guard !tags.isEmpty else {
                return GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .center, spacing: 5) {
                            Spacer()
                            Image("empty tag illustration")
                            Text("Create tags by tapping on the", comment: "Former part of the empty tag state text.").lineLimit(3)
                            HStack {
                                Image(systemName: "tag").accessibilityLabel(Text("Illustration showing that there are no tags", comment: "A11y label for the empty tag illustration."))
                                Text("icon on any hymn", comment: "Latter part of the empty tag state text.")
                            }
                            Spacer()
                        }.frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                }.eraseToAnyView()
            }
            return List(tags, id: \.self) { tag in
                NavigationLink(value: Route.browseResults(BrowseResultsListViewModel(tag: tag))) {
                    Text(tag.title).tagPill(backgroundColor: tag.color.background, foregroundColor: tag.color.foreground)
                }.listRowSeparator(.hidden).maxWidth()
            }.listStyle(PlainListStyle()).padding(.top).eraseToAnyView()
        }.onAppear {
            self.viewModel.fetchUniqueTags()
        }.onDisappear {
            self.viewModel.tearDown()
        }.background(Color(.systemBackground))
    }
}

#if DEBUG
struct TagListView_Previews: PreviewProvider {
    static var previews: some View {

        let loadingViewModel = TagListViewModel()
        let loading = TagListView(viewModel: loadingViewModel)

        let emptyViewModel = TagListViewModel()
        emptyViewModel.tags = [UiTag]()
        let empty = TagListView(viewModel: emptyViewModel)

        let withTagsViewModel = TagListViewModel()
        withTagsViewModel.tags = [UiTag(title: "tag 1", color: .blue),
                                  UiTag(title: "tag 2", color: .green),
                                  UiTag(title: "tag 3", color: .none)]
        let withTags = TagListView(viewModel: withTagsViewModel)

        return Group {
            loading.previewDisplayName("loading")
            empty.previewDisplayName("empty")
            withTags.previewDisplayName("with tags")
        }
    }
}
#endif
