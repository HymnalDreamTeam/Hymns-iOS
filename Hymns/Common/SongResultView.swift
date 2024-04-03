import SwiftUI

struct SongResultView: View {

    private let viewModel: SongResultViewModel

    init(viewModel: SongResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            viewModel.label.map { label in
                Text(label).font(.caption).fontWeight(.bold).foregroundColor(.gray)
            }
            Text(viewModel.title)
        }.padding(.vertical, 0)
    }
}

#if DEBUG
struct SongResultView_Previews: PreviewProvider {
    static var previews: some View {
        SongResultView(
            viewModel: SongResultViewModel(stableId: "Hymn 480",
                                           title: "O Lord, breathe Thy Spirit on me",
                                           label: "Hymn 255",
                                           destinationView: Text("%_PREVIEW_% Destination").eraseToAnyView()))
            .previewLayout(.fixed(width: 250, height: 100))
    }
}
#endif
