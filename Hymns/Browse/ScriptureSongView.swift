import SwiftUI

struct ScriptureSongViewModel: Equatable, Hashable {
    let reference: String
    let title: String
    let hymnIdentifier: HymnIdentifier
}

struct ScriptureSongView: View {

    let viewModel: ScriptureSongViewModel

    var body: some View {
        HStack {
            Text(viewModel.reference)
            Spacer()
            Text(viewModel.title)
        }
    }
}

struct ScriptureSongView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ScriptureSongViewModel(reference: "1:19", title: "And we have the prophetic word",
                                               hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)
        return ScriptureSongView(viewModel: viewModel).previewLayout(.sizeThatFits)
    }
}
