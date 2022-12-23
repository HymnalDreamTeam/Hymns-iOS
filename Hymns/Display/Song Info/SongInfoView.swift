import SwiftUI

struct SongInfoView: View {

    @ObservedObject var viewModel: SongInfoViewModel
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    var body: some View {
        Group {
            if sizeCategory.isAccessibilityCategory() {
                VStack(alignment: .leading) {
                    Text(viewModel.type.label).font(.callout).bold()
                    VStack(alignment: .leading) {
                        ForEach(viewModel.values, id: \.self) { value in
                            if #available(iOS 16, *) {
                                NavigationLink(value: Route.browseResults(viewModel.createSongInfoItem(value))) {
                                    Text(value).font(.callout)
                                }
                            } else {
                                NavigationLink(destination: BrowseResultsListView(viewModel: viewModel.createSongInfoItem(value))) {
                                    Text(value).font(.callout)
                                }
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Text(viewModel.type.label).font(.callout).bold()
                    VStack(alignment: .leading) {
                        ForEach(viewModel.values, id: \.self) { value in
                            if #available(iOS 16, *) {
                                NavigationLink(value: Route.browseResults(viewModel.createSongInfoItem(value))) {
                                    Text(value).font(.callout)
                                }
                            } else {
                                NavigationLink(destination: BrowseResultsListView(viewModel: viewModel.createSongInfoItem(value))) {
                                    Text(value).font(.callout)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SongInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SongInfoViewModel(type: .category, values: ["Worship of the Father", "The Son's Redemption"])
        return Group {
            SongInfoView(viewModel: viewModel).toPreviews()
        }
    }
}
#endif
