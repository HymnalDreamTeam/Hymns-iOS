import SwiftUI

/// Song Result view that shows only a single hymn identfier.
struct SingleSongResultView: View {

    private let viewModel: SingleSongResultViewModel

    init(viewModel: SingleSongResultViewModel) {
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
struct SingleSongResultView_Previews: PreviewProvider {
    static var previews: some View {
        SingleSongResultView(
            viewModel: SingleSongResultViewModel(stableId: "Hymn 480",
                                                 title: "O Lord, breathe Thy Spirit on me",
                                                 label: "Hymn 255",
                                                 destinationView: Text("%_PREVIEW_% Destination").eraseToAnyView()))
        .previewLayout(.fixed(width: 250, height: 100))
    }
}
#endif

/// Song Result view that shows multiple hymn identfiers.
struct MultiSongResultView: View {

    private let viewModel: MultiSongResultViewModel

    init(viewModel: MultiSongResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            viewModel.labels.map { labels in
                HStack {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.4))
                            )
                    }
                }
            }
            Text(viewModel.title)
        }.padding(.vertical, 1)
    }
}

#if DEBUG
struct MultiSongResultView_Previews: PreviewProvider {
    static var previews: some View {
        MultiSongResultView(
            viewModel: MultiSongResultViewModel(stableId: "Hymn 480",
                                                title: "O Lord, breathe Thy Spirit on me",
                                                labels: ["Hymn 255", "Songbase 442"],
                                                destinationView: Text("%_PREVIEW_% Destination").eraseToAnyView()))
        .previewLayout(.fixed(width: 250, height: 100))
    }
}
#endif
