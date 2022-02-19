import SwiftUI

struct SongResultView: View {

    private let viewModel: SongResultViewModel

    init(viewModel: SongResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(viewModel.title)
    }
}

#if DEBUG
struct SongResultView_Previews: PreviewProvider {
    static var previews: some View {
        SongResultView(
            viewModel: SongResultViewModel(stableId: "Hymn 480", title: "Hymn 480", destinationView: Text("%_PREVIEW_% Destination").eraseToAnyView()))
            .previewLayout(.fixed(width: 200, height: 50))
    }
}
#endif
