import Prefire
import SwiftUI

struct SongInfoDialogView: View {

    @ObservedObject private var viewModel: SongInfoDialogViewModel

    init(viewModel: SongInfoDialogViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.songInfo.isEmpty {
            return ErrorView().eraseToAnyView()
        }
        return
            VStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.songInfo, id: \.self) { songInfo in
                    SongInfoView(viewModel: songInfo)
                }
            }.padding()
                .cornerRadius(5)
                .background(Color(.secondarySystemBackground))
                .eraseToAnyView()
    }
}

 #if DEBUG
struct SongInfoDialogView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let hymn = UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil, author: "MC")

        let dialogViewModel = SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40, hymn: hymn)!
        dialogViewModel.songInfo = [SongInfoViewModel(type: .category, values: ["Worship of the Father"]),
                                    SongInfoViewModel(type: .subcategory, values: ["As the Source of Life"]),
                                    SongInfoViewModel(type: .author, values: ["Will Jeng", "Titus Ting"])]
        let dialog = SongInfoDialogView(viewModel: dialogViewModel)

        let longValuesViewModel = SongInfoDialogViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40, hymn: hymn)!
        longValuesViewModel.songInfo = [SongInfoViewModel(type: .category,
                                                          values: ["Worship Worship Worship of of of the the the Father Father Father"]),
                                        SongInfoViewModel(type: .subcategory,
                                                          values: ["As As As the the the Source Source Source of of of Life Life Life"]),
                                        SongInfoViewModel(type: .author, values: ["Will Will Will Jeng Jeng Jeng", "Titus Titus Titus Ting Ting Ting"])]
        let longValues = SongInfoDialogView(viewModel: longValuesViewModel)
        return Group {
            dialog.previewDisplayName("regular values")
            longValues.previewDisplayName("long values")
        }.previewLayout(.sizeThatFits)
    }
 }
 #endif
