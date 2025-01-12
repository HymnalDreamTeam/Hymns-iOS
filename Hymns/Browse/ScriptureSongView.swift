import Prefire
import SwiftUI

struct ScriptureSongViewModel: Equatable, Hashable {
    let reference: String
    let title: String
    let hymnIdentifier: HymnIdentifier
}

struct ScriptureSongView: View {

    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    let viewModel: ScriptureSongViewModel

    var body: some View {
        Group {
            if sizeCategory.isAccessibilityCategory() {
                VStack(alignment: .leading) {
                    Text(self.viewModel.reference).font(.caption)
                    Text(self.viewModel.title)
                }
            } else {
                HStack {
                    Text(self.viewModel.reference).frame(width: 60, alignment: .trailing).font(.caption).padding(.trailing)
                    Text(self.viewModel.title).frame(alignment: .leading)
                }
            }
        }
    }
}

#if DEBUG
struct ScriptureSongView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        return Group {
            ScriptureSongView(viewModel: viewModel).previewDisplayName("default")
            ScriptureSongView(viewModel: viewModel)
                .environment(\.sizeCategory, .accessibilityMedium)
                .previewDisplayName("accessibility size")
        }.padding().previewLayout(.sizeThatFits)
    }
}
#endif
