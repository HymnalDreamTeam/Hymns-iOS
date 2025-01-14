import Prefire
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
                            NavigationLink(value: Route.browseResults(viewModel.createSongInfoItem(value))) {
                                Text(value).font(.callout)
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Text(viewModel.type.label).font(.callout).bold()
                    VStack(alignment: .leading) {
                        ForEach(viewModel.values, id: \.self) { value in
                            NavigationLink(value: Route.browseResults(viewModel.createSongInfoItem(value))) {
                                Text(value).font(.callout)
                            }
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SongInfoView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let viewModel = SongInfoViewModel(type: .category, values: ["Worship of the Father", "The Son's Redemption"])
        return Group {
            SongInfoView(viewModel: viewModel)
        }.previewLayout(.sizeThatFits)
    }
}
#endif
